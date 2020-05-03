# frozen_string_literal: true

##
# This class represents a translator/encoder
# The object accepts any fields from the parser
# and builds the machine language representation
# from it
class Code
  def initialize; end

  def encode_op_code(op_code)
    op_code
  end

  def encode_a_value(a_value)
    a_val_binary = a_value.to_i.to_s(2)
    a_val_binary.rjust(15, '0')
  end

  def encode_c_dest(c_dest_parsed)
    if c_dest_parsed.nil? || c_dest_parsed == ''
      '000'
    else
      check_c_dest(c_dest_parsed, 'A') +
        check_c_dest(c_dest_parsed, 'D') +
        check_c_dest(c_dest_parsed, 'M')
    end
  end

  def check_c_dest(c_dest_parsed, dest_char)
    if c_dest_parsed.index(dest_char).nil?
      '0'
    else
      '1'
    end
  end

  def encode_c_comp(c_comp_parsed)
    if c_comp_parsed.index('M').nil?
      '0' + encode_c_comp_c(c_comp_parsed)
    else
      '1' + encode_c_comp_c(c_comp_parsed)
    end
  end

  def encode_c_comp_c(c_comp_parsed)
    case c_comp_parsed
    when '0'
      '101010'
    when '1'
      '111111'
    when '-1'
      '111010'
    when 'D'
      '001100'
    when 'A', 'M'
      '110000'
    when '!D'
      '001101'
    when '!A', '!M'
      '110001'
    when '-D'
      '001111'
    when '-A', '-M'
      '110011'
    when 'D+1'
      '011111'
    when 'A+1', 'M+1'
      '110111'
    when 'D-1'
      '001110'
    when 'A-1', 'M-1'
      '110010'
    when 'D+A', 'D+M'
      '000010'
    when 'D-A', 'D-M'
      '010011'
    when 'A-D', 'M-D'
      '000111'
    when 'D&A', 'D&M'
      '000000'
    when 'D|A', 'D|M'
      '010101'
    else
      puts 'Invalid C instruction'
    end
  end

  def encode_c_jump(c_jump_parsed)
    case c_jump_parsed
    when ''
      '000'
    when 'JGT'
      '001'
    when 'JEQ'
      '010'
    when 'JGE'
      '011'
    when 'JLT'
      '100'
    when 'JNE'
      '101'
    when 'JLE'
      '110'
    when 'JMP'
      '111'
    end
  end
end
