# frozen_string_literal: true

require_relative 'parser.rb'
require_relative 'code_writer.rb'

##
# This is the main class for the VM translator.
# Its purpose is to handle input/output
# Input: file_name.vm := a program written in the VM language
# Output: file_name.asm := a program written in the Hack assembly language
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
  if file_name.split('.')[1] != 'vm'
    puts 'Invalid file type'
    exit
  end

  # Try Opening File
  puts 'Opening file: ' + file_name
  vm_file = File.open(file_name, 'r')
  if vm_file.nil?
    puts 'Error opening file: ' + file_name
    exit
  end

  # First Pass - remove whitespace and populate symbol table
  vm_lines = []
  until vm_file.eof

    # Line with whitespace removed
    line = vm_file.readline
    line = line.split('//')[0]
    line = line.strip
    next if line == ''

    # Line is a line of VM w/ whitespace removed
    vm_lines.push(line)

  end

  # Second Pass - begin writing from VM language to
  # Hack symbolic assembly language
  parser = Parser.new
  code_writer = CodeWriter.new(file_name.split('.')[0])
  output_file = file_name.split('.')[0] + '.asm'
  asm_file = File.new(output_file, 'w')
  puts 'Writing file: ' + output_file
  vm_lines.each do |vm_line|
    vm_line = vm_line.to_s
    parser.parse(vm_line)
    if parser.stack_command?
      code_writer.write_stack_command(parser.stack_command,
                                      parser.memory_segment,
                                      parser.memory_segment_index)
    elsif parser.arithmetic_command?
      code_writer.write_arithmetic_command(parser.arithmetic_command)
    elsif parser.logical_command?
      code_writer.write_logical_command(parser.logical_command)
    elsif parser.branching_command?
      code_writer.write_branching_command(parser.branching_command,
                                          parser.branching_label)
    elsif parser.function_command?
      code_writer.write_function_command(parser.function_command,
                                         parser.function_name,
                                         parser.n_args)
    else
      raise('Invalid VM command: ' + vm_line)
    end
    code_writer.asm_lines.each do |asm_line|
      asm_file.puts(asm_line)
    end
  end

  puts 'Successfully complete writing ' + output_file
end
