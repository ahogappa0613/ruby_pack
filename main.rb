# ruby実行時からすでに読み込まれているファイルを記憶しておく
already_libs = $".dup
require ARGV[0]

# .soで読み込まれているので.bundleに変更する
lib_files = ($" - already_libs).grep(/.*\.so$/).map { _1.gsub(/\.so/, '.bundle') }
ruby_files = ($" - already_libs).grep(/.*\.rb$/)

# 読み込まれているrubyスクリプトを読み込んで一枚のスクリプトファイルにする
# 一部読み込まなくて良いものがあるのではじく
# 一枚のスクリプトファイルにするのでrequireは削除しておく
File.open("#{ARGV[0]}.cat.rb", 'w') do |file|
  file.print "# frozen_string_literal: true\n"
  ruby_files.each do
    next unless _1 =~ %r{^/.*\.rb$}

    prog = File.open(_1).read
    prog = prog.gsub(/^(\s*(require|require_relative)\s+('|").*('|"))$/, '')
    file.print "#{prog}\n"
  end
end

# 結合したrubyスクリプトをコンパイルしてファイルに書き出す
# 拡張子は適当
iseq = RubyVM::InstructionSequence.compile_file("#{ARGV[0]}.cat.rb")
bin_iseq = iseq.to_binary
File.binwrite("#{ARGV[0]}.cat.rbin", bin_iseq)

# erbを使ってrustのコードを生成する
require 'erb'
include_bytes_paths = lib_files.map { "include_bytes!(\"#{RbConfig::CONFIG['rubyarchdir']}/#{_1}\")" }
lib_names = lib_files.map { "\"#{_1}\"" }.map { _1.gsub(/\.bundle/, '') }.join(', ')
rbin_path = "#{ARGV[0]}.cat.rbin"

File.open('./src/main.rs', 'w') { _1.print(ERB.new(File.open('./main.rs.erb', 'r').read).result(binding)) }
