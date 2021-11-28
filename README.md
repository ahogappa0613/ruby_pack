# これは何？
Qiita アドベントカレンダー2021で紹介した記事で使ったコードです

# 使い方
前提として`rubyの静的ライブラリ`が必要です

シンプルに試したい時は
```sh
ruby main.rb ./csv.rb
```
と実行すると
* `./csv.rb`の結合ファイル
* 結合ファイルを`RubyVM::InstructionSequence`に変換したもの

が生成されます

この状態で、`cargo rustc -- -C link-dead-code=on`としてbuildすると実行ファイルが作られます
