# NFCタグ操作

brew install libusb

nfcpy.py
ndeftool.py
pip install ndeftool

ndeflib.py

[NFCタグ で鍵を開けよう（1） NFCタグにURIを書き込む](http://www.tokoro.me/posts/nfc-iphone-1/)


##  タグ情報

cd /Users/yamazakishouji/Dev/expedition/expedition/utility/nfcpy/examples
python tagtool.py show

## フォーマット

cd /Users/yamazakishouji/Dev/expedition/expedition/utility/nfcpy/examples
python tagtool.py format

## URI 書き込み

cd /Users/yamazakishouji/Dev/expedition/expedition/utility/nfcpy/examples
ndeftool uri https://youtu.be/0E00Zuayv9Q | python tagtool.py load -


ndeftool text 大崎 | python tagtool.py load -
ndeftool text "大崎" id "ymzk" | python tagtool.py load -


ndeftool text --language jp --encoding UTF-8 "大崎" id "ymzk"  | python tagtool.py load -


＃ swift ライブラリ管理

## carthage カーセッジ

brew install carthage

https://qiita.com/tsuzuki817/items/8f6e2e0c2b3f9d197097

## cocoapods




mBaaS
- AWS Mobile Hub
- Firebase
