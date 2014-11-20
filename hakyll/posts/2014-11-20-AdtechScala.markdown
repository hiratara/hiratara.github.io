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

## 「Dynalystが広告配信で使っている技術(Spray×Akka×Kamon×Zabbix)」韓翔元さん



<!--
## 「アドテク×Scala×パフォーマンスチューニング」水谷陽介さん

## 「軽量言語メインのWeb系エンジニアだった自分がScalaのシステム開発に携わることになった経緯」 重村道人さん
-->
