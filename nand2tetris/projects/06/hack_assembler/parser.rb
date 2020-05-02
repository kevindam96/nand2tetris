
class Parser
  def initialize(hack_instruction)
    
    @is_a_instruction = false
    @is_c_instruction = false

    @a_instruction_value = 0
    @a_instruction_symbol = ""
    a_instruction_symbol
    
    if hack_instruction[0] == "@"
      @is_a_instruction = true
      @is_c_instruction = false
    else
      @is_a_instruction = false
      @is_c_instruction = true
    end

    if is_a_instruction
      if hack_instruction[1..hack_instruction.length - 1].is_integer?
        @a_instruction_value = 
      else
      end
    end

  end


  class String
    def is_integer?
      self.to_i.to_s == self
    end
  end

end