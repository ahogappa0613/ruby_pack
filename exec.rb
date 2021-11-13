bin_iseq = File.binread('./csv.rb.cat.rbin')

iseq = RubyVM::InstructionSequence.load_from_binary(bin_iseq)

iseq.eval
