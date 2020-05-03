# frozen_string_literal: true
require 'parser.rb'
require 'code.rb'
require 'symbol_table.rb'

##
# This class is the main class
# The purpose of the main class is to handle file input,
# file writing, and file output
class Main
  # Validate CL Argument
  if ARGV.empty?
    puts 'Too few arguments'
    exit
  elsif ARGV.size > 1
    puts 'Too many arguments'
    exit
  end
  file_name = ARGV[0]
  if file_name.split('.').size != 2
    puts 'Invalid argument' if ARGV[0].split('.').size != 2
    exit
  end
  if file_name.split('.')[1] != 'asm'
    puts 'Invalid file type'
    exit
  end

  # Try Opening File
  puts 'Opening file: ' + file_name
  asm_file = File.open(file_name, 'r')
  if asm_file.nil?
    puts 'Error opening file: ' + file_name
    exit
  end

  # First Pass - remove whitespace and populate symbol table
  instructions = []
  symbol_table = SymbolTable.new
  until asm_file.eof

    # Remove whitespace
    line = asm_file.readline
    line = line.split('//')[0]

    next if line == ''

    line = line.delete(' ')
    line = line.strip

    # Check for label ([label_name])
    if !line.index('(').nil? && line.index('(') < line.index(')')
      label = line.split('(')
      label = label.split(')')
      symbol_table[label] = instructions.size unless symbol_table.key?(label)
      next
    end

    # Line is neither whitespace nor a label, it is an instruction
    instructions += line

  end

  # Second Pass - begin writing the file in Hack machine language
  parser = Parser.new(symbol_table)
  code = Code.new
  output_file = file_name.split('.')[0]
  hack_file = File.new(output_file + '.hack', 'w')
  instructions.each do |instruction|
    if !instruction.index('@').nil?

      # Process A-Instruction
      parser.parse_a_instruction(instruction)
      hack_file.puts(code.encode_op_code(parser.op_code) +
                     code.encode_a_value(parser.a_instruction_value))

    else

      # Process C-Instruction
      parser.parse_c_instruction(instruction)
      hack_file.puts(code.encode_op_code(parser.op_code) + 
                     '11' +
                     code.encode_c_comp(parser.c_instruction_comp) +
                     code.encode_c_dest(parser.c_instruction_dest) +
                     code.encode_c_jump(parser.c_instruction_jump))

    end
  end
end
