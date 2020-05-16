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
    @branching_command = ''
    @branching_label = ''
    @function_command = ''
    @function_name = ''
    @n_args = 0
  end

  attr_reader :stack_command
  attr_reader :memory_segment
  attr_reader :memory_segment_index
  attr_reader :arithmetic_command
  attr_reader :logical_command
  attr_reader :branching_command
  attr_reader :branching_label

  def parse(vm_line)
    # Check for command type and parse
    vm_parts = vm_line.split(' ')
    if stack_commands.include?(vm_parts[0].to_sym)
      @command_type = :stack
      @stack_command = vm_parts[0].to_sym
      @memory_segment = vm_parts[1].to_sym
      @memory_segment_index = vm_parts[2].to_i
    elsif arithmetic_commands.include?(vm_parts[0].to_sym)
      @command_type = :arithmetic
      @arithmetic_command = vm_parts[0].to_sym
    elsif logical_commands.include?(vm_parts[0].to_sym)
      @command_type = :logical
      @logical_command = vm_parts[0].to_sym
    elsif branching_commands.include?(vm_parts[0].to_sym)
      @command_type = :branching
      @branching_command = vm_parts[0].to_sym
      @branching_label = vm_parts[1].to_sym
    elsif function_commands.include?(vm_parts[0].to_sym)
      @command_type = :function
      @function_command = vm_parts[0].to_sym
      if @function_command == :function || @function_command == :call
        @function_name = vm_parts[1].to_sym
        @n_args = vm_parts[2].to_i
      end
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

  def branching_commands
    %i[goto if-goto label]
  end

  def function_commands
    %i[call function return]
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
