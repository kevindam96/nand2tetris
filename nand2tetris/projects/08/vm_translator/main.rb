# frozen_string_literal: true

require 'pathname'
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

  # Check if directory or .vm file
  vm_file_names = []
  if ARGV.size != 1
    puts 'Invalid argument: ' + file_name
    puts 'Proper usage is: ruby main.rb file_directory\file.vm'
    puts 'OR'
    puts 'ruby main.rb file_directory'
    puts 'where the parent directory of file_directory is vm_translator'
    exit
  end
  cl_arg = ARGV[0]
  if cl_arg.include?('.') && !cl_arg.include?('.vm')
    puts 'Invalid file type'
    puts 'Proper usage is: ruby main.rb file_directory\file.vm'
    puts 'OR'
    puts 'ruby main.rb file_directory'
    puts 'where the parent directory of file_directory is vm_translator'
    exit
  elsif cl_arg.include?('.vm')
    is_file = true
    output_file = cl_arg.sub('.vm', '.asm')
    asm_file = File.new(output_file, 'w')
    vm_file_names.push(cl_arg)
  else
    is_file = false
    output_file = cl_arg.to_s + '.asm'
    asm_file = File.new(output_file, 'w')
    Dir.foreach('./' + cl_arg) do |file_name|
      vm_file_names.push(file_name) if file_name.include?('.vm')
    end
  end

  CodeWriter.bootstrap.each do |asm_line|
    asm_file.puts(asm_line)
  end

  calls_of_fn_count = Hash.new
  vm_file_names.each do |file_name|
    # Try Opening File
    puts 'Opening file: ' + file_name
    if is_file
      vm_file = File.open(file_name, 'r')
    else
      vm_file = File.open('./' + cl_arg.to_s + '/' + file_name, 'r')
    end
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
    code_writer = CodeWriter.new(output_file.split('.')[0], file_name.split('.')[0], calls_of_fn_count)
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
    calls_of_fn_count = code_writer.calls_of_fn_count
  end
  puts 'Successfully complete writing ' + output_file
end
