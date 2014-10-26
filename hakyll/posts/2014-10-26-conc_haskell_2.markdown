---
title: 今日は「第2回 「Haskellによる並列・並行プログラミング」読書会」の日です
---

[第2回 「Haskellによる並列・並行プログラミング」読書会](http://partake.in/events/8cb2c3a9-777d-450a-8e1c-350bbb1eb324)へ来ている。基本的に朗読形式なので、議論を中心にメモしておく。

* 4章 データフロー並列:Parモナド
    * p.59 `IVar i` より 「`IVar` の `i`」と書くべきではないか
    * p.61 `put_` で速度が向上するのはなぜか → 評価済かどうか、データ構造を末端までなめなくていいため
    * `IVar` はなぜ `Eq` なの？
    * 実装を見ると `IORef` で実装されてる (via: http://hackage.haskell.org/package/monad-par-0.3.4.6/docs/src/Control-Monad-Par-Scheds-Direct.html#IVar )
* 4.1 例:グラフの最短経路
    * グラフの番号は飛び飛びでもいいの？ → 多分連続してい
    * ノードが連結してないとまずいのでは？ → 大きいウェイトで表せばいいでしょう
    * `k=0`のとき直接のノードのみになるとは？ → 経由がないので
    * 脱線: `Nothing` と `Just` に順序ついてるけど、逆にしたいとこもあるのでは？ → そういう `Down` 型がある
    * `Maybe` を使ってるけど、 `Maybe` と同じ性質を持ってるわけではないよね。ので `newtype` すべき
    * Generalized newtype deriving拡張ってのがあるので、それで楽できる
    * 長さとは重みの合計？ → はい。微妙かも
    * `Data.IntMap.Strict` が新しいバージョンにはある
    * 畳み込みは結合的だと並列化できる？ → 結合則があればどこからでも
    * なんで3.02倍？→4.17/1.38
* 4.2 パイプライン並列
    * p.67 `ByteStrings` になってる
    * p.68 `sa.hs` ではなく `rsa.hs`
    * 試しに rsa-pipeline.hs の threadscope を動かしてみる
    * 生産者が `Fork` を入れる。消費者が `fork` する。[参考](http://hiratara.github.io/posts/2014-09-14-parallel-haskel-excersize.html)
* 4.2.1 生産者の流量制限
* 4.2.2 パイプライン並列の制限
* 4.3 会議の時間割
    * p.69 「各パイプラインステージが単一のforkによるもので」は読み替える微妙な日本語？
    * p.72 `timetable` の定義が途中で切れてる？ → 以降に実装が続いていて、p.74で完成してる
    * p.74 「永遠に帰ってこない」は「永遠に返って来ない」？
* 4.3.1 並列性の追加
    * Pattern guards は Haskell2010 から入ってる
* 4.4 例:並列型推論器
* 4.5 別のスケジューラを使う
* 4.6 戦略と比較したParモナド