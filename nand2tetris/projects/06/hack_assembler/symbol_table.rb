# frozen_string_literal: true

##
# This class represents a symbol table
# The table is a hash where the key is the symbol and the
# value is the address in RAM pertaining to the symbol
class SymbolTable
  def initialize
    @table = { 'R0' => '0', 'R1' => '1', 'R2' => '2', 'R3' => '3',
               'R4' => '4', 'R5' => '5', 'R6' => '6', 'R7' => '7',
               'R8' => '8', 'R9' => '9', 'R10' => '10', 'R11' => '11',
               'R12' => '12', 'R13' => '13', 'R14' => '14',
               'R15' => '15',
               'SCREEN' => '16384', 'KBD' => '24576',
               'SP' => '0', 'LCL' => '1', 'ARG' => '2',
               'THIS' => '3', 'THAT' => '4' }
    @variable_count = 0
  end

  def get_value(symbol)
    @table[symbol]
  end

  def contains_symbol?(symbol)
    @table.key? symbol
  end

  def add_variable(variable)
    if @table.size - 5 < 16_384
      @table[variable] = @variable_count + 16
      @variable_count += 1
    else
      throw Exception('RAM is full, no space available for adding symbols')
    end
  end

  def add_label(label, instruction_number)
    if @table.size - 5 < 16_384
      @table[label] = instruction_number
    else
      throw Exception('RAM is full, no space available for adding symbols')
    end
  end
end
