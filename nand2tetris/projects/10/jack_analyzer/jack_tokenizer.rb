# frozen_string_literal: true

# require 'pathname'
# require_relative 'parser.rb'
# require_relative 'code_writer.rb'

##
# This class is responsible for breaking up the input Jack file into
# a stream of tokens defined by the Jack language lexicon.
class JackTokenizer
  def initialize(jack_file_names)
    @jack_file_names = jack_file_names
    @tokens = []
    @token_types = []
    @current_index = -1
    @current_token = ''
    @current_token_type = :''
    jack_files = get_jack_files(jack_file_names)
    tokenize(jack_files)
  end

  def more_tokens?
    current_index < @tokens.size
  end

  def next_token
    @current_index += 1
    @current_token = @tokens[@current_index]
    @current_token_type = @token_types[@current_index]
  end

  def token_type
    @current_token_type
  end

  def token_types
    %i[keyword symbol identifier int_const string_const]
  end

  def keyword
    if @current_token_type != :keyword
      raise 'keyword can only be called if the current token type is keyword'
    end

    @current_token
  end

  def symbol
    if @current_token_type != :symbol
      raise 'symbol can only be called if the current token type is symbol'
    end

    @current_token
  end

  def identifier
    if @current_token_type != :identifier
      raise 'identifier can only be called if the current token type is
            identifier'
    end

    @current_token
  end

  def int_val
    if @current_token_type != :int_const
      raise 'int_val can only be called if the current token type is int_const'
    end

    @current_token
  end

  def string_val
    if @current_token_type != :string_const
      raise 'string_val can only be called if the current token type is
            string_const'
    end

    @current_token
  end

  private

  def get_jack_files(jack_file_names)
    jack_files = []
    jack_file_names.each do |jack_file_name|
      puts 'Opening file: ' + jack_file_name
      jack_file = File.open(jack_file_name)
      raise 'Error opening file: ' + jack_file_name if jack_file.nil?

      jack_files.push(jack_file)
    end
    jack_files
  end

  def tokenize(jack_files)
    jack_files.each do |jack_file|
      tokenize_jack_file(jack_file)
    end
  end

  def tokenize_jack_file(jack_file)
    jack_lines = get_jack_lines(jack_file)
    tokenize_jack_lines(jack_lines)
  end

  def get_jack_lines(jack_file)
    jack_lines = []
    until jack_file.eof
      jack_line = jack_file.readline
      jack_line = jack_line.split('//')[0]
      jack_line = jack_line.strip
      jack_lines.push(jack_line)
    end
    jack_lines
  end

  def tokenize_jack_lines(jack_lines)
    jack_lines.each do |jack_line|
      tokenize_jack_line(jack_line)
    end
  end

  def tokenize_jack_line(jack_line)
    jack_words = jack_line.split(' ')
    jack_words.each do |jack_word|
      tokenize_jack_word(jack_word)
    end
  end

  def tokenize_jack_word(jack_word)
    if keyword?(jack_word)
      add_token(jack_word, :keyword)
    elsif jack_word.match(%r"{}()\[\].,;+-*/&|<>=~")
      tokenize_word_with_symbol(jack_word)
    elsif jack_word[0].integer?
      add_token(jack_word, :int_const)
    elsif jack_word.match(/"/)
      add_string_const(jack_word)
    elsif !jack_word[0].integer? && jack_word.match(/[0-9a-zA-Z_]/)
      add_token(jack_word, :identifier)
    else
      raise 'Invalid or unexpected token type for input word: ' + jack_word.to_s
    end
  end

  def add_token(token, token_type)
    @tokens.push(token.to_s)
    @token_types.push(token_type.to_sym)
  end

  def keyword?(jack_word)
    keywords = %i[class constructor function method field
                  static var int char boolean void 'true'
                  'false' null this let do if else while
                  return]
    keywords.include?(jack_word.to_sym)
  end

  def tokenize_word_with_symbol(jack_word)
    if jack_word.length > 1
      explode_word(jack_word)
    else
      add_token(jack_word, :symbol)
    end
  end

  def explode_word(jack_word)
    if !jack_word.index('{').nil?
      explode_and_recurse(jack_word, '{')
    elsif !jack_word.index('}').nil?
      explode_and_recurse(jack_word, '}')
    elsif !jack_word.index('(').nil?
      explode_and_recurse(jack_word, '(')
    elsif !jack_word.index(')').nil?
      explode_and_recurse(jack_word, ')')
    elsif !jack_word.index('[').nil?
      explode_and_recurse(jack_word, '[')
    elsif !jack_word.index(']').nil?
      explode_and_recurse(jack_word, ']')
    elsif !jack_word.index('.').nil?
      explode_and_recurse(jack_word, '.')
    elsif !jack_word.index(',').nil?
      explode_and_recurse(jack_word, ',')
    elsif !jack_word.index(';').nil?
      explode_and_recurse(jack_word, ';')
    elsif !jack_word.index('+').nil?
      explode_and_recurse(jack_word, '+')
    elsif !jack_word.index('-').nil?
      explode_and_recurse(jack_word, '-')
    elsif !jack_word.index('*').nil?
      explode_and_recurse(jack_word, '*')
    elsif !jack_word.index('/').nil?
      explode_and_recurse(jack_word, '/')
    elsif !jack_word.index('&').nil?
      explode_and_recurse(jack_word, '&')
    elsif !jack_word.index('|').nil?
      explode_and_recurse(jack_word, '|')
    elsif !jack_word.index('<').nil?
      explode_and_recurse(jack_word, '<')
    elsif !jack_word.index('>').nil?
      explode_and_recurse(jack_word, '>')
    elsif !jack_word.index('=').nil?
      explode_and_recurse(jack_word, '=')
    elsif !jack_word.index('~').nil?
      explode_and_recurse(jack_word, '~')
    else raise 'Invalid match on symbol in word: ' + jack_word.to_s
    end
  end

  def explode_and_recurse(jack_word, jack_symbol)
    add_token(jack_symbol, :symbol)
    words = jack_word.split(jack_symbol)
    words.each do |word|
      tokenize_jack_word(word)
    end
  end

  def add_string_const(jack_word)
    string_const_array = jack_word.split('"')
    if string_const_array.size != 1
      raise 'Error adding string constant for Jack word: ' + jack_word
    end

    add_token(string_const_array[0], :string_const)
  end
end

##
# Extending the String class to include the integer? method
class String
  def integer?
    to_i.to_s == self
  end
end
