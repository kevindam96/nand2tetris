# frozen_string_literal: true

##
# This class is a parser for the VM translator.
# Its purpose is to parse a line of VM code and separate
# the line into its lexical parts
class Parser
  def initialize
    @command_type = ''
    @stack_command = ''
    @memory_segment = ''
    @memory_segment_index = 0
    @arithmetic_command = ''
    @logical_command = ''
  end

  attr_reader :stack_command
  attr_reader :memory_segment
  attr_reader :memory_segment_index
  attr_reader :arithmetic_command
  attr_reader :logical_command

  def parse(vm_line)
    # Remove whitespace
    vm_line = vm_line.strip
    vm_line = vm_line.split('//')[0]

    # Check for command type and parse
    vm_parts = vm_line.split(' ')
    if stack_commands.include?(vm_parts[0])
      @command_type = :stack
      @stack_command = vm_parts[0]
      @memory_segment = vm_parts[1]
      @memory_segment_index = vm_parts[2].to_i
    elsif arithmetic_commands.include?(vm_parts[0])
      @command_type = :arithmetic
      @arithmetic_command = command
    elsif logical_commands.include?(vm_parts[0])
      @command_type = :logical
      @logical_command = vm_parts[0]
    else
      puts 'Invalid VM command: ' + vm_parts[0]
    end
  end

  def command_types
    %i[stack arithmetic logical branching function]
  end

  def stack_commands
    %i[push pop]
  end

  def memory_segments
    %i[local argument this that constant static pointer temp]
  end

  def arithmetic_commands
    %i[add sub neg]
  end

  def logical_commands
    %i[eq gt lt and or not]
  end

  def stack_command?
    if @command_type.empty?
      false
    else
      @command_type == :stack
    end
  end

  def arithmetic_command?
    if @command_type.empty?
      false
    else
      @command_type == :arithmetic
    end
  end

  def logical_command?
    if @command_type.empty?
      false
    else
      @command_type == :logical
    end
  end

  def branching_command?
    if @command_type.empty?
      false
    else
      @command_type == :branching
    end
  end

  def function_command?
    if @command_type.empty?
      false
    else
      @command_type == :function
    end
  end

end