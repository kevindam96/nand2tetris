# frozen_string_literal: true

##
# This class is a code writer for the VM translator.
# Its purpose is to take the fields from the parser and
# output the command to an array of lines in Hack
# Assembly Language
class CodeWriter
  def initialize(file_name)
    @asm_lines = []
    @file_name = file_name
  end

  attr_reader :asm_lines

  def initialize_labels
    lines = []
    lines.push('(EQ)')
    write_set_binary_true(lines)
    lines.push('(GT)')
    write_set_binary_true(lines)
    lines.push('(LT)')
    write_set_binary_true(lines)
    lines
  end

  def write_stack_command(command, memory_segment, memory_segment_index)
    @asm_lines = []
    @asm_lines.push('// ' + command.to_s + ' ' + memory_segment.to_s + ' ' +
                    memory_segment_index.to_s)
    case command.to_sym
    when :push
      write_push_command(memory_segment, memory_segment_index)
    when :pop
      write_pop_command(memory_segment, memory_segment_index)
    else
      raise('Invalid stack command: ' + command.to_s + ' ' +
             memory_segment.to_s + ' ' + memory_segment_index.to_s)
    end
  end

  def write_arithmetic_command(command)
    @asm_lines = []
    @asm_lines.push('// ' + command.to_s)
    case command.to_sym
    when :add
      write_add_command
    when :sub
      write_sub_command
    when :neg
      write_neg_command
    else
      raise('Invalid arithmetic command: ' + command.to_s)
    end
  end

  def write_logical_command(command)
    @asm_lines = []
    @asm_lines.push('// ' + command.to_s)
    case command.to_sym
    when :eq
      write_eq_command
    when :gt
      write_gt_command
    when :lt
      write_lt_command
    when :and
      write_and_command
    when :or
      write_or_command
    when :not
      write_not_command
    else
      raise('Invalid logical command: ' + command.to_s)
    end
  end

  private

  def write_push_command(memory_segment, memory_segment_index)
    case memory_segment.to_sym
    when :local
      write_push_local(memory_segment_index)
    when :argument
      write_push_argument(memory_segment_index)
    when :this
      write_push_this(memory_segment_index)
    when :that
      write_push_that(memory_segment_index)
    when :constant
      write_push_constant(memory_segment_index)
    when :static
      write_push_static(memory_segment_index)
    when :pointer
      write_push_pointer(memory_segment_index)
    when :temp
      write_push_temp(memory_segment_index)
    else
      raise('Invalid memory segment: ' + memory_segment.to_s)
    end
  end

  def write_push_constant(memory_segment_index)
    @asm_lines.push('@' + memory_segment_index.to_s)
    @asm_lines.push('D=A')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M+1')
  end

  def write_push_local(memory_segment_index)
    @asm_lines.push('@LCL')
    write_push_to_stack(memory_segment_index)
  end

  def write_push_argument(memory_segment_index)
    @asm_lines.push('@ARG')
    write_push_to_stack(memory_segment_index)
  end

  def write_push_this(memory_segment_index)
    @asm_lines.push('@THIS')
    write_push_to_stack(memory_segment_index)
  end

  def write_push_that(memory_segment_index)
    @asm_lines.push('@THAT')
    write_push_to_stack(memory_segment_index)
  end

  def write_push_static(memory_segment_index)
    @asm_lines.push('@' + @file_name + '.' + memory_segment_index.to_s)
    write_push_to_stack(memory_segment_index)
  end

  def write_push_pointer(memory_segment_index)
    if memory_segment_index.zero?
      @asm_lines.push('@THIS')
    elsif memory_segment_index == 1
      @asm_lines.push('@THAT')
    else
      raise('Invalid pointer for push pointer command: ' +
            memory_segment_index.to_s)
    end
    @asm_lines.push('A=M')
    @asm_lines.push('D=M')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M+1')
  end

  def write_push_temp(memory_segment_index)
    @asm_lines.push('@5')
    write_push_to_stack(memory_segment_index)
  end

  def write_push_to_stack(memory_segment_index)
    @asm_lines.push('D=M')
    @asm_lines.push('@' + memory_segment_index.to_s)
    @asm_lines.push('A=D+A')
    @asm_lines.push('D=M')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M+1')
  end

  def write_pop_command(memory_segment, memory_segment_index)
    case memory_segment.to_sym
    when :local
      write_pop_local(memory_segment_index)
    when :argument
      write_pop_argument(memory_segment_index)
    when :this
      write_pop_this(memory_segment_index)
    when :that
      write_pop_that(memory_segment_index)
    when :constant
      raise('Stack pop command is invalid for constants')
    when :static
      write_pop_static(memory_segment_index)
    when :pointer
      write_pop_pointer(memory_segment_index)
    when :temp
      write_pop_temp(memory_segment_index)
    else
      raise('Invalid memory segment: ' + memory_segment)
    end
  end

  def write_pop_local(memory_segment_index)
    @asm_lines.push('@LCL')
    write_pop_to_memory(memory_segment_index)
  end

  def write_pop_argument(memory_segment_index)
    @asm_lines.push('@ARG')
    write_pop_to_memory(memory_segment_index)
  end

  def write_pop_this(memory_segment_index)
    @asm_lines.push('@THIS')
    write_pop_to_memory(memory_segment_index)
  end

  def write_pop_that(memory_segment_index)
    @asm_lines.push('@THAT')
    write_pop_to_memory(memory_segment_index)
  end

  def write_pop_static(memory_segment_index)
    @asm_lines.push('@' + @file_name + '.' + memory_segment_index.to_s)
    write_pop_to_memory(memory_segment_index)
  end

  def write_pop_temp(memory_segment_index)
    @asm_lines.push('@5')
    write_pop_to_memory(memory_segment_index)
  end

  def write_pop_pointer(memory_segment_index)
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    case memory_segment_index
    when 0
      @asm_lines.push('@THIS')
    when 1
      @asm_lines.push('@THAT')
    else
      raise('Invalid pointer for pop pointer command: ' +
            memory_segment_index.to_s)
    end
    @asm_lines.push('M=D')
    set_stack_after_pop
  end

  def write_pop_to_memory(memory_segment_index)
    @asm_lines.push('D=M')
    @asm_lines.push('@' + memory_segment_index.to_s)
    @asm_lines.push('D=D+A')
    @asm_lines.push('@R13')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    @asm_lines.push('@R13')
    @asm_lines.push('A=M')
    @asm_lines.push('M=D')
    set_stack_after_pop
  end

  def set_stack_after_pop
    @asm_lines.push('@SP')
    @asm_lines.push('M=M-1')
  end

  def write_add_command
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    @asm_lines.push('A=A+1')
    @asm_lines.push('D=D+M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=D')
    set_stack_after_pop
  end

  def write_sub_command
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    @asm_lines.push('A=A+1')
    @asm_lines.push('D=D-M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=D')
    set_stack_after_pop
  end

  def write_neg_command
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=-M')
  end

  def write_eq_command
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    @asm_lines.push('A=A+1')
    @asm_lines.push('D=D-M')
    @asm_lines.push('@EQ')
    @asm_lines.push('D;JEQ')
    write_set_binary_false
  end

  def write_gt_command
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    @asm_lines.push('A=A+1')
    @asm_lines.push('D=D-M')
    @asm_lines.push('@GT')
    @asm_lines.push('D;JGT')
    write_set_binary_false
  end

  def write_lt_command
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    @asm_lines.push('A=A+1')
    @asm_lines.push('D=D-M')
    @asm_lines.push('@GT')
    @asm_lines.push('D;JGT')
    write_set_binary_false
  end

  def write_and_command
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    @asm_lines.push('A=A+1')
    @asm_lines.push('D=D&M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=D')
    set_stack_after_pop
  end

  def write_or_command
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    @asm_lines.push('A=A+1')
    @asm_lines.push('D=D|M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=D')
    set_stack_after_pop
  end

  def write_not_command
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=!D')
    set_stack_after_pop
  end

  def write_set_binary_true(lines)
    lines.push('@65535')
    lines.push('D=A')
    lines.push('@SP')
    lines.push('A=M')
    lines.push('A=A-1')
    lines.push('A=A-1')
    lines.push('M=D')
    lines
  end

  def write_set_binary_false
    @asm_lines.push('@0')
    @asm_lines.push('D=A')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=D')
    set_stack_after_pop
  end
end
