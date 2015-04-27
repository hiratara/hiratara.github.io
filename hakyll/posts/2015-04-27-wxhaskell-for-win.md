---
title: WxHaskellをWindows 8.1でビルドする
---

WxHaskellをSurface Pro 3上でビルドした。 [公式のwiki](https://wiki.haskell.org/WxHaskell/Windows) に従うべきだが、ハマったところを書いておく。

## Haskell Platform の導入

以前にインストールしたものを使ったので割愛。2014.2.0.0を利用。

## MinGW と msys の導入

こちらも以前にインストールしたものを使ったので割愛。 `sh.exe` を利用するためにmsysまで導入しておく必要がある。

## wxWidgets のビルド

[wxWidgetsのダウンロードページ](https://www.wxwidgets.org/downloads/) のWindows Installerを使ってソースコードを用意した。これをMinGWでビルドするのだけど、ポイントはHaskell Platformに付属する `gcc` でビルドすること。原則公式のWikiに従えばいいのだけど、PATHが結構違ったりするので確認しながら作業したい。こちらの環境では以下のようにコマンドを実行した。

```
C:\wxWidgets-3.0.2\build\msw> Set HASKELL_COMPILER_DIR=C:\Program Files\Haskell Platform\2014.2.0.0
C:\wxWidgets-3.0.2\build\msw> Set PATH=%HASKELL_COMPILER_DIR%\mingw\libexec\gcc\mingw32\4.8.1\;%HASKELL_COMPILER_DIR%\lib\extralibs\bin;%HASKELL_COMPILER_DIR%\bin;%HASKELL_COMPILER_DIR%\mingw\bin;C:\MinGW\msys\1.0\bin
C:\wxWidgets-3.0.2\build\msw> Set LIBRARY_PATH=%HASKELL_COMPILER_DIR%\mingw\lib;%HASKELL_COMPILER_DIR%\mingw\lib\gcc\mingw32\4.8.1
C:\wxWidgets-3.0.2\build\msw> sh -c "C:/MinGW/bin/mingw32-make.exe  -j -f makefile.gcc clean"
C:\wxWidgets-3.0.2\build\msw> sh -c "C:/MinGW/bin/mingw32-make.exe  -j -f makefile.gcc all"
```

ここでハマったのが `cmd.exe` とシェルでの `"` の振舞の違い。 `%PATH%` などを `Set` する際にスペース入りのパスを `"` で包んで補完してくる癖にこれらの環境変数には `"` が入ってはいけないっぽい。が、シェルでは逆に空白スペース入りのパスをうまく使えないようだったので、シェルから呼ぶ `mingw32-make.exe` は明示的に指定した。この辺はなにかWindowsやMinGWの流儀に沿ってないことをやってる気もしつつ、とりあえずwxWidgetsのビルドは完了。

## wx-config.exe の準備

公式ページで指示されたURLからDLするだけ。PATHが通ってるとこに置くのだけど、後述する `git clone` した `wxHaskell` フォルダの中に放り込んでおけば十分。もしくは `.cabal-sandbox\bin` に PATH を通してそこに置くか。

## wxHaskell のビルド

言われるままに `git` でソースコードをとってきてビルドした。ディレクトリは適当なとこに移った上で、以下のような感じ。公式ページでは男らしくグローバルに突っ込む手順になっているが、恐ろしすぎるので `cabal sandbox` 利用した。

```
...> git clone https://github.com/wxHaskell/wxHaskell.git
...> Cd wxHaskell
...> Set WXCFG=gcc_dll\mswu
...> Set CPLUS_INCLUDE_PATH=%HASKELL_COMPILER_DIR%\mingw\lib\gcc\mingw32\4.8.1\include\c++;%WXWIN%\include
...> Set LIBRARY_PATH=%WXWIN%\lib\gcc_lib;%HASKELL_COMPILER_DIR%\mingw\lib\
...> cabal sandbox init
...> cabal install .\wxdirect
...> cabal install .\wxc
...> cabal install .\wxcore
...> cabal install .\wx
```

## サンプルの実行

サンドボックスを使ったのでそれを `ghc` に教える必要がある。後、各種 `.dll` があるディレクトリを PATH に入れる必要がある。

```
...> ghc -package-db .cabal-sandbox\x86_64-windows-ghc-7.8.3-packages.conf.d samples\wxcore\BouncingBalls.hs
...> Set PATH=c:\wxWidgets-3.0.2\lib\gcc_dll\;.cabal-sandbox\x86_64-windows-ghc-7.8.3\wxc-0.92.0.0;%HASKELL_COMPILER_DIR%\mingw\bin;
...> samples\wxcore\BouncingBalls.exe
```

![BouncingBalls.exe](/images/2015-04-27-bouncing-balls.png)
