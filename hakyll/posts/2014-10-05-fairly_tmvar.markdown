---
title: Haskellによる並列・並行プログラミングの10.9
---

公平性のある `TMVar` を実施しなさいというお題の[回答](https://github.com/hiratara/parconc-examples/commit/43f0be6ea3d39f6b277cb599f46cae1539ed0681)を書いたので簡単に解説。

例えば `putMVar` ですでに値が入っているとき、キューに `TVar` を突っ込んでおいてそのままブロックし、 `takeMVar` によって値が空になったら起こして欲しい。が、書籍にも書いてあるとおり、 `STM` モナドではブロックは `retry` なので、ブロックするとキューに `TVar` を突っ込んだってこともトランザクションの破棄によって捨てられてしまう。

そこで、`STM`モナドではキューに突っ込むところまでやり、ブロックする処理は戻り値の `IO` アクションに任せることにするとうまくいく。以下の部分だ。

```
putTMVar :: Show a => TMVar a -> a -> STM.STM (IO ())
...(snip)...
    Just _  -> do
      t' <- STM.newTVar (Just a)
      STM.writeTVar queue (qs ++ [t'])
      return $ do
        STM.atomically $ do
          tvar <- STM.readTVar t'
          case tvar of
           Nothing -> return ()
           Just _ -> STM.retry
        return ()
```

`t'`をキューに突っ込んだ後は、ブロックするための `IO` モナドを作っている。この `IO` 値内で `atomically` + `retry` させることでブロックを実現している。

型が変わったせいで、利用側も若干めんどくさくなるが、原則 `join` で `atomically` の戻り値を潰すだけで問題ない。

```
    join . STM.atomically $ putTMVar done 1
```

```
  n1 <- join . STM.atomically $ takeTMVar done
```

