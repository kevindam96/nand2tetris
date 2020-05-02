# frozen_string_literal: true

##
# This class is a parser for the Hack assembly language
# Its purpose is to unpack a Hack assembly language instruction
# into its underlying fields
class Parser
  def initialize(symbol_table)
    @op_code = ''
    @symbol_table = symbol_table
    @a_instruction_value = ''
    @c_instruction_dest = ''
    @c_instruction_comp = ''
    @c_instruction_jump = ''
  end

  attr_reader :op_code
  attr_reader :a_instruction_value
  attr_reader :c_instruction_dest
  attr_reader :c_instruction_comp
  attr_reader :c_instruction_jump

  def parse_instruction(hack_instruction)
    parse_op_code(hack_instruction)
    if @op_code == '0'
      parse_a_instruction(hack_instruction)
    else
      parse_c_instruction(hack_instruction)
    end
  end

  def parse_op_code(hack_instruction)
    @op_code = if hack_instruction.index('@').nil?
                 '1'
               else
                 '0'
               end
  end

  def parse_a_instruction(hack_instruction)
    symbol = hack_instruction[1..hack_instruction.length - 1]
    if symbol.integer?
      @a_instruction_value = symbol
    else
      parse_a_value_from_symbol(symbol)
    end
  end

  def parse_a_value_from_symbol(symbol)
    @a_instruction_value = @symbol_table[symbol]
  end

  def parse_c_instruction(hack_instruction)
    has_equals = !hack_instruction.index('=').nil?
    has_semicolon = !hack_instruction.index(';').nil?
    split_c_instruction(has_equals, has_semicolon, hack_instruction)
  end

  def split_c_instruction(has_equals, has_semicolon, hack_instruction)
    if has_equals && has_semicolon
      parse_c_dest_jump(hack_instruction)
    elsif has_equals && !has_semicolon
      parse_c_dest(hack_instruction)
    elsif !has_equals && has_semicolon
      parse_c_jump(hack_instruction)
    else
      @c_instruction_comp = hack_instruction
    end
  end

  def parse_c_dest(hack_instruction)
    equals_split = hack_instruction.split('=')
    @c_instruction_dest = equals_split[0]
    @c_instruction_comp = equals_split[1]
  end

  def parse_c_jump
    semicolon_split = hack_instruction.split(';')
    @c_instruction_jump = semicolon_split[semicolon_split.size - 1]
    @c_instruction_comp = semicolon_split[semicolon_split.size - 2]
  end

  def parse_c_dest_jump
    equals_split = hack_instruction.split('=')
    equals_semicolon_split = equals_split.split(';')
    @c_instruction_dest = equals_split[0]
    @c_instruction_comp = equals_semicolon_split[0]
    @c_instruction_jump = equals_semicolon_split[1]
  end

  ##
  # Add the integer method to the String class
  class String
    def integer?
      to_i.to_s == self
    end
  end
end
