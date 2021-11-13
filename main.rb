require 'erb'
$path = []
iseq_patch = Module.new do
  def load_iseq(fname)
    # RubyVM::InstructionSequence.compile('nil')
    $path << fname
    nil
  end
end
RubyVM::InstructionSequence.singleton_class.prepend(iseq_patch)

require ARGV[0]

paths = $".grep(/.*\.bundle/) + ($" & $path)

# p paths
@libs = []
File.open("#{ARGV[0]}.cat.rb", 'w') do |file|
  @libs = paths.map do |path|
    next path if path =~ /.*\.bundle$/
    next nil if path =~ /.*\.so$/
    next nil if path =~ /thread.rb/

    p path
    prog = File.open(path).read
    prog = prog.gsub(/(\s*require\s*('|").*('|")|require_relative).*/, '')
    file.print prog
    nil
  end.compact!
end

iseq = RubyVM::InstructionSequence.compile_file("#{ARGV[0]}.cat.rb")

bin_iseq = iseq.to_binary

File.binwrite("#{ARGV[0]}.cat.rbin", bin_iseq)

p @libs
file = File.open('./src/main.rs', 'r')
src = file.read
lib_files = @libs.map do |name|
  "include_bytes!(\"#{name}\"),"
end.join
src.gsub!(/static mut FILES: Lazy<Vec<&\[u8\]>>.*/,
          "static mut FILES: Lazy<Vec<&\[u8\]>> = Lazy::new\(\|\| { vec!\[#{lib_files}\]}\);\n")
src.gsub!(/let loaded_lib_names = vec!\[.*\];\n/, "let loaded_lib_names = vec!#{@libs};\n")
src.gsub!(/let file = include_bytes!\(.*\);\n/,
          "let file = include_bytes!(\"#{File.expand_path("#{ARGV[0]}.cat.rbin")}\");\n")
file = File.open('./src/main.rs', 'w')
file.write(src)
file.close
