---
title: 4/10の読書メモ:続微分積分読本
mathjax: on
---

> <a href="http://www.amazon.co.jp/%E7%B6%9A-%E5%BE%AE%E5%88%86%E7%A9%8D%E5%88%86%E8%AA%AD%E6%9C%AC-%E5%A4%9A%E5%A4%89%E6%95%B0-%E5%B0%8F%E6%9E%97-%E6%98%AD%E4%B8%83/dp/4785315261%3FSubscriptionId%3D15SMZCTB9V8NGR2TW082%26tag%3Ddays0aa-22%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D4785315261" target="_top">続 微分積分読本 -多変数-</a><br />小林 昭七 <br /><a href="http://www.amazon.co.jp/%E7%B6%9A-%E5%BE%AE%E5%88%86%E7%A9%8D%E5%88%86%E8%AA%AD%E6%9C%AC-%E5%A4%9A%E5%A4%89%E6%95%B0-%E5%B0%8F%E6%9E%97-%E6%98%AD%E4%B8%83/dp/4785315261%3FSubscriptionId%3D15SMZCTB9V8NGR2TW082%26tag%3Ddays0aa-22%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D4785315261" target="_top"><img src="http://ecx.images-amazon.com/images/I/4150MMH4WHL._SL75_.jpg" border="0" alt="4785315261" /></a><br /><img src="http://www.assoc-amazon.jp/e/ir?t=days0aa-22&l=ur2&o=9" width="1" height="1" style="border: none;" alt="" />

## p.19 平均値定理

２変数の場合、合成関数の微分と同様に$f_x$か$f_y$の連続を仮定する必要が出てくる。この辺は、$f_x$によって$x$についての性質は捉えられるが、$y$についての性質は捉えられないってことかなと思う。驚くべきはむしろ$f_x$と$f_y$の片方の連続を仮定するだけでいいことだが、これはある点を基準とした時に$x$か$y$のどちらか片方の向きについてはもう片方の変数を全く動かさなくて住む、つまり１変数に帰着できるからかなと思う。証明を見ても、

$$
\begin{align}
  &  f(a + \Delta x, b + \Delta y) - f(a, b) \\
  &= f(a + \Delta x, b + \Delta y) - f(a, b + \Delta y) + f(a, b + \Delta y) - f(a, b)
\end{align}
$$

という変形を使っていて、ここで最初の2項には固定したい$y$側に$\Delta y$がいるので、$x$軸方向だけで議論を進めることができない。他方、最後の2項は$y$方向にしか変化させないので1変数の条件によって各種定理が適用できる。