iseq = RubyVM::InstructionSequence.compile_file("#{ARGV[0]}")

puts iseq.disasm
