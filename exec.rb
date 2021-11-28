# rbin化したファイルを実行する
bin_iseq = File.binread("#{ARGV[0]}.cat.rbin")

iseq = RubyVM::InstructionSequence.load_from_binary(bin_iseq)

iseq.eval
