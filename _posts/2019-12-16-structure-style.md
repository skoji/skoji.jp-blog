---
layout: post
title: 構造とスタイルの分離に関する低レベルの話
date: '2019-12-16T19:46:12+09:00'
categories:
- ひとりアドベントカレンダー
- 休むに似たり
---

ドキュメントは、構造とスタイルが分離されているべきだ、といいます。Webであれば、HTMLに構造が、CSSにスタイルが、という分離がされています。が、完全に綺麗に分離するのは難しいことが多いと思っています。

そしてこのブログでは、元々そこまで考えていなかったのもあり、全然うまく行っていません。MovableTypeやWordPress時代の記事は、今のJekyllに引っ越す時点ではHTMLとして扱いました。CSSは過去のものは使わず、完全に新規に書き直しました。古い記事の見た目がおかしなことになっていることが割とあるのは、主にこのせいです。特に画像の扱いが曖昧です。少し前に画像は問答無用で中央配置するようにCSSを変えたのですが、よくないので近々直そうと思っています。いずれにしても、過去に渡って全ての記事で画像がちゃんと表示されるように、CSSだけでなんとかするのは絶望的です。何しろどういう意味合いの画像なのか、マークアップからはほとんど読み取れないので、構造にそったスタイルを定めることはできないからです。

Jekyllにした時点で`dl`タグのスタイルがリセットされていたせいで、過去記事でものすごく読みにくくなっていたものがあることにも、最近気付きました（これは修正済みです）。スタイルのリセット、やっぱりあんまりよくないね。

記事中のHTMLにインラインでスタイル指定されてるものは、今でも割とちゃんと表示されているものが多いです。構造とスタイルの分離とは。しかも`<font color="red">`なんてものがまだ生き残っています。