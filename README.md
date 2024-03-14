# HentaiAtHome-Plugin-CN
这个项目是 LANraragi 的插件，由[sakuyamaij](https://github.com/sakuyamaij/LANraragi/tree/d83ea34557f1ade648a631b00100e36bbdd99060)大佬提交。旨在自动从由 HentaiAtHome 客户端下载的档案中提取 `galleryinfo.txt` 中的信息，并添加到数据库中。

原始插件目前(2024/3/14)仍处于 PR 阶段，因此我将其提取出来并参考 [zhy201810576/ETagConverter](https://github.com/zhy201810576/ETagConverter) 插件，尝试把tag信息转换成中文。~~希望有大佬去[提交](https://github.com/Difegue/LANraragi/pull/944)一下测试代码，测试通过后的原始插件就可以集成进LANraragi了。~~

代码已在200+样本上测试通过，但由于本人此前未接触过Perl，因此使用此插件时还请务必备份数据库，以免造成数据丢失，如果有错误，请提出issue，也欢迎提交PR。

## 使用方法

参考[zhy201810576/ETagConverter](https://github.com/zhy201810576/ETagConverter)

`db.text.json`项目地址：[EhTagTranslation](https://github.com/EhTagTranslation/Database/releases)