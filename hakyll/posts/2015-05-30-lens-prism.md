---
title: 今日はLens&Prism勉強会の日です
---

[Lens&Prism勉強会](http://connpass.com/event/13929/)に途中から来ています。

## Lensの説明 / gakuzzzzさん

途中から。

* lensは部分から構成
* ekmett さん「`set l (set l s b) a == set l s b`が抜けてるよ」
* ネストされた設定の例
* `At` マップのキーバリューから値を取り出す
* `Iso`, `Prism`, `Lens` について、 `f`, `g` の比較
* `Optional` or `Travarsal`, Affine Traversal, 0-1 Traversal などの呼び方
    * `Prism` と `Lens`を合わせたもの
* `Index` と `At` の違い
    * 存在しないインデックスだと部分が取り出せない
* `Json` の例
    * `String` からの変換から始まってひたすらネストが必要
    * `parse`は`Prism`ではダメ。JSONの表記ゆれがあるから元に戻せない
        * `Optional` を使う
        * ekmettさんによると、表記ゆれを同値と見なすこともできるのであってるともあってないとも言える
    * `Lens`より`Optional`と`Prism`が使われてる
* 他に `Getter` とか `Setter` とかある
* Q. Scalaで使ってうれしいの？
    * そんなに頻繁にはない
    * 手で書くとそんなにコード短くならない。マクロ使えれば嬉しいかも
* Q. `ScalaZ`と`Monocle`とで`PLens`は違う
    * Partial LensとPolymorphic Lens
    * HaskellだとLensはレンズファミリー、`Lens'`がレンズ
    * ScalaのPartial LensはHaskellでは`Traversal`では(怪しげ)

## LensでHaskellをもっと格好良く！ / its_out_of_tune さん

* タプルの `set` `get` は普通めんどい → `lens`
* `^.` `_1` get , `_2` `.~` set, `&` (`flip ($)`)
* `makeLenses` Template Haskell
* lensの作り方
  * `Traversable` の `fmapDefault`, `over`, と `Setter`
  * `Data.Foldable` の`foldMap`と`foleMapOf`, `Getting`
  * `Setter` と `Getting` を `Functor` を使ってそろえる
* 便利な使い方
  * `%~` は `over`
  * `to` は関数適用。getterになる
  * `use` と `.=` は `MonadState` で使う

## Opticから見たLens/Prism / its_out_of_tune さん

* `Either` が入ると `Lens` ではきつい
* `^?` : `Prism` での値の取り出し
    * setterは一緒
    * `Monoid` の取り出しでは `mempty` があるので一緒
* `Prism` も合成可能。 `Lens` と合成すると `re` は使えない
* `MonadState` 内でも普通に使える
    * ただし、`use` はMonoidのみ。 `preuse`
    * `Int` は `Sum` を使えばモノイドになるよ！
* `Functor` いろいろ
    * `Contravariant` 反変。HomとかConstとか
    * `Bifunctor` 双関手
    * `Profunctor`
* `Optic` : `Lens` から `(->)` を抽象化
    * `Prism` も表現できる
    * `Optical` : `(->)` を 1 種類から 2 種類に増やしたもの
* ekemett/lens はすべて `Optic` 型で全て合成可能
    * 後はコンパイラお任せ
* `Equality` : `id` のみ
* `Iso ` : 同型。 `from` で逆にできる
* `Iso` から `Prism` と `Lens`
    * `Prism` から `Review` 、さらに `AReview` へ。 `unto`, `un`, `re`
    * `unto`, `un` → `Review` を作る
    * `re` → `Getter` を作る
* `Getting` は `Getter` 、`Setter`は`Settable`
* `Fold` は `Getter`と`Traversal` を強くしたもの
    * `(^..)`, `(^?)`
    * `Getting r s a` の `r` が `Monoid` なら `Fold`
* `Choice` と `Prism`
    * `Choice` は `Profunctor`。関数と`Tagged`
    * `Prism` は `prism` 関数で作る
* `Const r` は `Monoid` 制約がないと `Applicative` にならない
    * `pure` の定義に `mempty` 必要
* Q. 「準同型」の言葉が違う、 `Const r` の定義が実際と違う (`mappend` 使う)

## DERIVING LANSES / halcat0x15a さん

* Lensを手で作るのは辛い
* JavaでReflection
    * Java8でパラメータ名をReflectionで取れる
    * コンストラクタからパラメータ名を取ってゲッターの名前を作ってとる
    * (めっちゃ辛い)
* Scala のマクロによるlens
    * マクロ：ブラックボックスとホワイトボックス
    * →強力な方(ホワイトボックス)
    * フィールド名が存在しなくてもコンパイル時に弾かれる
    * 型安全かつ速い。ただしホワイトボックスマクロは将来なくなるかも
* HaskellのGeneric
    * `GHC.Generic`
    * `Generic` クラスはderiving可能
    * 名前の取り出し方がわからないので何番目のフィールドか
        * → 型レベル自然数が必要
    * 型安全、マクロ不要、遅い
* Q. `Deriving Generic` する？ → ライブラリとかよろしく使ってくれる。JSONとか
* Q. `lens` にも `Generic` あるよね？ → `Generic` に対する `ISO` があるだけでは
    * Genericのインスタンスについて `Traversal` にする[仕組みはある](http://hackage.haskell.org/package/lens-4.11/docs/Generics-Deriving-Lens.html)
    * この仕組みはフィールドを明示して `Lens` にしてる点が違う

## XPath in Lens / tanakh さん

* ブラウザを開かずにAsk.fmで質問したい
* `xml-conduit` でADT取り出して直接も書ける
* `Text.XML.Cursor` を使えばいい → パッケージごとにDSL覚えるのはちょっと
* `Text.XML.Lens` ： `..` とか `./` とかきついけど広く使われてる
* そして `Lens` 沼へ
* XPATHと `Lens` の対比表 → 結構違う
* 「無尽蔵に演算子が増える」
* CSSセレクターも使える
    * XPathよりナウい。「題材を間違えた感」
* `http-condit` と組み合わせると楽
* `aeson-lens` VS `lens-aeson`
    * 前者を tanakh さんが更新しないから ekmett さんが作ったのが後者
* Q. `xml-lens` の作者だけど何かある？
    * 属性があるかないか書きにくい
    * 足します
* Q. CSSセレクタからレンズを作る機能があるとすごい
    * 作ると面白いと思います
