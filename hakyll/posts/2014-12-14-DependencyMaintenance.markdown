---
title: 今はまだtransformers 0.3のサポートが必要
---

[GHC 7.8, transformers 0.3, and lenient lower bounds](https://t.co/fjxbuYP8jz)に書いてあるとおりの話。

[lmabdabot-hipchat-plugins](https://github.com/hiratara/lambdabot-hipchat-plugins)で[pontarius-xmpp](https://hackage.haskell.org/package/pontarius-xmpp)使ってるんだけど、hh変更が多いライブラリなのでgithubのmasterからビルドしようと思ったらハマった。hackageに[上がってないcommit](https://github.com/pontarius/pontarius-xmpp/commit/730b3ce61a93c1fa0a)がtransformer 0.4へ依存し始めたため、先に貼ったリンクの問題でビルドができない。

具体的には、lambdabotが依存しているmuevalがghcに依存しているためにtransformer 0.3縛りがあるために、以下のエラーが出る。

```
% cabal install -p --only-dependencies --ghc-options="-O2 -threaded -fprof-auto" -j
Resolving dependencies...
cabal: Could not resolve dependencies:
trying: lambdabot-5.0 (user goal)
trying: lambdabot-hipchat-plugins-0.1.0.0 (dependency of lambdabot-5.0)
next goal: transformers (dependency of lambdabot-hipchat-plugins-0.1.0.0)
rejecting: transformers-0.3.0.0/installed-16a... (conflict: pontarius-xmpp =>
transformers>=0.4)
trying: transformers-0.4.2.0
trying: lambdabot-haskell-plugins-5.0 (dependency of lambdabot-5.0)
trying: mueval-0.9.1.1 (dependency of lambdabot-haskell-plugins-5.0)
trying: hint-0.4.2.1 (dependency of mueval-0.9.1.1)
next goal: ghc (dependency of hint-0.4.2.1)
rejecting: ghc-7.8.3/installed-4d8... (conflict: transformers==0.4.2.0, ghc =>
transformers==0.3.0.0/installed-16a...)
Backjump limit reached (change with --max-backjumps).

Note: when using a sandbox, all packages are required to have consistent
dependencies. Try reinstalling/unregistering the offending packages or
recreating the sandbox.
```

対策としては、pontarius-xmpp側を再度transformer 0.3に対応させるしかないのかなーと思ってる。
