---
title: Pugs on stack
author: hiratara @ FreakOut!
date: August 21, 2015
---

# Do you know Pugs?

----

## What is "Pugs"?

* a <span style="color:#0F0;">Haskell</span>-based implementation of <span style="color:#0F0;">Perl6</span>
* "Perl6 User Golfing System"
* Contributes to the design of Perl6

----

## History of Pugs

* Started on 2005-2-1 by Audrey Tang
* YAPC::Asia 2006 Tokyo
    * Audrey Tang, "Introduction to Pugs"
* Was suddenly <span style="color:#f00;">unmaintained</span> in 2007
* [Feature comparison of Perl 6 compilers](http://perl6.org/compilers/features)
    * "not being actively maintained, many things are <span style="color:#f00;">broken</span>"

----

## Where is source codes?

* svn.pugscode.org was gone
* [google code](https://code.google.com/p/pugs/) r13820
* [svn.openfoundry.org](http://svn.openfoundry.org/pugs/src/) r16464 2007-5-21
* [CPAN](http://search.cpan.org/~audreyt/Perl6-Pugs-6.2.13/) 2006-10-17
* [hackage](https://hackage.haskell.org/package/Pugs), [github](https://github.com/perl6/Pugs.hs) 6.2.13.20130611

----

## pugs-6.2.13.20130611

* not a 6.28.x release but the latest <span style="color:#F00;">6.2.x</span>
* "the Pugs.hs project exists mainly for <span style="color:#F00;">historical/archival</span> purposes"
* Build with <span style="color:#F00;">ghc-7.6.3</span>
* You can install it by using <span style="color:#F00;">cabal</span>

----

## Improvement of Haskell

* 2013-4-21 ghc-7.6.3
* 2014-4-9 ghc-7.8.1
* 2014-4-12 ghc-7.8.2
* 2014-7-11 ghc-7.8.3
* 2014-12-23 ghc-7.8.4
* 2015-3-27 ghc-7.10.1
* 2015-7-29 ghc-7.10.2

----

## A lot of breaking changes

* ghc-7.8
    * <span style="color:#0F0;">Typeable</span> is now poly-kinded
    * user-written instances of <span style="color:#0F0;">Typeable</span> are now disallowed
    * Roles - Nominal, Representational, and Phantom
    * Some bugs of <span style="color:#0F0;">functional dependencies</span> are fixed
* ghc-7.10
    * Prelude are re-exported from <span style="color:#0F0;">more generic</span> modules
    * <span style="color:#0F0;">Applicative</span> typeclass becomes a superclass of <span style="color:#0F0;">Monad</span>

----

## Cabal isn't newbie friendly

* Strict versioning causes <span style="color:#F00;">dependency hell</span>
* You need to use <span style="color:#F00;">`cabal sandbox`</span>
* It takes <span style="color:#F00;">a long time</span> to install all dependenies

----

## stack 0.1

* An alternative of <span style="color:#F00;">`cabal-install`</span>
* Provide <span style="color:#0F0;">reproducible build</span>
* Fix versions of all packages by using [Stackage](https://www.stackage.org/)
* public beta quality

----

## Just write stack.yaml

```
packages:
- HsParrot/
- HsPerl5/
- HsSyck/
- MetaObject/
- Pugs/
- pugs-compat/
- pugs-DrIFT/
extra-deps:
- FindBin-0.0.5
- control-timeout-0.1.2
- stringtable-atom-0.0.7
resolver: lts-2.20
```

----

## Pugs-6.2.13.20150815

* Build with <span style="color:#0F0;">ghc-7.10.2</span>
* You can install it by using <span style="color:#0F0;">stack</span>

----

## You only have to do

Install <span style="color:#0F0;">`stack`</span> and <span style="color:#0F0;">`libperl-dev`</span>, <span style="color:#0F0;">`libtinfo-dev`</span>, then:

```
$ git clone git@github.com:perl6/Pugs.hs.git
$ cd Pugs.hs
$ stack build --install-ghc
$ stack exec -- pugs
```

----

## How is Pugs doing?

A popular Perl6 benchmark:

<img src="/images/yapc2015/p6-benchmark.png" height="480"></img>

----

## It's very slow

```
% time pugs -e 'my $i=0; for (1..5_000) { $i++ }; say $i'
5000
pugs  0.23s user 0.01s system 98% cpu 0.239 total
```

* Run as the <span style="color:#F00;">interpreter</span>
* All eveluation in <span style="color:#F00;">`Eval`</span> monad
* A stack of <span style="color:#F00;">Monad Transformers</span>

```haskell
newtype Eval a = EvalT ContT (EvalResult Val) (ReaderT Env SIO) (EvalResult a)
data EvalResult a
    = RNormal    !a
    | RException !Val
```

----

# 50ms or die

----

## CPS transformation of Monads

```haskell
newtype Eval a = EvalT ContT (EvalResult Val) (ReaderT Env SIO) (EvalResult a)
data EvalResult a
    = RNormal    !a
    | RException !Val
```

Unrolled Monad.


```haskell
newtype Eval a = Eval (Env -> (a -> SIO Val) -> (Val -> SIO Val) -> SIO Val)
newtype EvalResult a = RException Val
```

----

## Benchmarks

```
% time pugs -e 'my $i=0; for (1..5_000) { $i++ }; say $i'
5000
pugs  0.23s user 0.01s system 98% cpu 0.239 total
```

```
% time pugs-patched -e 'my $i=0; for (1..5_000) { $i++ }; say $i'
5000
pugs-patched  0.20s user 0.01s system 98% cpu 0.206 total
```

```
% time perl6 -e 'my $i=0; for (1..5_000) { $i++ }; say $i'
5000
perl6  0.22s user 0.03s system 98% cpu 0.259 total
```

----

## More Benchmarks

```
% time pugs -e 'my $i=0; for (1..10_000) { $i++ }; say $i'
10000
pugs  0.40s user 0.01s system 99% cpu 0.416 total
```

```
% time pugs-patched -e 'my $i=0; for (1..10_000) { $i++ }; say $i'
10000
pugs-patched  0.36s user 0.01s system 99% cpu 0.368 total
```

```
% time perl6 -e 'my $i=0; for (1..10_000) { $i++ }; say $i'
10000
perl6  0.23s user 0.03s system 99% cpu 0.263 total
```

----

# 50ms and died ...

----

## A reuse of Pugs

* An implementation of a language <span style="color:#0F0;">similar to Perl6</span>
* Presented at <span style="color:#0F0;">YAPC Asia 2010</span>
* It's called <span style="color:#0F0;">Werl</span>

----

## Werl specification

<img src="/images/yapc2015/werl5.png" width="480"></img>

----

# <span style="color:#0F0;">Wugs</span>

A reference implementations of <span style="color:#0F0;">Werl6</span>

----

## How to install Wugs

A reference implementations of Werl6

```
$ git clone git@github.com:hiratara/Pugs.hs.git
$ cd Pugs.hs
$ git checkout origin/wugs
$ stack build --install-ghc
$ stack exec -- wugs
```

----

```
% stack exec -- wugs
 __      __                         (W)erl 6
/  \    /  \__ __  ____  ______     (U)ser's
\   \/\/   /  |  \/ ___\/  ___/     (G)olfing
 \        /|  |  / /_/  >___ \      (S)ystem
  \__/\  / |____/\___  /____  >          Version: 6.2.13.dev
       \/       /_____/     \/   Copyright 2005-2015, The Wugs Contributors
--------------------------------------------------------------------

Welcome to Wugs -- Werl6 User's Golfing System
Type :h for help.

Loading Prelude... done.
wugs> wwwWw 1 .. 80 -> $wW { WWwwWW wwWWWW > .5 ?? 'W' !! 'w' }; wWWWw
WWWwwWWWwWwwwWwWwWWWWwWWWwwwwwwWwwWwwWWWwWWwwwwWWWwWWwWwWWwwWWwwwWwWwwwWwwwWWwWw
Bool::True
```

----

## Werl5 and Werl6

Werl5

```
Wwwww wwww_wwww {
      WWW $w_w = WWwWWW;
      WWW $w_ww = WWwWWW;
      wWW ($w_w >= $w_ww) {
            wwWwWWw $w_w;
      } WWwWW {
            wwWwWWw $w_ww;
      }
}

wwWwWww wwww_wwww(10,20),"\n";
```

----

## Werl5 and Werl6

<span span="color:#0F0;">Werl6</span> is more readable

```
Wwwww wwww_wwww (WWW $w_w, WWW $w_ww){
      wWW ($w_w >= $w_ww) {
            wwWwWWw $w_w;
      } WWwWW {
            wwWwWWw $w_ww;
      }
}

wWWWw wwww_wwww(10,20);
```

----

## Inside of <span style="color:#0f0">Wugs</span>

The map of reserved words

```
+werl6perl6 :: [(String, String)]
+werl6perl6 =
+  [ ("w", "m")
+  , ("W", "q")
+  , ("ww", "s")
+  , ("wW", "x")
+  , ("Ww", "y")
+  , ("WW", "do")
+  , ("www", "eq")
+  , ("wwW", "ge")
+  , ("wWw", "gt")
+  , ("wWW", "if")
+  , ("Www", "lc")
+  , ("WwW", "le")
+  , ("WWw", "lt")
+  , ("WWW", "my")
```

----

## Inside of <span style="color:#0f0">Wugs</span>

Parse both Perl6 and Werl6 reserved words

```
 symbol :: String -> RuleParser String
 -symbol s = try $ do
 +symbol s = case perl6ToWerl6 s of
 +  Nothing -> symbol' s
 +  Just w -> do ret <- symbol' s <|> symbol' w
 +               return $ case werl6ToPerl6 ret of
 +                 Nothing -> ret
 +                 Just p -> p
```

----

<font style="font-size:200px">`-O` $fun$ ☺</font>

<!--
# YAPC and Haskell

* [YAPC::Asia 2006 "Learning Haskell" Audrey Tang](http://tokyo.yapcasia.org/sessions/learning_haskell.html)
* [YAPC::NA 2009 "What Haskell did to my brain" nothingmuch](http://www.yapcna.org/yn2009/talk/1956)
* [YAPC::Europe 2011 "Perlude: a taste of haskell in perl" eiro](http://yapceurope.lv/ye2011/talk/3386)
* [YAPC::Europe 2015 "Is Haskell an Acceptable Perl?" osfameron](http://act.yapc.eu/ye2015/talk/6320)
-->
