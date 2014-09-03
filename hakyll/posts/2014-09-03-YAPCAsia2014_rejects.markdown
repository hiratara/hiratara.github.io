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
    - Q. Tengのスキーマローダーとか使えばいい。O/Rマッパー書く人なら知ってるよね ([ニュアンス違いそうです](https://twitter.com/tokuhirom/status/507129417852674049)、すみません)
    - A. 麻疹なんで

## @__papix__  さん｢帰ってきたPerCUDA 〜PerlとGPGPUが出会い, そして未来へ〜｣

- 画面つながらない → 再起動したら直った！
- 1年前にPerCUDA構想の話をした
    - PerlのコードのみでGPGPUをつくろうとした
    - 一ヶ月でできた→卒業
    - 職質テックトークのmoznionさんの会を参照
- YAPCのトークで落選した
- GPGPUへの注目
    - 64〜128個のコア「今は4000以上あるよ！ちゃんと調べて！！」
    - EC2でもある（高い）
- CUDA、OpenCLなどがある
    - 静的型付けになっちゃう
    - 知識必要
- スクリプト言語でのマッピング (Ruby、Python、Perlなど)
    - 楽なんじゃね？
    - PyCUDA、Pynvvm は有名
    - ParaRuby, Ikra(RubyコードからCを自動生成
- Perl
    - KappaCUDA、ExtUtils::nvcc、OpenCL、CUDA::Minimal
    - PerCUDA → PerlのコードをGPUコードに自動変換
        - GPUないときは、pure perlで実行(MBAにはないよ)
        - 1200倍高速に！
- CPU側処理とGPU側処理を切り分けて実装する必要
    - CPUとGPUのメモリが共通ではないので
- CUDA
    - NVIDIAが提供するGPGPUフレームワーク
    - CUDA C言語とCUDA API
    - NVCCコンパイラもある
    - llvmを使ってるので、通常のCやFortranでも使える
- LLVM
    - Clang
    - LLVM IRを介すので、言語、アーキテクチャに依存しない
    - 変換フェーズでの最適化がいい感じ
- Compiler::CodeGenerator::LLVM → Perl コードをLLVM IRへ
    - 使えない構文が多いので見送り
- PerCUDA
    - 変換系と実行系にわかれている
    - PTXに変換して、GPU実効しない場合はPerlの通常の関数を呼ぶ
    - 正規表現でCに変換している(！)
    - GPUでじっこうした結果をまたPerlでラップする
    - CUDAのAPIでGPUを操作
- 1024x1024の行列の乗算は1000倍以上(生CUDAの方が5倍くらい速いけど)
    - Perlのデータ変換が遅い
- 極悪な正規表現があっても大学院は終了できる
- 今後
    - GPUの値段が下がっている
    - Imager的なものをGPUでやろうとしてたけど
    - GPGPU坂をよ
- 質疑応答
    - Q. OpenCLの予定は？
    - A. ないです
    - Q. 型あまりよくないですよ
    - A. 型ないと動かないですよ
    - Q. あの正規表現ずっとあるんですけどなんとかならないですか
    - A. 時間がなかったのです

## @punytan さん｢Model Layer Development Tips｣

- バリデーション、DB、テストをなんとかする
- バリデーション
    - Mouse::Util::TypeConstraints
    - subtypeを使って、文字列や自然数などを
- Data::Validatorを使うとよい
- Internals::SvREADONLY は悲しいことになる
    - NoRestricted を使うといい
    - ないキーにアクセスすると落ちる
    - 「それをチェックしたいからそうしてるのでは」「xorとかしているときは厳しい」
- SQLの生成にはSQL::Formatを使う
- DBIx::HandlerでDBに接続する
    - コネクションハンドリング、scopeベース
    - fork safeなのでpreforkの時は必須
    - txnメソッドでトランザクション
- DBIのマニアックなメソッド
    - selectrow_*ref, selectall_*ref
- DBIx::QueryLog
    - 開発中に、どんなクエリを出してるか見る
    - colorとかcompactとかexplainは便利
- テスト → コンパイル、データ、prove、高速化
    - Test::LoadAllModules → 全部ロードしてコンパイルチェック
    - Test::MOre、Test::Deep、Test::Deep::Matcher → データのチェック
        - superhashofとか
    - Test::Pretty → proveの結果を見やすく。`prove -Pretty`
    - Test::Docker::MySQL → Dockerコンテナでテストを速く
        - `$guard->get_port` でおｋ
        - スキーマやフィクスチャを事前用意しておくとよい
- Alpaca.pm
    - モデルフレームワーク
    - Proof of Conceptを実装
    - モデルにフォーカス
    - 大量のデータベースを扱える(スケーラブル)
    - ビルトインのテストフレームワーク
- 例えば、ブログの記事の読み込み
    - DB定義、型のバリデーション、ロジックを書く
    - テスト → テーブルロード、実行
    - cmpとかis_deeplyとかはデータのdumpがでなくて不便
    - スロークエリのハイライトとか
    - kamipoさんがmysql casualで話してたアレ（？）を使いたい
- デモ → さっきまでは動いてたんだけど
- 質疑応答
    - Q. Test::DockerMysqlDは使ってます?
    - A. 今はまだ。使えると思う
    - Q. セットアップが面倒なのはどうする？
    - A. 頑張る
    - Q. Test::Prettyを使うと壊れてしまうようなテストはどうする？
    - A. そういうときはTest::Prettyを使わない

## @xtetsuji  さん｢今に伝えるメールの技術｣

- みんな飲んでますか
    - 「平成生まれはメール使わないでしょ？」
    - 「DISは許しません」
    - 「xtetsujiです。xtetsujiです。よろしくお願いします」
    - mod_perl職人から、メールで勝負
    - トーク落ちたので・・・
- AnyEventを封じられたのでmod_perlでSMTPサーバ作った経験
- メールを取り巻く
    - SPAM、未読、SMTPがシンプルじゃない、POP3もIMP4も面倒、社内でも使わない
- Sがシンプルじゃない問題
    - SOAPの例「(Sは)現状は何かの頭文字ではないとされている」
- gmailのせいで社内のメールサーバがなくなってきてる
    - ガラケーが消えたのも大きい
    - IM、チャットの台頭
- 「シニアエンジニアによるガラケー大戦回顧録」というイベント
    - ひろ＊ちゅさんにretweetされてバズった
    - インデックスさんの倒産にちなんで
- ガラケーとメールの関係
    - 空メという文化
    - 通知もメール
- メールが使われないとまずい
    - メールの技術が継承されない
- MTA : Mail Transfer Agent
    - 今は Postfix を選ぶといい
    - バージョンアップが激しい(最新版は2.11.1)
    - 日本Postfix友の会(新宿のロイホで作った) → 活動したい
    - Postfixのページ postfix-jp.info も更新が止まってる ← 叩き潰したい
- SMTPを手でしゃべる
    - telnet localhost 25
    - PerlならNet::SMTP (コアモジュール)
    - RCPT TOで拒否されるのとDATAで拒否されるのと複数パターン
        - 前者は指定拒否されてる場合。後者はspam判定
- Email::Sender Moose依存からMoo依存に変わった
    - ラッパーを作ってます
    - 「Tegami」とか予定
- 受信
    - Postfixのpipeを使う
    - .forwardにかいたりmaster.cfにサービスとして書いたり
- メルマガの消し込み
    - エラーメールをプログラムで受信して配信しないようにする
    - master.cf使ったほうがエンベロープfromがもらえるので便利
    - 受け取り時に落ちないように
- Qpsmtpd
    - Perl製のメールサーバ
    - forkする感じでもない
- エラー文面の文面の解析
    - bounceHammer(perl製)で
- メルマガ大量配信
    - 外部に任せるといい
    - サーバとIPアドレスを並べる
- fml4はperl5.10で動かなくなった
    - fml8プロジェクトが後継。普及しない
    - Python製のMailmanが普及だけど、使いにくい
- 絵文字
    - Encode::JP::MobileやUnicode::Japanese
    - 今ではEncodeモジュール
- ガラケーから絵文字
    - 下駄になる
    - LINE使ったほうが早いよ！
- メールの技術はロストテクノロジー化したけど、生き残るはず
- 「メールは滅びぬ」

## @saisa6153 さん ｢今から始めるレガシーコード改善レポート｣

- レガシーは資産、遺産
    - legacy system だと古くなったもの的な意味になる
- 新しい技術 → 高速になる。新しい脆弱性も出る
- ユーザーが必要とするので止められない
- 新しくなることのメリット
    - 0.1秒遅いと1%売上ダウン、0.5秒遅くなると20%検索数がダウン
    - セキュリティをないがしろにするリスク
    - でも、そこまでメリットある？
- あなたがレガシーと思うものがレガシーである
    - エンジニア、顧客、エンドユーザ、マネージャ → 関わる人はひとりじゃない
    - 古くてもいいという人も多い(XP)
    - 深夜の不在着信は辛い
- ハードウェア、ソースコードは勝手に変わったりしない
    - ただし、システムをとりまく環境は常に変わる
    - システムも世界の変化についていかなければならない→ついていけないものがレガシー
- レガシーはダメか
    - 問題はおおい
    - コストを考える必要 → お金がない。競合に勝つスピード。
    - 次々と現れる新技術
    - レガシーの方がコストが高い、となる機運が高まった時に手を付ける
- 題材: システムPerl。Catalyst。1億PV
    - 顧客ごとのカスタマイズ(コピペ。リポジトリが別(git + subversion)ネットワークごとフォーク)
    - OSやMiddle Wareが古すぎる。仮想化するとなぜかトラブル
    - サーバごとにCPANバージョン違う。プロダクトコードがサーバ内でのみ弄られてる（！）
    - シンボリックリンクの多用。NFS
    - バッチが終わらない。止まる、リトライ負荷
    - コードスタイルが違いすぎる。modelが薄い。テストがない。マイグレーションって何？
- 「Perlに起因するレガシーさはない」
    - Googleとかで見るとトレンド下がってるけど
    - 「衰退してるのは僕らだった」
    - レガシーさの判断、同僚に判断、優先順位付け（全部は無理）
    - 見切り発車で失敗すると次はない→慎重に
- プロダクトのフォークの問題
    - 可能な限り合わせる
    - デベロップブランチで運用されているサーバの修正(顧客と調整)
- 次の手
    - バッチを減らす 
    - Git化
    - GitDDL::Migrator
    - Test:mysqld
    - バッチは手を出しやすい
- さらに次の予定
    - テストの導入、規約、Ansibleの導入
- 一番つらかったところ
    - どこから手を出すのかわからない
    - 障害やバグの割り込みが多い
    - モチベーションが上がらない
        - 新しいものを生み出していない後ろめたさ
- 「技術的負債を倍返しするイメージ」「前任者は殉職した」と考えるのがいい
- どうするべきだった（どうするべき）
    - CI/CD環境は重要
    - コマンド1つでデプロイできるようになってから開発スタート
    - コーディング規約、設計方針、バージョン管理
    - 引き継ぎへの備え（組織でやる以上仕方ない）
    - 開発完了（運用開始前）までに問題を解決しておく
    - OSやMiddlewareをアップデートする状態は維持
- 辛くなったらグリーンフィールド(政治的、技術的制約のないプロジェクト)に関わる
- 良かった点
    - 良くなってるという実感がある
    - 最近のプロジェクトはモダンになってるので希望はある
    - マイナスを0にするのも、大事、と考える
    - 反面教師として使える
- これからレガシーシステムに向かう人
    - 直す意義を考えてビジネスサイドを動かす
    - 見方を見つける
    - 業務との平行は避ける

<!--
## LTタイム
### @mala さん「」
### @note103 さん「」
### @karupanerura さん「」
### @xaicron さん「」
-->
