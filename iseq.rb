iseq = RubyVM::InstructionSequence.compile_file((ARGV[0]).to_s)

puts iseq.disasm
