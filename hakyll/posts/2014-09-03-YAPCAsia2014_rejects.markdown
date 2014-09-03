---
title: 今日は YAPC::Asia 2014 Reject con の日です
---

[YAPC::Asiaのreject con](http://www.zusaar.com/event/14507005)に参加します。自分用に執ったメモを公開しておきます。

## @__papix__さん / オープニング

- トークで落ちて悔しいって言ってたら開催の運び
- 悔しい5人と飛び入りLT
- 乾杯！

## @ytnobody & @tsucchi  さん｢これはORMですか? いいえOtogiriです - 基礎編｣

### @ytnobodyさん

- これゾン関係ない
- DBIx::Sunny + SQL::Maker
- ORM
    - 車輪の再発明。麻疹の一種
- 動機
    - TengはSchema書くのがおっくう
    - TengはSchema::Dumperで自動生成できる
    - 自動生成されたコードに TYPE => 4 みたいなマジックナンバーが
    - SQL::Translator::Producer::Teng でよくなる
    - テーブル変更頻繁だし、そこに手間かけたくない
- OogiriはSchmaがないので、面倒事がない
    - `strict => 0` を指定しないと、Hash-refが食わせられなかったり
    - select, updateはTengっぽい
    - transactionやinflateのサポート
- デフォルトではstrict 1
    - decode_json したものは食わせられない
    - SQL::QueryMakerが提供する関数群がexportされるので、それを使う
- 行数少ない。合計で200行以下
 
### @tsucchiさん Otogiriの話応用(?)編

- SQL::Executor みたいの作ってた
    - 似てるけど、DBIx::Sunnyベースじゃない
    - 一年くらいOtogiriに乗っかってる
- Otogiri::Plugin
    - `Otogiri::Plugin::DeleteCascade` → FKを辿って親も消す。`delete_cascade()`
    - Otogiriの名前空間にメソッド生やす
    - TableInfo (show tables), BulkInsert, WueryWithNamedPlaceholder
- OtogiriとReplyの組み合わせ
    - Reply は irb 的なの。repl
    - Otogiri::Plugin::DataDumperAutoEncode → 自動でエンコード
    - Reply::Plugin::ORM → Reply環境でotogiriが使える
- デモ
    - TableInfo, Desc, Selectの例
    - Delete_cascadeも便利
- oracleのクライアントの代わりに使ったりinflateと組み合わせると便利かもね
- 今後
    - Pluginで便利なものはコアに引き上げたいな
    - Pluginのグルーピングしたいな
- 質疑応答
    - Q. Tengのスキーマローダーとか使えばいい。O/Rマッパー書く人なら知ってるよね
    - A. 麻疹なんで

<!--
## @__papix__  さん｢帰ってきたPerCUDA 〜PerlとGPGPUが出会い, そして未来へ〜｣
## @punytan  さん｢( ✌'ω')✌ 楽しいモデル層開発｣
## @xtetsuji  さん｢今に伝えるメールの技術｣
## @saisa6153 さん ｢今から始めるレガシーコード改善レポート｣
## LTタイム
### @mala さん「」
### @note103 さん「」
### @karupanerura さん「」
### @xaicron さん「」
-->
