# frozen_string_literal: true

##
# This class is a code writer for the VM translator.
# Its purpose is to take the fields from the parser and
# output the command to an array of lines in Hack
# Assembly Language
class CodeWriter
  def initialize(file_name, vm_file_name, calls_of_fn_count)
    @asm_lines = []
    @file_name = file_name
    @vm_file_name = vm_file_name
    @eq_count = 0
    @gt_count = 0
    @lt_count = 0
    @calls_of_fn_count = calls_of_fn_count
  end

  attr_reader :asm_lines
  attr_reader :calls_of_fn_count

  def self.bootstrap
    asm_lines = []
    asm_lines = initialize_stack_pointer(asm_lines)
    asm_lines = call_sys_init(asm_lines)
    asm_lines
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

  def write_branching_command(command, label)
    @asm_lines = []
    @asm_lines.push('// ' + command.to_s + ' ' + label.to_s)
    case command.to_sym
    when :goto
      write_goto_command(label)
    when :'if-goto'
      write_if_goto_command(label)
    when :label
      write_label_command(label)
    end
  end

  def write_function_command(command, name, n_args)
    @asm_lines = []
    if command == :return
      @asm_lines.push('// ' + command.to_s)
    else
      @asm_lines.push('// ' + command.to_s + ' ' +
                      name.to_s + ' ' + n_args.to_s)
    end
    case command.to_sym
    when :call
      write_call_command(name, n_args)
    when :function
      write_fn_defn_command(name, n_args)
    when :return
      write_return_command
    end
  end

  def self.initialize_stack_pointer(asm_lines)
    asm_lines.push('// initialize stack pointer')
    asm_lines.push('@256')
    asm_lines.push('D=A')
    asm_lines.push('@SP')
    asm_lines.push('M=D')
    asm_lines
  end

  def self.call_sys_init(asm_lines)
    asm_lines.push('// call Sys.init')
    asm_lines = call_sys_init_push_return_add(asm_lines)
    asm_lines = call_sys_init_save_current_frame(asm_lines)
    asm_lines = call_sys_init_reposition_arg(asm_lines)
    asm_lines = call_sys_init_reposition_lcl(asm_lines)
    asm_lines = call_sys_init_goto_command(asm_lines)
    asm_lines = call_sys_init_return_label(asm_lines)
    asm_lines
  end

  def self.call_sys_init_push_return_add(asm_lines)
    asm_lines.push('@Sys.init$ret.0')
    asm_lines.push('D=A')
    asm_lines.push('@SP')
    asm_lines.push('A=M')
    asm_lines.push('M=D')
    asm_lines.push('@SP')
    asm_lines.push('M=M+1')
    asm_lines
  end

  def self.call_sys_init_save_current_frame(asm_lines)
    asm_lines = call_sys_init_push_lcl(asm_lines)
    asm_lines = call_sys_init_push_arg(asm_lines)
    asm_lines = call_sys_init_push_this(asm_lines)
    asm_lines = call_sys_init_push_that(asm_lines)
    asm_lines
  end

  def self.call_sys_init_reposition_arg(asm_lines)
    asm_lines.push('@SP')
    asm_lines.push('D=M')
    asm_lines.push('@5')
    asm_lines.push('D=D-A')
    asm_lines.push('@ARG')
    asm_lines.push('M=D')
    asm_lines
  end

  def self.call_sys_init_reposition_lcl(asm_lines)
    asm_lines.push('@SP')
    asm_lines.push('D=M')
    asm_lines.push('@LCL')
    asm_lines.push('M=D')
    asm_lines
  end

  def self.call_sys_init_goto_command(asm_lines)
    asm_lines.push('@Sys.init')
    asm_lines.push('0;JMP')
    asm_lines
  end

  def self.call_sys_init_return_label(asm_lines)
    asm_lines.push('(Sys.init$ret.0)')
  end

  def self.call_sys_init_push_lcl(asm_lines)
    asm_lines.push('@LCL')
    asm_lines.push('D=M')
    asm_lines.push('@SP')
    asm_lines.push('A=M')
    asm_lines.push('M=D')
    asm_lines.push('@SP')
    asm_lines.push('M=M+1')
    asm_lines
  end

  def self.call_sys_init_push_arg(asm_lines)
    asm_lines.push('@ARG')
    asm_lines.push('D=M')
    asm_lines.push('@SP')
    asm_lines.push('A=M')
    asm_lines.push('M=D')
    asm_lines.push('@SP')
    asm_lines.push('M=M+1')
    asm_lines
  end

  def self.call_sys_init_push_this(asm_lines)
    asm_lines.push('@THIS')
    asm_lines.push('D=M')
    asm_lines.push('@SP')
    asm_lines.push('A=M')
    asm_lines.push('M=D')
    asm_lines.push('@SP')
    asm_lines.push('M=M+1')
    asm_lines
  end

  def self.call_sys_init_push_that(asm_lines)
    asm_lines.push('@THAT')
    asm_lines.push('D=M')
    asm_lines.push('@SP')
    asm_lines.push('A=M')
    asm_lines.push('M=D')
    asm_lines.push('@SP')
    asm_lines.push('M=M+1')
    asm_lines
  end

  private_class_method :initialize_stack_pointer
  private_class_method :call_sys_init_push_return_add
  private_class_method :call_sys_init_save_current_frame
  private_class_method :call_sys_init_reposition_arg
  private_class_method :call_sys_init_reposition_lcl
  private_class_method :call_sys_init_goto_command
  private_class_method :call_sys_init_return_label
  private_class_method :call_sys_init_push_lcl
  private_class_method :call_sys_init_push_arg
  private_class_method :call_sys_init_push_this
  private_class_method :call_sys_init_push_that

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
    @asm_lines.push('D=M')
    write_push_to_stack(memory_segment_index)
  end

  def write_push_argument(memory_segment_index)
    @asm_lines.push('@ARG')
    @asm_lines.push('D=M')
    write_push_to_stack(memory_segment_index)
  end

  def write_push_this(memory_segment_index)
    @asm_lines.push('@THIS')
    @asm_lines.push('D=M')
    write_push_to_stack(memory_segment_index)
  end

  def write_push_that(memory_segment_index)
    @asm_lines.push('@THAT')
    @asm_lines.push('D=M')
    write_push_to_stack(memory_segment_index)
  end

  def write_push_static(memory_segment_index)
    @asm_lines.push('@' + @vm_file_name.to_s + '.' + memory_segment_index.to_s)
    @asm_lines.push('D=M')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M+1')
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
    @asm_lines.push('D=M')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M+1')
  end

  def write_push_temp(memory_segment_index)
    @asm_lines.push('@5')
    @asm_lines.push('D=A')
    write_push_to_stack(memory_segment_index)
  end

  def write_push_to_stack(memory_segment_index)
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
    @asm_lines.push('D=M')
    write_pop_to_memory(memory_segment_index)
  end

  def write_pop_argument(memory_segment_index)
    @asm_lines.push('@ARG')
    @asm_lines.push('D=M')
    write_pop_to_memory(memory_segment_index)
  end

  def write_pop_this(memory_segment_index)
    @asm_lines.push('@THIS')
    @asm_lines.push('D=M')
    write_pop_to_memory(memory_segment_index)
  end

  def write_pop_that(memory_segment_index)
    @asm_lines.push('@THAT')
    @asm_lines.push('D=M')
    write_pop_to_memory(memory_segment_index)
  end

  def write_pop_static(memory_segment_index)
    @asm_lines.push('@SP')
    @asm_lines.push('AM=M-1')
    @asm_lines.push('D=M')
    @asm_lines.push('@' + @vm_file_name.to_s + '.' + memory_segment_index.to_s)
    @asm_lines.push('M=D')
  end

  def write_pop_temp(memory_segment_index)
    @asm_lines.push('@5')
    @asm_lines.push('D=A')
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
    @asm_lines.push('@EQ' + @eq_count.to_s)
    @asm_lines.push('D;JEQ')
    @asm_lines.push('@NEQ' + @eq_count.to_s)
    @asm_lines.push('0;JMP')
    @asm_lines.push('(EQ' + @eq_count.to_s + ')')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=-1')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M-1')
    @asm_lines.push('@END_EQ' + @eq_count.to_s)
    @asm_lines.push('0;JMP')
    @asm_lines.push('(NEQ' + @eq_count.to_s + ')')
    @asm_lines.push('@0')
    @asm_lines.push('D=A')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M-1')
    @asm_lines.push('(END_EQ' + @eq_count.to_s + ')')
    @eq_count += 1
  end

  def write_gt_command
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    @asm_lines.push('A=A+1')
    @asm_lines.push('D=D-M')
    @asm_lines.push('@GT' + @gt_count.to_s)
    @asm_lines.push('D;JGT')
    @asm_lines.push('@NGT' + @gt_count.to_s)
    @asm_lines.push('0;JMP')
    @asm_lines.push('(GT' + @gt_count.to_s + ')')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=-1')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M-1')
    @asm_lines.push('@END_GT' + @gt_count.to_s)
    @asm_lines.push('0;JMP')
    @asm_lines.push('(NGT' + @gt_count.to_s + ')')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=0')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M-1')
    @asm_lines.push('(END_GT' + @gt_count.to_s + ')')
    @gt_count += 1
  end

  def write_lt_command
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    @asm_lines.push('A=A+1')
    @asm_lines.push('D=D-M')
    @asm_lines.push('@LT' + @lt_count.to_s)
    @asm_lines.push('D;JLT')
    @asm_lines.push('@NLT' + @lt_count.to_s)
    @asm_lines.push('0;JMP')
    @asm_lines.push('(LT' + @lt_count.to_s + ')')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=-1')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M-1')
    @asm_lines.push('@END_LT' + @lt_count.to_s)
    @asm_lines.push('0;JMP')
    @asm_lines.push('(NLT' + @lt_count.to_s + ')')
    @asm_lines.push('@0')
    @asm_lines.push('D=A')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('A=A-1')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M-1')
    @asm_lines.push('(END_LT' + @lt_count.to_s + ')')
    @lt_count += 1
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
  end

  def write_goto_command(label)
    @asm_lines.push('@' + label.to_s)
    @asm_lines.push('0;JMP')
  end

  def write_if_goto_command(label)
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('A=A-1')
    @asm_lines.push('D=M')
    set_stack_after_pop
    @asm_lines.push('@' + label.to_s)
    @asm_lines.push('D;JNE')
  end

  def write_label_command(label)
    @asm_lines.push('(' + label.to_s + ')')
  end

  def write_call_command(name, n_args)
    write_call_push_return_add(name)
    write_call_save_current_frame
    write_call_reposition_arg(n_args)
    write_call_reposition_lcl
    write_goto_command(name)
    write_call_return_label(name)
  end

  def write_call_save_current_frame
    write_call_push_lcl
    write_call_push_arg
    write_call_push_this
    write_call_push_that
  end

  def write_call_push_return_add(name)
    if !@calls_of_fn_count.key?(name.to_sym)
      @calls_of_fn_count[name.to_sym] = 0
    else
      @calls_of_fn_count[name.to_sym] += 1
    end
    @asm_lines.push('@' + name.to_s + '$ret.' +
                    @calls_of_fn_count[name.to_sym].to_s)
    @asm_lines.push('D=A')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M+1')
  end

  def write_call_push_lcl
    @asm_lines.push('@LCL')
    @asm_lines.push('D=M')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M+1')
  end

  def write_call_push_arg
    @asm_lines.push('@ARG')
    @asm_lines.push('D=M')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M+1')
  end

  def write_call_push_this
    @asm_lines.push('@THIS')
    @asm_lines.push('D=M')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M+1')
  end

  def write_call_push_that
    @asm_lines.push('@THAT')
    @asm_lines.push('D=M')
    @asm_lines.push('@SP')
    @asm_lines.push('A=M')
    @asm_lines.push('M=D')
    @asm_lines.push('@SP')
    @asm_lines.push('M=M+1')
  end

  def write_call_reposition_arg(n_args)
    @asm_lines.push('@SP')
    @asm_lines.push('D=M')
    @asm_lines.push('@5')
    @asm_lines.push('D=D-A')
    @asm_lines.push('@' + n_args.to_s)
    @asm_lines.push('D=D-A')
    @asm_lines.push('@ARG')
    @asm_lines.push('M=D')
  end

  def write_call_reposition_lcl
    @asm_lines.push('@SP')
    @asm_lines.push('D=M')
    @asm_lines.push('@LCL')
    @asm_lines.push('M=D')
  end

  def write_call_return_label(name)
    @asm_lines.push('(' + name.to_s + '$ret.' +
                    @calls_of_fn_count[name.to_sym].to_s + ')')
  end

  def write_fn_defn_command(name, n_args)
    @asm_lines.push('(' + name.to_s + ')')
    n_args.to_i.times { write_push_constant(0) }
  end

  def write_return_command
    @asm_lines.push('@LCL')
    @asm_lines.push('D=M')
    @asm_lines.push('@R14')
    @asm_lines.push('M=D')
    write_return_store_return_address
    write_pop_command(:argument, 0)
    write_return_reposition_sp
    write_return_reinstate_caller_state
    write_return_to_return_address
  end

  def write_return_store_return_address
    @asm_lines.push('@R14')
    @asm_lines.push('D=M')
    @asm_lines.push('@5')
    @asm_lines.push('A=D-A')
    @asm_lines.push('D=M')
    @asm_lines.push('@R15')
    @asm_lines.push('M=D')
  end

  def write_return_reposition_sp
    @asm_lines.push('@ARG')
    @asm_lines.push('D=M')
    @asm_lines.push('@SP')
    @asm_lines.push('M=D+1')
  end

  def write_return_reinstate_caller_state
    write_return_reinstate_that
    write_return_reinstate_this
    write_return_reinstate_arg
    write_return_reinstate_lcl
  end

  def write_return_reinstate_that
    @asm_lines.push('@R14')
    @asm_lines.push('D=M')
    @asm_lines.push('@1')
    @asm_lines.push('A=D-A')
    @asm_lines.push('D=M')
    @asm_lines.push('@THAT')
    @asm_lines.push('M=D')
  end

  def write_return_reinstate_this
    @asm_lines.push('@R14')
    @asm_lines.push('D=M')
    @asm_lines.push('@2')
    @asm_lines.push('A=D-A')
    @asm_lines.push('D=M')
    @asm_lines.push('@THIS')
    @asm_lines.push('M=D')
  end

  def write_return_reinstate_arg
    @asm_lines.push('@R14')
    @asm_lines.push('D=M')
    @asm_lines.push('@3')
    @asm_lines.push('A=D-A')
    @asm_lines.push('D=M')
    @asm_lines.push('@ARG')
    @asm_lines.push('M=D')
  end

  def write_return_reinstate_lcl
    @asm_lines.push('@R14')
    @asm_lines.push('D=M')
    @asm_lines.push('@4')
    @asm_lines.push('A=D-A')
    @asm_lines.push('D=M')
    @asm_lines.push('@LCL')
    @asm_lines.push('M=D')
  end

  def write_return_to_return_address
    @asm_lines.push('@R15')
    @asm_lines.push('A=M')
    @asm_lines.push('0;JMP')
  end
end
