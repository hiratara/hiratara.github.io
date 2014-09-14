---
title: Haskellによる並列・並行プログラミングの4.2.1
---

> <a href="http://www.amazon.co.jp/Haskell%E3%81%AB%E3%82%88%E3%82%8B%E4%B8%A6%E5%88%97%E3%83%BB%E4%B8%A6%E8%A1%8C%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0-Simon-Marlow/dp/4873116899%3FSubscriptionId%3D15SMZCTB9V8NGR2TW082%26tag%3Ddays0aa-22%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D4873116899" target="_top">Haskellによる並列・並行プログラミング</a><br />Simon Marlow 山下 伸夫 <br /><a href="http://www.amazon.co.jp/Haskell%E3%81%AB%E3%82%88%E3%82%8B%E4%B8%A6%E5%88%97%E3%83%BB%E4%B8%A6%E8%A1%8C%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0-Simon-Marlow/dp/4873116899%3FSubscriptionId%3D15SMZCTB9V8NGR2TW082%26tag%3Ddays0aa-22%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D4873116899" target="_top"><img src="http://ecx.images-amazon.com/images/I/51R0ZMN-OJL._SL75_.jpg" border="0" alt="4873116899" /></a><br /><img src="http://www.assoc-amazon.jp/e/ir?t=days0aa-22&l=ur2&o=9" width="1" height="1" style="border: none;" alt="" />

こちらの演習問題の解答が [stackoverflow](http://stackoverflow.com/questions/24773130/parallel-haskell-rate-limiting-the-producer) とか [github](https://github.com/erantapaa/parconc-examples/commit/d2c657c516377c29bca2521452dbfbe966ef6ee4) に上がってるんだけど、間違えてそうなので[自分が書いたもの](https://github.com/hiratara/parconc-examples/commit/639abe2cad1fc3529313981ede51d5364126c115)を解説しておく。

問題の例を読むと、一回のforkで生産する要素数は200だけど、消費者側が100個目を消費したところで次のforkが走り始める必要があることがわかる。これがなかなか難しい。

まず簡単なところから。型は問題文で与えられているので、`streamFold`は自明である。`Fork`は`Cons`を持っているので、`fork`する以外は`Cons`と同じ事をやるだけでいい。

```haskell
streamFold :: (a -> b -> a) -> a -> Stream b -> Par a
streamFold fn !acc instrm = do
  ilst <- get instrm
  case ilst of
    Nil      -> return acc
    Cons h t -> streamFold fn (fn acc h) t
    Fork kick (Cons h t) -> fork kick >> streamFold fn (fn acc h) t
```

`streamFromList`は問題文よりchunkの大きさとforkするタイミングを渡せって言われてるので以下の型。

```haskell
type ForkSetting = (Int, Int)
streamFromList :: NFData a => [a] -> Par (Stream a)
streamFromList' :: NFData a => ForkSetting -> [a] -> Par (Stream a)
```

これにあわせて`loop`も型を変える必要がある。が、さらにもうひと工夫 `Maybe (IVar (IList a))` という引数が必要で、これは後述する。　

```haskell
loop :: (Int, Int) -> [a] -> IVar (IList a) -> Maybe (IVar (IList a)) -> Par ()
```
`loop` の通常時の動作は改修前と変わらない。`loop`の引数の変更にあわせてパラメータを適切に受け渡すだけである。ただし、追加したカウンタのデクリメントは必要である。　

```haskell
  loop _ [] var _ = put var Nil   -- <4>
  loop (n, k) (x:xs) var nVar = do      -- <5>
    tail <- new                         -- <6>
    put var (Cons x tail)               -- <7>
    loop (n - 1, k - 1) xs tail nVar    -- <8>
```

`n == 1` のときも簡単。これは指定された数のチャンクを生産し終わった時なので、再帰を停止すればよい。ただ、再帰をやめるのにあたり、新しい`IVar`をここで生成してしまうと、この`IVar`へ値を`put`してくれるワーカーがどこにもいなくなってしまう。そこで前述した `loop` へ追加した最後の引数を使う。

```haskell
  loop (1, _) (x:_) var (Just next) = put var (Cons x next)
```

この `next` は、次のchunkの生産時に結果を `put` する `Stream` の先頭要素である。なので、消費者側はこの `next` を `get` することで続きのデータが得られる。

`k == 0` の時が次のchunkの生産を `fork` すべきときで、ここで `loop` の最後の引数も作る必要がある。あと、 `Fork` は `Cons` も兼ねているので、通常の `Cons` を生成する場合の処理も必要となる。 `nVar` が次のchunkの結果を含む`Stream`の先頭で、これを `loop` で引き回して今のchunkの生産が終わったら `nVar` へ繋げてやる。`fork`する際、現在のワーカーが残り `n - 1` 個の生産をする予定のはずなので、それらは `drop` でリストから捨ててやる。

```haskell
  loop (n, 0) (x:xs) var Nothing = do
    tail <- new
    nVar <- new
    put var (Fork (kick (drop (n - 1) xs) nVar)
                  (Cons x tail))
    loop (n - 1, -1) xs tail (Just nVar)

  kick xs var = loop (chunkSize, forkPoint) xs var Nothing
```

ここまでできてしまえば、 `streamMap` は生産者と消費者の両方の役割を兼ねるだけなのでさくっと実装できるかと思うが、実はそうはいかない。 `streamFromList` はlistを相手にしていたために `Fork` を消費者へ渡す時点で次のchunkがどの要素から生成を始めればよいかがわかったが、言語今回は入力が `Stream` なので上流からの値を `chunkSize` 個すべて受け取るまでは次のchunkの対象とすべき要素が確定しない。

この問題を解決するには、 `loop` の最後の引数を `Maybe (IVar (IVar (IList a), IVar (IList b)))` というように入れ個の `IVar` に変えてやるとよい。そして、現在のforkが`chunkSize`個のデータの生産を終えた時点で、次のforkに対して入力と出力の2つの `Stream` を表す `IVar` を伝えてやればよい。

`Fork`を要求する側は、だいたいこうなる(`Nil` は再帰を終えるので自明、`Fork`を消費する部分は`Cons`の消費と同じなので、それぞれ省略している)。次のchunkの入出力の先頭を表す`Stream`を受け取るために `nextstrm` という `IVar` を生成し、これを `loop` の引数としてchunkの末尾まで引き回している。chunkの末尾までいって対象となる `Stream` が確定した時点で、`(instrm, outstrm) <- get var` と結果を受け取って次のchunkの処理を開始する。

```haskell
  loop (n, 0) instrm outstrm Nothing = do
    ilst <- get instrm
    case ilst of
...(snip)...
      Cons h t -> do
        newtl <- new
        nextstrm <- new
        put outstrm (Fork (kick' nextstrm)
                          (Cons (fn h) newtl))
        loop (n - 1, -1) t newtl (Just nextstrm)
...(snip)...

  kick instrm outstrm = loop (chunkSize, forkPoint) instrm outstrm Nothing
  kick' var = do
    (instrm, outstrm) <- get var
    kick instrm outstrm
```

chunkの末尾でやることは、だいたい以下の通り。次のchunkの入力の先頭である `tail` がここで確定し、また、出力を書き込むために `newtl` という新たな `Stream` を生成し、 `loop` の末尾の引数を使って次のchunkにそれらを伝えると共に、消費者には続きを得るために `newtl` を返している。

```haskell
  loop (1, _) instrm outstrm (Just next) = do
    ilst <- get instrm
    case ilst of
...(snip)...
      Cons h tail -> do
        newtl <- new
        put next (tail, newtl)
        put outstrm (Cons (fn h) newtl)
...(snip)...
```

完全な実装は[githubの方](https://github.com/hiratara/parconc-examples/commit/639abe2cad1fc3529313981ede51d5364126c115)を参照して欲しい。ただし、面倒だったので本に載っていない `streamFilter` の方は改修していないので使えない(`fork`しないので最初のchunkで止まる)。
