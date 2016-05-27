airport-bssid
=============

If you want to get associated to a specific bssid with Mac OS, use this one.

============
### To Interop Tokyo NOC / STM team

最近のMacのairportコマンドではBSSID指定でAPに接続できなくなっています。
qpSHiNqpが(Interop Tokyo)[http://www.interop.jp] 2013にSTMとして参加していた際に, このことが原因で困ったのでBSSID指定でAssocできるツールをつくりました。

Interop TokyoにはShowNetと呼ばれるめちゃくちゃでかい展示ネットワークが構築され, 来場者や出展者などが利用する膨大な数のAPが設置されます.
これらのAPは, 数種類の異なるポリシーのWiFiを吹いているのですが, 当然同じポリシーのものは同じESSID (通常SSIDと呼ばれる) で提供されます. ESSIDはユーザが個々のAPの設定を意識せずにWiFiを利用できるようにするある種の隠匿/カプセル化のための仕組みです.
一方, ネットワーク構築部隊的には, 個々のAPレベルでの接続性テストを行う業務も生じるので, 事前に得たAPとBSSIDの関連から, BSSIDレベルでのAssociationを行ってAPレベルで疎通性チェックが可能となっていることが望まれます.

このような経緯から, 2013年に私が作ったツールをgithubに上げたのですが, なぜかここ数ヶ月, 外国のユーザからissue報告が上がってきたり, 遂にInterop Tokyo 2016のネットワーク構築期間もスタートしたことから久々にメンテしようと思い立ちました.
不完全な部分もあるかと思いますが, もしバグを見つけたらIssue報告, もし気に入っていただけたら, Star付けて頂けると私のこの上ない喜びとなります.
特に, 幕張組からのIssue報告はできるだけ即日で対応します. 今年もがんばってください.

