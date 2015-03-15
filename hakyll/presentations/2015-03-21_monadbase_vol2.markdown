---
title: モナモナ言うモナド変換子入門
author: hiratara
date: March 21, 2015
---

# 前回について

* [わかめのモナド浸し](http://connpass.com/event/1152/)
* [モナモナ言うモナド入門](http://www.slideshare.net/hiratara/ss-15209166)
    * 圏の基礎的な概念の定義
    * モノイダル圏の定義
    * モナドは自己関手圏のモノイド

# 今回の内容

* モノイド変換子
* [Monatron](https://hackage.haskell.org/package/Monatron) による lifting 

# monoidal 圏

[復習] $(\mathbb{C}, \otimes, I, \alpha, \lambda, \rho)$ がモノイダル圏とは、

* $\mathbb{C}$ 圏
* $\otimes : \mathbb{C} \times \mathbb{C} \to \mathbb{C}$ 双関手
* $I \in \mathbb{C}_0$
* $\alpha : - \otimes (- \otimes -) \Rightarrow (- \otimes -) \otimes -$ 自然同型
* $\lambda : I \otimes - \Rightarrow -$ 自然同型
* $\rho : - \otimes I \Rightarrow -$ 自然同型

# monoidal 圏

[復習] $(\mathbb{C}, \otimes, I, \alpha, \lambda, \rho)$ がモノイダル圏とは、

* $\lambda_I = \rho_I$
* $\alpha \circ \alpha = (\alpha \otimes \mathrm{id}) \circ \alpha \circ (\mathrm{id} \otimes \alpha)$
* $( \rho \otimes \mathrm{id} ) \circ \alpha = \mathrm{id} \otimes \lambda$

# monoid

[復習] モノイダル圏$\mathbb{C}$において、$(M, e, m)$ がモノイドとは、

* $M \in \mathbb{C}_0$
* $e : I \to M \in \mathbb{C}_1$
* $m : M \otimes M \to M \in \mathbb{C}_1$

# monoid

[復習] モノイダル圏$\mathbb{C}$において、$(M, e, m)$ がモノイドとは、

* $m \circ ( m \otimes \mathrm{id} ) \circ \alpha = m \circ ( \mathrm{id} \otimes m )$

* $m \circ ( e \otimes \mathrm{id} ) = \lambda$
* $\rho =m \circ ( \mathrm{id} \otimes e )$

# monoid 準同型

射$f : M \to M'$がモノイド$(M, e, m)$と$(M', e', m')$の間の準同型とは、

* $f \circ e = e'$
* $f \circ m = m' \circ (f \otimes f)$

# 例: 集合圏

直積を $\otimes$ としたモノイダル圏のモノイド準同型は、通常の意味のモノイド準同型となる。

* exercise

# 例:[mmorph](https://hackage.haskell.org/package/mmorph-1.0.4/docs/Control-Monad-Morph.html)

* 定義: `morph :: forall a . m a -> n a`
    * `morph . return = return`
    * `morph . (f >=> g) = morph . f >=> morph . g`
    * exercise: モノイド準同型の定義と同値か
* `lift :: Monad m => m a -> t m a`
    * `lift . return = return`
    * `lift (m >>= f) = lift m >>= (lift . f)`
    * exercise: `morph`の定義と同値か

# $\mathrm{Mon}(\mathbb{C})$

モノイドとモノイド準同型は圏を成す。

# monoid 変換子

モノイド変換子 $(T, \mathrm{lift})$とは、

* $T : \mathrm{Mon}(\mathbb{C})_0 \to \mathrm{Mon}(\mathbb{C})$ 関手
* $\mathrm{lift} : \mathrm{In} \Rightarrow T$ 自然変換

ただし、 $\mathrm{In} : \mathrm{Mon}(\mathbb{C})_0 \to \mathrm{Mon}(\mathbb{C})$ は埋め込み関手とする。

# monad 変換子

関手圏 $\mathbb{C}^\mathbb{C}$ において、関手の合成・自然変換の水平合成を$\otimes$ ととったモノイダル圏におけるモノイド変換子。

# monad 変換子

* monadから新しいmonadを作れる
* $T$は貧弱
    * 射関数がない関手
    * 継続モナドのための定義
* $\mathrm{lift}$は`return`と`bind`を保つ
* モナドの構造を保つだけではprogrammingでは不十分
    * モナド特有の操作の再利用が必要
    * `catchError :: m a -> (e -> m a) -> m a`

# H-operations

モノイダル圏 $\mathbb{C}$ において $op : HM \to M$ が H-operation であるとは、

* $M$ モノイド
* $H : \mathrm{Mon}(\mathbb{C}) \to \mathbb{C}$ 関手

# 例: `catchError`

ほとんどの操作はH-operationsを元に導出できる。

* $S - = - \times -^E$ とする
* $\mathrm{catchError'} : S \otimes M \to M$ is first-order
    * exercise: Check that it's not algebraic
* `catchError = curry catchError'`

# lifting

$\mathrm{op}^M : HM \to M$をH-operation、$h : M \to N$をモノイド準同型とする。$\mathrm{op}^N : HN \to N$ が以下を満たすとき、$\mathrm{op}^M$の$h$に沿った持ち上げであるという。

* $h \circ \mathrm{op}^M = \mathrm{op}^N \circ Hh$

# how to lift

| | 変換子 | 共変 | 関手的 | モノイダル |
| :---- | ----: | ----: | ----: | ----: |
H-operation | |  |  |  |
$\tiny{(S \otimes M) \otimes F \to M}$ | | | | M
first-order | | | C | C M
代数的 | A | A | A C | A C M

* A : Algebraic lifting
* C : Condensity lifting
* M : Monoidal lifting

# first-order

H-operation $\mathrm{op} : HM \to M$ がfirst-orderであるとは、

* $H - = S \otimes -$
* $S \in \mathbb{C}_0$ シグネチャ

# algebraic

H-operation $\mathrm{op} : HM \to M$ が代数的であるとは、

* $\mathrm{op}$ はfirst-order
* $m \circ (\mathrm{op} \otimes \mathrm{id}) \circ \alpha = \mathrm{op} \circ (\mathrm{id} \otimes m)$

# algebraic

代数的なoperation $\mathrm{op} : S \otimes M \to M$ と $S \to M$ という形のH-operationは一対一で対応している。

<!-- # covariant -->

<!-- モナド変換子 $(T, \mathrm{lift})$ が共変とは、 -->

<!-- * $T : \mathrm{Mon}(\mathbb{C}) \to \mathrm{Mon}(\mathbb{C})$ 関手 -->
<!-- * $\mathrm{lift} : \mathrm{Id} \Rightarrow T$ 自然変換 -->

<!-- # functorial -->

<!-- モナド変換子 $(T, \mathrm{lift})$ が関手的とは、 -->

<!-- * $(T, \mathrm{lift})$ が covariant -->
<!-- * $T : \mathbb{C} \to \mathbb{C}$ -->
<!-- * $U(\mathrm{lift}_M) = \mathrm{lift}_{UM}$ -->

<!-- # monoidal -->

<!-- モナド変換子 $(T, \mathrm{lift})$ がモノイダルとは、 -->

<!-- * $T : \mathbb{C} \to \mathbb{C}$ はモノイダル関手 -->
<!-- * $\mathrm{lift} : \mathrm{Id} \Rightarrow T$ はモノイダル自然変換 -->

<!-- # (lax) monoidal F -->

<!-- モノイダル圏 $(\mathbb{C}, \otimes, I, \alpha, \lambda, \rho)$と$(\mathbb{C}', \otimes', I', \alpha', \lambda', \rho')$ -->
<!-- について、$(F, \phi_I, \phi)$ がモノイダル関手とは、 -->

<!-- * $F: \mathbb{C} \to \mathbb{C}'$ -->
<!-- * $\phi_I : I' \to FI$ 射 -->
<!-- * $\phi : F- \otimes F- \Rightarrow F(- \otimes -)$ 自然変換 -->

<!-- # (lax) monoidal 関手 -->

<!-- モノイダル圏 $(\mathbb{C}, \otimes, I, \alpha, \lambda, \rho)$と$(\mathbb{C}', \otimes', I', \alpha', \lambda', \rho')$ -->
<!-- について、$(F, \phi_I, \phi)$ が(緩い)モノイダル関手とは、 -->

<!-- * $F\alpha \circ \phi \circ (\mathrm{id} \otimes' \phi) = \phi \circ (\phi \otimes' \mathrm{id}) \circ \alpha'$ -->
<!-- * $\lambda' = F\lambda \circ \phi \circ (\phi_I \otimes' \mathrm{id})$ -->
<!-- * $\rho' = F\rho \circ \phi \circ (\mathrm{id} \otimes' \phi_I)$ -->

<!-- # monoidal nat -->

<!-- モノイダル圏 $(\mathbb{C}, \otimes, I, \alpha, \lambda, \rho)$ と $(\mathbb{C}', \otimes', I', \alpha', \lambda', \rho')$ -->
<!-- の間のモノイダル関手 $(F, \phi_I, \phi)$ と $(F', \phi_I', \phi')$ に対して $\tau$ がモノイダル自然変換とは、 -->

<!-- * $\tau : F \Rightarrow F'$ -->
<!-- * $\phi_I' = \tau_I \circ \phi_I$ -->
<!-- * $\phi' \circ (\tau \otimes' \tau) = \tau \circ \phi$ -->

<!-- # Theorem -->

<!-- モノイド変換子 $(T, \mathrm{lift})$ がモノイダルであるとき、、以下で定義されるモノイド変換子 $(T', \mathrm{lift}')$ は関手的である。 -->

<!-- * $T' : (M, e, m) \mapsto (TM, Te \circ \phi_I, Tm \circ \phi)$ -->
<!-- * $\mathrm{lift}' = \mathrm{lift}$ -->

# algebraic lifting

$\mathrm{op}^M : S \otimes M \to M$ をalgebraic operation、 $h : M \to N$ をモノイド変換子とすると、$\mathrm{op}^N : S \otimes N \to N$ なる algebraic operation で $\mathrm{op}^M$ の $h$ に沿った持ち上げとなっているものが唯一存在する。

* $\mathrm{op}^N = m \circ ((h \circ \mathrm{op}^M \circ (S \otimes e) \circ \rho^{-1}) \otimes M)$

<!-- # condensity lifting -->

<!-- $\mathbb{C}$ をright closedなモノイダル圏とする。 -->

<!-- $\mathrm{op}^M : S \otimes M \to M$をfirst order operation、$(T, \mathrm{lift}^T)$をfunctorial モノイド変換子とする。このとき、$\mathrm{op}^M$ の $\mathrm{lift}^T_M$ に沿った持ち上げ$\mathrm{op}^{TM} : S \otimes TM \to TM$が存在する。 -->

<!-- # condensity lifting -->

<!-- * $\mathrm{op}^{TM} = T(\mathrm{down}^K_M) \circ op^{T(KM)} \circ (S \otimes T(\mathrm{lift}^K_M))$ -->
<!-- * ただし、 $(K, \mathrm{lift}^K)$ は condinsity モノイド変換子、$\mathrm{down}^K \circ \mathrm{lift}^K = \mathrm{id}$ -->
<!-- * また、$\mathrm{op}^{KM} = m^K \circ (\lambda(\mathrm{op}^M) \otimes M^M)$はalgebraic operationで、$\mathrm{op}^{T(KM)}$ はその $\mathrm{lift}^T$ に沿った lifting -->

<!-- # monoidal lifting -->

<!-- $(T, \phi_I, \phi, \mathrm{lift}^T)$をmonoidal transformer、$S, F \in \mathbb{C}_0$、$\mathrm{op}^M : S \otimes M \otimes F \to M$ をH-operationとする。このとき、 $\mathrm{lift}^T_M$ に沿った持ち上げ $\mathrm{op}^{TM} : S \otimes TM \otimes F \to TM$ が存在する。 -->

<!-- * $\mathrm{op}^{TM} = T(\mathrm{op}^M) \circ \phi_{S \otimes M, F} \circ (\phi_{S, M} \otimes \mathrm{lift}^T_F) \circ (\mathrm{lift}^T_M \otimes TM \otimes F)$ -->

# まとめ

* モナド変換子はモナド準同型の族
* operationの持ち上げは難しい


# 参考文献

* [Monad transformers](http://conway.rutgers.edu/~ccshan/wiki/blog/posts/Monad_transformers/), Chung-chieh Shan
    * 歴史がまとまっているエントリ
* “An Abstract View of Programming Languages”, Eugenio Moggi
    * モナド変換子とoperationの問題設定
* "Modular Monadic Semantics", Sheng Liang, Paul Hudak 
    * mtl式のadhocなlifting
* "Monad Transformers as Monoid Transformers", Mauro Jaskelio
    * モノイダル圏での議論は見通しが良い
    * モノイド変換子、は必要ないかも？
