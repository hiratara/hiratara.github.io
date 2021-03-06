---
title: 今日は「アドテク×Scala meetup」の日です
---

[アドテク×Scala meetup](http://connpass.com/event/8384/)へ来ているので、内容を適当にメモっておく。タグは[#adtech_scala](https://twitter.com/search?q=%23adtech_scala)とのこと。

## 挨拶 / 田村さん

* 前半はプレゼン、後半はパネルディスカッション
* 飲み物と寿司あるよ！
* スピーカー紹介

## 「アドテクを支えるScala - Ad Generationの場合」野村欣弘さん

* Scalaは1.5年、ネット広告業界は2.5年
    * medibaさんの前もSSP
* なぜScalaを使い始めたか
    * medibaの求人ではScalaについて触れてない。けど使ってる
    * 2011年くらいから Lift を使ってた形跡。それがスタート
    * Lift押しの人はもう在籍していない・・・
    * その後Play × Spark
* Ad Generation → スマホに注力したSSP
    * ScaleOutに譲渡予定
    * ScalaはRTBに使ってる
* 流れ
    * SDK → 枠データ参照(RTBかどうか)→RTBサーバ(Scala)→DSP
    * DSPからのレスは100ms待つ。オークションを実施。高いものをadserverへ返す
    * 戻すものがなければ adnetwork のタグを戻す
    * ログはfluentd → HDFS → ログ集計(scala)
* rtb-engineはspray (akkaベース。軽量で速い)
    * UIもsprayで実装
    * 70億オークション/月。250(70×3〜4DSP)億bidリクエスト/月
    * 対アドサーバは4,900qps、対DSPは20,000QPS
    * リソースはまだ余裕ある
* ピーク時にさばけないことがあったので、チューニングした
    * akkaとsprayの設定を見直し。似たような設定項目があって、戸惑う
    * ベンチをとりながら調整
* コードの見直し
    * ブロックを防ぐためにFutureを利用
    * スレッドプールを用途ごとに用意 : アドサーバ、DSP、Future、ログ出力、など
* rtb-engine-log
    * sparkを利用。Pythonとかでも書けるけどScalaで
    * mesos上で実行 : sparkと相性がいいので
    * 7種のログ(オークション関連は4種類)
    * cronで10分、1時間、1日の粒度
    * HDFSから読んでPostgressに吐き出し
    * cron → spark → mesos master → zoo keeper に登録してあるワーカへ
    * 6CPU、20GB を 4台。(master 2、slave 4)
    * ログの量 500MB〜1.5GB / hour。配信は10台。
    * 12s 〜 40s / job
* spark を使った感想 → 不満はない
    * メモリに乗せると速いけど、乗せすぎるのもよくないという印象
    * 処理が30分で終わるけど、JVMの停止に30分かかるとか
    * 手軽。身構えなくていい。spark-shellがあったり、コレクション操作する感覚だったり
* scalaを使った感想
    * 並列、並行処理を使いやすい
    * アドサーバやRTBサーバには向いている
    * 用途を選ばず使える。JVMなんで。一種類の言語に統一できていい
    * Javaは知っておいたほうが
    * チューニングには、JVMのパラメータとか知らないと
* 今後の課題
    * チューニングはこのあと誰かがやるよ！
    * 分析などに使えるのを調べたい
* Pのつく言語につかれた方はぜひいらしてください

## 「Dynalyst Scala {Culture})」韓翔元さん

* ノートとかメモっておいたけど消えたのでアドリブで
* Javaは8年、Scalaは1年
* Dynalyst "Dynamic Retargeting + Analyst"
    * スマホに特化したリターゲティング
    * Scala 88.7%(前は90%あったんだけど・・・)、Rubyが9.6% 
* bid, ad, 計測サーバは spray。その裏にakka。ログはredshiftへ
    * ログの最終形はakka(bidの最適化など)
* sprayの理由
    * ドキュメントが充実
    * テストキットがいい
    * ベンチマークも良い
    * Scalaを使いたかった
* 並行性 → 16コアを使い切れてる 
* ExecutionContext(どのスレッドで実行するか)、Future。for記法使える
* spray-routing(他にspray-httpとかもある)
    * DSLっぽく見やすく書ける
    * `FutureDirectives`。akkaのthreadをブロッキングしない
    * `onComplete`で実装させて、`Success`と`Failure`でパターンマッチ(failureはno bid)
    * `Future[A<:BidResponse]`
* ひとつのFutureにすべての計算を入れるのは良くない
* Router, Logic, External Resourcesの3レイヤに分ける
    * スレッドをキックするディスパッチャが必要
    * 3つ一緒でもいいし、レイヤごとでも(dynalystはレイヤごとに最適化)
    * レイヤのローカルスコープに、 `implicit val` で定義
* Futureのテスト → 別スレッドなので普通には無理
    * Specs2 を使う `Matcher[Future[T]]`
    * `.await` できる。リトライやタイムアウトも
* jenkinsを使っているが、CIのサイドエフェクトの影響でテスト落ちることが
    * 再ビルド時間かかる。切り分け辛い
    * Abstract Future → `Monad[M]` にしておけばおｋ
    * `Service` のコンパニオンで、`M`を`Future`にしたり`Id`にしたり
    * テストでは `Id` 、 本番では `Future`
* `Monad`とは → 構造。ステップごとに評価するもの。
* akkaはakka.io読め
    * バッチではなくデーモンで動かしてる
* Master / Workerパターンを使う (letitcrash.comのポスト)
    * Master, Worker, Requester の3つのアクター
    * WorkerはMasterから仕事を受け取って、Futureで仕事をさせる(自分のスレッドはブロックしない)
* Akkaの監視の仕方
    * Typesafe Console
        * UIはいい。type safe社のサポート
        * 値段が高いのでやめた
    * Kamon
        * 無料なのでこっち
        * Akka, Spray, Playをサポート
        * Mailボックスのたまり具合、スループットなどの監視
        * StatsD、New Relic, Datadog などで可視化
        * Migrationはけっこう大変(昨日コンパイルエラー出たのでpull-reqした)
* Kamonとzabbixを連携
    * StatsDにzabbix統合を利用
    * ルータはスレッド使わない、DB周りはスレッド多い
* まとめ
    * SprayのFutureDirectiveを使ってる
    * Abstract Futureでテストしやすく
    * Akkaはmaster/worker パターンを使ってスケールできる構成
    * Kamonでモニタリング
* https://github.com/alexandru/scala-best-practices というのがある
    * 学習コストが高いと言われることが多いので
    * "MUST NOT, SHOULD NOT" だらけ → Scala選ばない理由になりそう・・・
    * このページで勉強するといいんじゃね
    * トライアンドエラーを繰り返して、いいものを見つけるのがエンジニアのやることでしょう

## 「アドテク×Scala×パフォーマンスチューニング」水谷陽介さん

* DSS Tech Blogってのがあるので見てね
* DSPとは → SSPへ入札する
* すべてのプロダクトでscalaを採用している
    * サーバサイド、webコンソール、バッチ
* パフォーマンスチューニングの目的
    * システムの課題の解消
        * 甲府カジノ問題、レイテンシー、バッチ処理の時間超過、開発ツールの動作の遅さ
    * インフラコストの削減
        * アドテクではコストが肥大化しがち
        * 配信料による利益＞インフラ投資 を満たさないと
    * パフォーマンスチューニングにもコスト・リスクはある→インフラ増強が一番の場合もあるので注意
* チューニングの仕方→メトリクス測定、ボトルネック特定、仮説を立てて調整
* 「80%の時間はコードの20%が占める」パレートの法則
    * 半分くらいはデータベースが原因
    * 次点は非同期・スレッド。Scalaの問題とか
    * 正しい実装をしていればI/O bindになる
* I/O : メモリ、ディスク、ネットワーク
    * CPU命令を1回1秒とすると、メモリから読み込み3日, ディスク6.5ヶ月, レイテンシ5年
* 10kbのファイルを100万個読んだ場合 → シーク2.5h   。1回のシークだと3.5msで済む
* メモリ、処理量、応答速度は3すくみの関係
    * 比重を変えるのがチューニング
    * 面積を増やすのが最適化
* パフォーマンスチューニングは、性能要件について関係者の合意を得ることから
    * ブラウザ数、配信数の見積り
    * 月間10億impだと、1000QPSくらいでしょう
    * トラッカーを受け取る量
    * 集計するもの。誰が何を見るのか
    * ビジネスサイドの制約→年度内売上など
    * 数字を出すのが大事。性能テストの目標とする
* 並行プログラミングモデルの設計は重要
    * ブロッキングを減らす。FutureとActorを使うのか
    * スレッドプールのサイズは本番デプロイしないとわからない
* DB設計 : ルックアップ回数。レコードあたりのサイズとか。メモリ使用量。
* 最初の実装は簡潔さ、明快さを優先
    * 線形より悪いアルゴリズムは避けること
    * 推測するな、計測すべし
    * sbt-jmh マイクロベンチマークツール。`run`にオプション指定するだけ
* Scalaコードの最適化
    * コレクションを正しく使う
    * 関数呼び出しより再帰を使うとオーバヘッドを防げる
    * 例: `List#length` の計算量は `O(n)` でそれを `n` 回呼ぶようなコード
    * ScalaBlitz : Scalaコレクションの高速化 (マクロでごにょごにょ)
* 性能テスト
    * シンプルであれば ab
    * Gatling → Scalaで書かれたテストツール
    * JMeterの時代は終わった！
    * 負荷をかける側のリソースに注意
    * 二箇所以上変更しない
* ログの記録、異常検知が大事
    * GCログを出す
    * JMX
    * `/dev/null` に捨てない
    * SLF4J + Profiler どこの処理がボトルネックか
    * 可視化 Grafana + Graphite : トレンドを見れる
* それでも行き詰まったら : C++

## 「軽量言語メインの文系エンジニアだった自分がScalaのシステム開発に携わることになった経緯」 重村道人(@shigemk2)さん

* 文系だった。和民でバイトしながらRuby
    * フィリピンで英会話ごにょごにょ
    * ソシャゲ Pythonとか
* A8.net(2000-), moba8.net(2006-) → Java。tomcat。レガシー
* トラッキングサーバがScala、Play
* Github Enterprise を導入してつらい目にあったり
* Scalaを採用した理由
    * レガシーのリプレイス。Javaからなら楽だろう
    * 上司がScala好き (LiftでWebアプリ書くほど)
    * メンバーもScala好き (Scala Matsuriのスタッフが2名)
    * モナドや圏論が飛び交う職場。ScalaZ
* コンパイルが遅い対策
    * 性能の良いLinuxマシン
* Javaの会社かと思ったらScalaだった
    * まったくわからん。「Javaでいうところの」がわからない
    * とりあえずブログを書く
    * わからなければ教えを請う (自分以外ほぼ全員が書ける)
    * 月10,000円の書籍代(なれる！SEはNG)
    * Brainfuck方言を作ったり
    * LLとの共通点 : Rubyのオブジェクト指向。JSの関数型っぽさ
    * Scalaの本をたくさん読む (Google翻訳フル稼働で英語も)
    * F#でPDP-11のインタプリタを書いたり
    * 8086の逆アセンブラをHaskellで書く
    * 関数プログラミング実践入門、JavaScriptで学ぶ関数型プログラミング、とかとか
* 「俺のScala道はこれからだ」
* 人が足りていないので募集しています

## パネルディスカッション(質疑応答など)

* Q. JVMはスペックが必要で配信に向いてないのでは？
* 水. Scalaを選んだらたまたまJVMだった。できそうだったから
* 重. もともとJavaだった。資源を使える。Javaよりコード数が少ない
* 野. はじめからJVMだった。バケモノって感じではないのでカジュアルになった気がする
    * サーバスペックも上がってる。前職はApache × Perl、Erlang
    * 前職40台くらいだったが10台くらいになった。akkaが軽量ぽい
* 韓. Scala文化が広がっている。経験上、JVMでも2万QPSくらいさばけるのは知ってた。だからScalaも
* Q. Haskell経験あるのでScalazを使いたくなる。どうしてる？
* 韓. Haskellは知らなかった。関数型をやるときはHaskellを避けられない。今のトレンドであり、悪いことではない
* Q. 反対の声はあった？
* 韓. 心の中にはあるかもしれないけど聞いてない
* 水. どうやって勉強した？
* 韓. Functional programming in scalaを読んでる。scala baseの気になるセッションを見たり。みんなで勉強する文化を作った
* Q. ログのフォーマットには何を採用？
* Q. Scalaを使ってからプロダクトをリリースするまでの時間
* 野. LTSV。2〜3人で4ヶ月くらい。
* 韓. TSV。2〜3ヶ月くらい
* 重. トレジャーデータを使っているのでCSV。6ヶ月〜1年くらいのスパン
* 水. redshiftを使っているのでJSON。圧縮がいいものはmessage pack。2〜3ヶ月でプロトタイプ、ロンチは半年
* Q. LLが恋しくなることは？
* 重. コードを書くことが恋しい。なんでもいい(から書きたい)
* Q. フレームワークの選定基準は？
* 野. 理由は、速そうだから。深い理由はない。ベンチはとった。速度が重要
* 韓. type safe社のライブラリを使いたかった
* 水. 個人的にはフレームワーク使いたいが、ノウハウがない。スケジュールがタイト。手慣れたものを使った
* 重. Railsを使ってるとこもある。言語に対する好み。CakeかRails使います
* 麻. コロッサス？という「軽量NIOフレームワークが出てたよね
* Q. Scalaと機械学習
* 水. 機械学習メインではない。Javaのlib linearとか使ってる
* 会場でScalaで機械学習やってる人は？ → いない
* Q. Scalaを採用して難しかったことは？
* 韓. DIの解決が難しい。cake patternとか。むずかしかったのでやめた
* 水. 個人のレベル差。Scalaは個人の力が出やすい。ペアプロで意見があわなかったり。チームの底上げが難しい
* 克服するための社内での取り組みは？
+ 水. 逆に知りたい。スカラのテストをするだけでも奥が深い
* 「複雑・・・高機能な言語」
* 韓. チームメンバーがもともとよかった。ペアプロ、勉強会
* Q. Scalaエンジニアの採用が難しい。RubyとJava、どちらのエンジニアが向いてる？
* 重. Javaの人が市場に多いので、多い。Rubyの人は一人だけ。もともとJavaを使ってたのもある。言語関係なくエンジニアのレベルの高さによる
* 水. PHPのエンジニアもいるけど、習得速かった
* 韓. 最初からScalaの人が来たらラッキー。モチベーション、言語に対する理解は大事。Javaの理解は役に立つ
* 野. 募集はJavaエンジニアのほうが多い。Javaやってたほうが慣れるのは速そう。いミュータブルではハマるかも。クロージャとかで悩んだり
* 麻. 多くの言語を習得している人のほうが習得が早いという発表も前にあった
* Q. sparkを使ってハマったことは？
* 野. HDFSとかでハマることのほうが多い。sparkはいいと思ってる
* 韓. 特にハマったことは聞いてない。「がんばりました」くらいの報告
* 麻. コミッタが来てた。twitterの
* Q. アドテク
* 韓. 今のところはない。adrollという会社の話によると、海外ではerlangを使ってることが多いらしい。選択肢の一つかも
* 韓. 他のプロダクトでは、goでやるという決断をしたところもある
* 水. Apache, enginx の中で処理するときはCで書いている会社もあると聞いた。FPGAでのプログラミングも
* Q. スレッドプールを分けることでどのような問題が解決されたのか？ 
* 韓. 特に問題はなかった。早く終わるfutureもあれば、時間がかかるのもある。プールが枯渇したりする。どのレイヤが時間がかかるか見にくかったのが見やすくなった
* Q. スレッドプールを分けると監視がしやすかった？
* 韓. わかりやすくなった
* Q. コーディング規約は？
* 全員コーディング規約は無さそう。書きたいように書いてそう。
* 重. scalaリフォームはいれている。明文化はしていない
* 麻. Rubyの人とJavaの人のコードが結構違うので、あえてもたないことも多いと聞いている
* Q. Scalaの言語仕様の更新頻度とかどうなんでしょう？
* 水. Javaより更新スピード早い。後方互換もなくなることある。新しいものはその時点の最新版。ハマったら解決。
* 重. Playはバージョンアップ早い。2.3からアクティベータによって起動方法が変わったり。リプレースは辛そう
