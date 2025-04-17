local assetLanguage = Sirin.CLanguageAsset.instance()
assetLanguage:addLanguage( 0, "strKR", "ko-kr", 949 ) -- id for launcher, script prefix, client path
assetLanguage:addLanguage( 1, "strBR", "pt-br", 1252 )
assetLanguage:addLanguage( 2, "strCN", "zh-cn", 936 )
assetLanguage:addLanguage( 3, "strGB", "en-gb", 1252 )
assetLanguage:addLanguage( 4, "strID", "en-id", 1252 )
assetLanguage:addLanguage( 5, "strJP", "ja-jp", 932 )
assetLanguage:addLanguage( 6, "strPH", "en-ph", 1252 )
assetLanguage:addLanguage( 7, "strRU", "ru-ru", 1251 )
assetLanguage:addLanguage( 8, "strTW", "zh-tw", 950 )
assetLanguage:addLanguage( 9, "strUS", "en-us", 1252 )
assetLanguage:addLanguage( 10, "strTH", "th-th", 874 )
-- add more languages below this line
-- Example:
-- assetCtrl:AddLanguage(11, "strTR", "tr-tr", 1254 )


-- default language id if translation for user selected language not provided.
assetLanguage:setDefaultLanguage( 3 ) -- default language British English
