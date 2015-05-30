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
