# frozen_string_literal: true

##
# This class is a parser for the Hack assembly language
# Its purpose is to unpack a Hack assembly language instruction
# into its underlying fields
class Parser
  def initialize
    @op_code = ''
    @a_instruction_value = ''
    @c_instruction_a = ''
    @c_instruction_c = ''
    @c_instruction_d = ''
    @c_instruction_j = ''
    @symbol_table = initialize_symbol_table
  end

  def initialize_symbol_table
    symbol_table = { 'R0' => '0', 'R1' => '1', 'R2' => '2', 'R3' => '3',
                     'R4' => '4', 'R5' => '5', 'R6' => '6', 'R7' => '7',
                     'R8' => '8', 'R9' => '9', 'R10' => '10', 'R11' => '11',
                     'R12' => '12', 'R13' => '13', 'R14' => '14',
                     'R15' => '15' }
    symbol_table
  end

  def parse_instruction(hack_instruction)
    @op_code = hack_instruction[0]
    if @op_code == '0'
      parse_a_instruction(hack_instruction)
    else
      parse_c_instruction(hack_instruction)
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
    add_symbol_to_table(symbol) unless symbol_to_table.key?(symbol)
    @a_instruction_value = @symbol_table[symbol]
  end

  def add_symbol_to_table(symbol)
    @symbol_table[symbol] = @symbol_table.size
  end

  def parse_c_instruction(hack_instruction)
    parse_c_instruction_a(hack_instruction)
    parse_c_instruction_c(hack_instruction)
    parse_c_instruction_d(hack_instruction)
    parse_c_instruction_j(hack_instruction)
  end

  def parse_c_instruction_a(hack_instruction)
    @c_instruction_a = hack_instruction[3]
  end

  def parse_c_instruction_c(hack_instruction)
    @c_instruction_c = hack_instruction[4..9]
  end

  def parse_c_instruction_d(hack_instruction)
    @c_instruction_d = hack_instruction[10..12]
  end

  def parse_c_instruction_j(hack_instruction)
    @c_instruction_j = hack_instruction[13..15]
  end
  ##
  # Add the integer method to the String class
  class String
    def integer?
      to_i.to_s == self
    end
  end
end
