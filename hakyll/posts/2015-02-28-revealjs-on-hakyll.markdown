---
title: reveal.js on hakyll
---

数式を使ったスライドを作るのに、[mathjax](http://www.mathjax.org/)と[reveal.js](http://lab.hakim.se/reveal-js)の組み合わせはなかなかお手軽でよい。さらに[github pages](https://github.com/hakimel/reveal.js/)を使えば、自前サーバなどを用意しなくてもプレゼン環境が整う。これは、[2年前の圏論勉強会](http://nineties.github.io/category-seminar/)でも使われていた組み合わせである。

現在このページは[Hakyll](http://jaspervdj.be/hakyll/)で管理しているので、スライドもmarkdownで書いてHakyllで管理して一緒に上げてしまうと楽かなと思って環境を整えた。

## 方法1). Pandocのスライド生成機能を使う

始めにこちらの方法を試してみた。[Pandocのデモ](http://johnmacfarlane.net/pandoc/demos.html)にもあるように、Pandocにはreveal.jsを使ったスライドを生成する機能がある。HakyllはPandocを呼び出しているので、この機能を使うといいと考えた。

まず、今回の主役はreveal.jsは `/reveal.js/` というpathに展開しておき、単純にコピーするよう `site.hs` に書く。

```
    match "reveal.js/**" $ do
        route   idRoute
        compile copyFileCompiler
```

プレゼンは `presentations/` ディレクトリに置き、ブログポストと同様にコンパイルをかける。ここでPandocを噛ませる際に、reveal.jsを使うようにしてやるとよい。以下のように書いた

```
  revealTemplate <- (\ (Right x) -> x) `fmap` getDefaultTemplate Nothing "reveal

  .. snip ..

    match "presentations/*" $ do
      let w = defaultHakyllWriterOptions {
            PD.writerSlideVariant = PD.RevealJsSlides
            , PD.writerTemplate = revealTemplate
            , PD.writerStandalone = True
            , PD.writerHTMLMathMethod = MathJax mathjaxURL
            , PD.writerHtml5 = True
            , PD.writerVariables = [("revealjs-url", "/reveal.js")]
            , PD.writerIncremental = True
            }
      route $ setExtension "html"
      compile $ pandocCompilerWith defaultHakyllReaderOptions w
```

コマンドラインでreveal.jsを吐かせるのは非常に簡単だが、ライブラリ経由で実際に走らせるには自分で引数を作る必要があってかなり骨が折れた。[pandoc.hs](https://github.com/jgm/pandoc/blob/master/pandoc.hs#L1175)とか[Pandoc.hs](https://github.com/jgm/pandoc/blob/master/src/Text/Pandoc.hs#L273)とかを見ると答えが出ている。

この方法でプレゼンを吐くことはできたのだが、以下の問題があった。

* 実装がめんどくさかった
* (現時点で) reveal.jsの3.0.x系に対応できていない
* reveal.js のmathjaxプラグインを使わず、自前でmathjaxと統合している


## 方法2). hakyllのテンプレート機能を使う

そもそもhakyllは[テンプレート機構を持っている](https://hackage.haskell.org/package/hakyll-4.6.6.0/docs/Hakyll-Web-Template.html)ので、欲しいのはmarkdownをhtmlに変える機能だけのはず。なので、Pandocにstandaloneなhtmlを吐いてもらうのをやめることにする。

まず、`./reveal.js/test/examples/math.html` をコピって、 [templates/presentation.html](https://github.com/hiratara/hiratara.github.io/blob/master/hakyll/templates/presentation.html)を作った。html化されたスライドを埋めたいところを `$body` にして、タイトルやら著者はメタデータから取ってきて1枚目のスライドに埋めてやればO.K.。

で、`site.hs` ではPandocにmarkdownのhtml化だけやらせる。ただし、reveal.jsで使えるようなhtmlを生成してもらう必要があるので、そのためのオプションはつける必要がある。

```
    match "presentations/*" $ do
      let w = defaultHakyllWriterOptions {
            PD.writerSlideVariant = PD.RevealJsSlides
            , PD.writerHTMLMathMethod = MathJax undefined
            , PD.writerHtml5 = True
            , PD.writerIncremental = True
            }
      let r = let r' = defaultHakyllReaderOptions in r' {
            PD.readerExtensions = Set.filter (/= PD.Ext_auto_identifiers) (PD.r\
eaderExtensions r')
            }
      route $ setExtension "html"
      compile $ do
        item <- pandocCompilerWith r w
        item <- loadAndApplyTemplate "templates/presentation.html" postCtx item
        return item
```

`RevealJsSlides`は適切な形式のhtmlを吐くために必要、`writerIncremental` を指定するとリストが一つずつ表示されるように `class="fragment"` が加えられる。 `MathJax undefined`は数式をmathjaxが読めるような形式でhtml化するのに必要となる。

最後に `Ext_auto_identifiers` を除いている部分だが、reveal.jsの最新版(3.0.0)は`<div>`の`id`属性をURLに使うようで、`id`属性を自動生成されると挙動に問題が出てしまった。そのために除いている。

これで `presentations/` 以下にmarkdownを置くと [スライドが生成される](http://hiratara.github.io/presentations/2015-03-21_monadbase_vol2.html#/)。デザインがいまいち気に食わないのはreveal.jsを使う度に思う課題である。日本語と相性そんなに良くないのかなあ。