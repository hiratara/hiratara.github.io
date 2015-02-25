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

# 今回のアジェンダ

* モナド変換子とは $T : \left| \mathrm{Mon}(\mathrm{Hask}^{\mathrm{Hask}}) \right| \to \mathrm{Mon}(\mathrm{Hask}^{\mathrm{Hask}})$ なる関手と、埋め込み関手 $\mathrm{In}$ について $\mathrm{lift}^T : \mathrm{In} \Rightarrow T$ なる自然変換
* プログラムにおいては各モナドにおける操作の持ち上げが重要な関心ごと

# モノイダル圏

[復習] $(\mathbb{C}, \otimes, I, \alpha, \lambda, \rho)$ がモノイダル圏とは、

* $\mathbb{C}$ category
* $\otimes : \mathbb{C} \times \mathbb{C} \to \mathbb{C}$  bifunctor
* $I \in \mathbb{C}_0$
* $\alpha : - \otimes (- \otimes -) \to (- \otimes -) \otimes -$ nat
* $\lambda : I \otimes - \to -$ nat
* $\rho : - \otimes I \to -$ nat

# モノイダル圏

[復習] $(\mathbb{C}, \otimes, I, \alpha, \lambda, \rho)$ がモノイダル圏とは、

* $\lambda_I = \rho_I$
* $\alpha \circ \alpha = (\alpha \otimes \mathrm{id}) \circ \alpha \circ (\mathrm{id} \otimes \alpha)$
* $( \rho \otimes \mathrm{id} ) \circ \alpha = \mathrm{id} \otimes \lambda$

# モノイド

[復習] モノイダル圏$\mathbb{C}$において、$(M, e, m)$ がモノイドとは、

* $M \in \mathbb{C}_0$
* $e : I \to M \in \mathbb{C}_1$
* $m : M \otimes M \to M \in \mathbb{C}_1$

# モノイド

[復習] モノイダル圏$\mathbb{C}$において、$(M, e, m)$ がモノイドとは、

* $m \circ ( m \otimes \mathrm{id} ) \circ \alpha = m \circ ( \mathrm{id} \otimes m )$

* $m \circ ( e \otimes \mathrm{id} ) = \lambda$
* $\rho =m \circ ( \mathrm{id} \otimes e )$

# モノイド準同型

射$f : M \to M'$がモノイド$(M, e, m)$と$(M', e', m')$の間の準同型とは、

* $f \circ e = e'$
* $f \circ m = m' \circ (f \otimes f)$

# 例:通常の意味のモノイド

* exercise

# 例:[mmorph](https://hackage.haskell.org/package/mmorph-1.0.4/docs/Control-Monad-Morph.html)

* Definition: `morph :: forall a . m a -> n a`
    * `morph . return = return`
    * `morph . (f >=> g) = morph . f >=> morph . g`
    * exercise: monoid morphism?
* `lift :: Monad m => m a -> t m a`
    * `lift . return = return`
    * `lift (m >>= f) = lift m >>= (lift . f)`

# $\mathrm{Mon}(\mathbb{C})$

モノイドとモノイド準同型は圏を成す。

# まとめ

* 
* 

