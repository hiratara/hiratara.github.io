---
title: 読書メモ: 続微分積分読本
mathjax: on
---

> <a href="http://www.amazon.co.jp/%E7%B6%9A-%E5%BE%AE%E5%88%86%E7%A9%8D%E5%88%86%E8%AA%AD%E6%9C%AC-%E5%A4%9A%E5%A4%89%E6%95%B0-%E5%B0%8F%E6%9E%97-%E6%98%AD%E4%B8%83/dp/4785315261%3FSubscriptionId%3D15SMZCTB9V8NGR2TW082%26tag%3Ddays0aa-22%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D4785315261" target="_top">続 微分積分読本 -多変数-</a><br />小林 昭七 <br /><a href="http://www.amazon.co.jp/%E7%B6%9A-%E5%BE%AE%E5%88%86%E7%A9%8D%E5%88%86%E8%AA%AD%E6%9C%AC-%E5%A4%9A%E5%A4%89%E6%95%B0-%E5%B0%8F%E6%9E%97-%E6%98%AD%E4%B8%83/dp/4785315261%3FSubscriptionId%3D15SMZCTB9V8NGR2TW082%26tag%3Ddays0aa-22%26linkCode%3Dxm2%26camp%3D2025%26creative%3D165953%26creativeASIN%3D4785315261" target="_top"><img src="http://ecx.images-amazon.com/images/I/4150MMH4WHL._SL75_.jpg" border="0" alt="4785315261" /></a><br /><img src="http://www.assoc-amazon.jp/e/ir?t=days0aa-22&l=ur2&o=9" width="1" height="1" style="border: none;" alt="" />

## p.12 偏微分の存在と連続性

1変数関数の場合微分が存在すれば連続であると言えるが、２変数関数の場合微分ができるからと言って連続とは限らない。定理1によると、$f_x(x, y)$か$f_y(x, y)$のどちらかが有界であれば連続となる。

有界の条件は$f_x(a, b + \Delta y)$を抑えこむのに使うので、変数が増えると有界であるべき偏微分の個数は増える気がする(要出典)。

## p.15 方向微分

$\boldsymbol{v}$ の方向への微分を $(D_\boldsymbol{v}f)(a,b)$ で表す。

## p.16 全微分

初めて腑に落ちる全微分の解説を見た気がする。全微分を以下のように4変数関数で定義する。

$$
df(x, y, \xi, \eta) = f_x(x, y) \xi + f_y(x,y) \eta
$$

この定義の元で、以下が言える。

$$
\begin{align}
  dx(x, y, \xi, \eta) &= \xi \hspace{4em} \because f(x, y) = x の時 f_x(x, y) = 1, f_y(x, y) = 0 \\
  dy(x, y, \xi, \eta) &= \eta
\end{align}
$$

これを用いて定義を書き直してさらに引数を省略すれば、よく見る以下の記法にたどり着く。

$$
df = f_x dx + f_y dy
$$

積の全微分は、1変数の微分の積の公式から導出できる。

$$
\begin{align}
  d(fg) &= (fg)_x dx + (fg)_y dy                     \\
        &= (f_x g + f g_x) dx + (f_y g + f g_y) dy   \\
        &= g (f_x dx + f_y dy) + f (g_x dx + g_y dy) \\
        &= g\,df + f\,dg
\end{align}
$$