# frozen_string_literal: true

require_relative 'parser.rb'
require_relative 'code.rb'
require_relative 'symbol_table.rb'

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
    puts 'Invalid argument: ' + file_name
    puts 'Please place input file in the hack_assembler directory'
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

    # Line with whitespace removed
    line = asm_file.readline
    line = line.split('//')[0]
    line = line.delete(' ')
    line = line.strip
    next if line == ''

    # Check for label ([label_name])
    if !line.index('(').nil? && line.index('(') < line.index(')')
      label = line.split('(')
      label = label[1]
      label = label.split(')')
      label = label[0]
      unless symbol_table.contains_symbol?(label)
        symbol_table.add_label(label, instructions.size)
      end
      next
    end

    # Line is neither whitespace nor a label, it is an instruction
    instructions.push(line)

  end

  # Second Pass - begin writing the file in Hack machine language
  parser = Parser.new(symbol_table)
  code = Code.new
  output_file = file_name.split('.')[0] + '.hack'
  hack_file = File.new(output_file, 'w')
  puts 'Writing file: ' + output_file
  instruction_number = 1
  instructions.each do |instruction|
    instruction = instruction.to_s
    parser.parse_instruction(instruction)
    if parser.instruction_type == 'A'

      # Process A-Instruction
      out_line = code.encode_op_code(parser.op_code) +
                 code.encode_a_value(parser.a_instruction_value)

    elsif parser.instruction_type == 'C'

      # Process C-Instruction
      out_line = code.encode_op_code(parser.op_code) +
                 '11' +
                 code.encode_c_comp(parser.c_instruction_comp) +
                 code.encode_c_dest(parser.c_instruction_dest) +
                 code.encode_c_jump(parser.c_instruction_jump)
    else
      puts 'Invalid instruction type: ' + parser.instruction_type
      puts 'Invalid instruction type occurred at instruction #' +
           instruction_number.to_s
    end
    instruction_number += 1
    hack_file.puts(out_line)
  end

  puts 'Successfully complete writing ' + output_file
end
