package LANraragi::Plugin::Metadata::HatH_CN;

use strict;
use warnings;
use utf8;

#Plugins can freely use all Perl packages already installed on the system
#Try however to restrain yourself to the ones already installed for LRR (see tools/cpanfile) to avoid extra installations by the end-user.
use Mojo::JSON qw(decode_json encode_json);
# use Mojo::Util qw(html_unescape);
# use Mojo::UserAgent;

#You can also use the LRR Internal API when fitting.
use LANraragi::Model::Plugins;
use LANraragi::Utils::Logging qw(get_plugin_logger);
use LANraragi::Utils::Archive qw(is_file_in_archive extract_file_from_archive);


#Meta-information about your plugin.
sub plugin_info {

    return (
        #Standard metadata
        name            => "HentaiAtHome Plugin CN",
        type             => "metadata",
        namespace    => "hentaiathomeCN",
        author          => "lily",
        version         => "0.1",
        description    => "通过 HentaiAtHome Downloader 的 galleryinfo txt 文件收集嵌入存档的元数据。",
        icon =>
          "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAAABmJLR0QA/wD/AP+gvaeTAAAACXBI\nWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4wYDFB0m9797jwAAAB1pVFh0Q29tbWVudAAAAAAAQ3Jl\nYXRlZCB3aXRoIEdJTVBkLmUHAAAEbklEQVQ4y1WUPW/TUBSGn3uvHdv5cBqSOrQJgQ4ghqhCAgQM\nIIRAjF2Y2JhA/Q0g8R9YmJAqNoZKTAwMSAwdQEQUypeQEBEkTdtUbdzYiW1sM1RY4m5Hunp1znmf\n94jnz5+nAGmakiQJu7u7KKWwbRspJWma0m63+fHjB9PpFM/z6Ha7FAoFDMNga2uLx48fkyQJ29vb\nyCRJSNMUz/PY2dnBtm0qlQpKKZIkIQgCer0eW1tbDIdDJpMJc3NzuK5Lt9tF13WWl5dJkoRyuYyU\nUrK3t0ccx9TrdQzD4F/HSilM08Q0TWzbplqtUqvVKBaLKKVoNpt8/vyZKIq4fv064/EY2ev1KBQK\n2LadCQkhEEJkteu6+L6P7/tMJhOm0ylKKarVKjdu3GA6nXL+/HmSJEHWajV0Xf9P7N8TQhDHMWEY\nIoRgOBzieR4At2/f5uTJk0RRRLFYZHZ2liNHjqBFUcRoNKJarSKlRAiRmfPr1y/SNMVxHI4dO8aF\nCxfI5/O4rotSirdv33L16lV+//7Nly9fUEqh5XI5dF0nTdPMaSEEtm3TaDSwLAvLstB1nd3dXUql\nEqZpYlkW6+vrdLtdHjx4wPb2NmEYHgpalkUQBBwcHLC2tsbx48cpFos4jkMQBIRhyGQyYTgcsrGx\nQavVot1uc+LECcbjMcPhkFKpRC6XQ0vTlDAMieOYQqGA4zhcu3YNwzDQdR3DMA4/ahpCCPL5fEbC\nvXv3WFlZ4c+fP7TbbZaWlpBRFGXjpmnK/Pw8QRAwnU6RUqJpGp7nMRqNcF0XwzCQUqKUolwus7y8\njO/7lMtlFhcX0YQQeJ6XMXfq1Cn29/epVCrouk4QBNi2TalUIoqizLg0TQEYjUbU63VmZmYOsdE0\nDd/3s5HH4zG6rtNsNrEsi0qlQqFQYH19nVevXjEej/8Tm0wmlMtlhBAMBgOkaZo0Gg329vbY2dkh\nCIJsZ0oplFK8efOGp0+fcvHiRfL5PAAHBweEYcj8/HxGydevX5FxHDMajajVanz69Ik4jkmSBF3X\n0TSNzc1N7t69S6vV4vXr10gp8X2f4XBIpVLJghDHMRsbG2jT6TRLxuLiIr1eDwBN09A0jYcPHyKE\n4OjRo8RxTBRF9Pt95ubmMud93+f79+80m03k/v4+UspDKDWNRqPBu3fvSNOUtbU16vU6ly5dwnEc\ncrkcrutimib5fD4zxzRNVldXWVpaQqysrKSdTofLly8zmUwoFAoIIfjXuW3bnD17NkuJlBLHcdA0\nDYAgCHj27BmO47C6uopM05RyucyLFy/QNA3XdRFCYBgGQRCwubnJhw8fGAwGANRqNTRNI0kSXr58\nyc2bN6nX64RhyP379xFPnjxJlVJIKTl37hydTocoiuh0OszOzmJZFv1+n8FgwJ07d7hy5Qrj8ZiP\nHz/S7/c5ffo0CwsL9Ho9ZmZmEI8ePUoNwyBJEs6cOcPCwgLfvn3j/fv35PN5bNtGKZUdjp8/f3Lr\n1q3svLVaLTzPI4oiLMviL7opJdyaltNwAAAAAElFTkSuQmCC",
        parameters => [
            {type => "bool",desc => "使用日文标题"},
            {type => "bool",desc => "添加上传者信息"},
            {type => "bool",desc => "添加上传时间"},
            {type => "string", desc => "EhTagTranslation项目的JSON数据库文件(db.text.json)的绝对路径" }
        ]
    );

}

#Mandatory function to be implemented by your plugin
sub get_tags {

    shift;
    my $lrr_info = shift;    # Global info hash
    my ($use_jpn_title, $add_uploader, $add_uploadtime, $db_path) = @_;

    my $logger = get_plugin_logger();
    my $file   = $lrr_info->{file_path};

    my $path_in_archive = is_file_in_archive( $file, "galleryinfo.txt" );
    if ($path_in_archive) {

        # Extract galleryinfo.txt
        my $filepath = extract_file_from_archive( $file, $path_in_archive );

        # Open it
        open( my $fh, '<:encoding(UTF-8)', $filepath )
            or return ( error => "无法打开$filepath!" );
			
			my $tag = "";
			my $title = "";
            while ( my $line = <$fh> ) {
				# Check if the line starts with Title:
				if ( $line =~ m/Title: (.*)/ && $use_jpn_title ) {
					$title = $1;
				}
				# Check if the line starts with Uploaded By: 
				if ( $line =~ m/Uploaded By: (.*)/ && $add_uploader ) {
					$tag .= "uploader:$1, ";
				}
				# Check if the line starts with Upload Time: 
				if ( $line =~ m/Upload Time: (.*)/ && $add_uploadtime ) {
					$tag .= "Upload Time:$1, ";
				}
                # Check if the line starts with TAGS:
                if ( $line =~ m/Tags: (.*)/ ) {
					$tag .= $1;
                    my $cntag = get_cn_tag($tag, $db_path);
                    return ( tags => $cntag , title => $title );
                }
            }
		return ( error => "在galleryinfo.txt中找不到tag!" );
    } else {
        return ( error => "在文档中找不到galleryinfo.txt!" );
    }
}

sub get_cn_tag {
    my ($tags, $file_path) = @_;
    my $logger = get_plugin_logger();

    my @list = map { s/^\s+|\s+$//g; $_ } split( /,/, $tags );

    my $filename = $file_path; # json 文件的路径
    my $json_text = do {
        open(my $json_fh, "<", $filename)
            or $logger->error("Can't open $filename: $!\n");
        local $/;
        <$json_fh>
    };
    # $logger->info("list before proceed: @list");
    my $json = decode_json($json_text);
    my $target = $json->{'data'};

    for my $item (@list) {
        my ($namespace, $key) = split(/:/, $item);
        for my $element (@$target) {
            # 如果$namespace与'namespace'字段相同，则进行替换
            if ($element->{'namespace'} eq $namespace) {
                my $name = $element->{'frontMatters'}->{'name'};
                $item =~ s/$namespace/$name/;
                my $data = $element->{'data'};
                # 如果在'data'字段中存在$key，则进行替换
                if (exists $data->{$key}) {
                    my $value = $data->{$key}->{'name'};
                    $item =~ s/$key/$value/;
                }
                last;
            }
        }
    }
    my $list_str = join(", ", @list);
    # $logger->info("list after proceed: $list_str");
    return $list_str;
}

1;
