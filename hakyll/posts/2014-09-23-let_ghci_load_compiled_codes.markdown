---
title: cabal buildで作った*.oをcabal replで再利用させる
---

最初に断っておくと、開発時にこの方法を使うことは稀だと思う([#heyhey_haskell](https://twitter.com/search?q=%23heyhey_haskell)懇親会調べ)。あくまでも興味本位でやっていることだとを念頭に入れておいてもらいたい。

[ghciのマニュアル](http://www.haskell.org/ghc/docs/7.8.3/html/users_guide/ghci-compiled.html)に書いてある原理は把握した上で、やりたかったのは[stackoverflowに出ていたこの質問](http://stackoverflow.com/questions/15125825/how-to-reuse-cabal-compiled-modules-when-using-ghci)。幸い `cabal repl`だと、 `-odir` に適切な値を渡してくれるので、自前でこの質問にあるようなオプションを指定する必要はない。

が、ghc 7.8.3現在では、これだけではうまくいかない。まず、 `*.cabal` 内に `executable` として指定されているターゲットについては [kazu-yamamotoさんのエントリ](http://d.hatena.ne.jp/kazu-yamamoto/20130912/1378955823) に書いてあるとおり `cabal` は静的ライブラリしか作らず `ghci` は動的ライブラリを見に行くのでうまく行かない。これは以下のようにbuildしておくと`ghci`から`*.o`を参照するようになる。

```
cabal build --ghc-option=-dynamic sudoku3
```

もっとひどいのは `library` 指定されている方で、 `cabal` のissueに上げられている [この問題](https://github.com/haskell/cabal/issues/2048) が ghc-7.8.3 でも解決していない。これに対するワークアラウンドは以下のようなもの。


```
cabal repl --ghc-options='-dynamic -osuf dyn_o -hisuf dyn_hi' lib:typedperl
```

どうしてこれで `cabal` が差し込んでいる `-dynamic-too` が悪さしなくなるのか理解しがたい部分もあるが、こちらの環境ではこれで望みどおりの挙動(コンパイル済コードについてはコンパイルが走らない)となった。いずれにせよ、[ghc 7.8.4では直して欲しい問題](https://ghc.haskell.org/trac/ghc/ticket/8736)である。
