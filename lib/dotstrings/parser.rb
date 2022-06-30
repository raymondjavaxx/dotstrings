# frozen_string_literal: true

module DotStrings
  class Parser
    # Special tokens
    TOK_SLASH = '/'
    TOK_ASTERISK = '*'
    TOK_QUOTE = '"'
    TOK_ESCAPE = '\\'
    TOK_EQUALS = '='
    TOK_SEMICOLON = ';'
    TOK_NEW_LINE = "\n"

    # States
    STATE_START = 0
    STATE_COMMENT_START = 1
    STATE_COMMENT = 2
    STATE_COMMENT_END = 3
    STATE_KEY = 4
    STATE_KEY_END = 5
    STATE_VALUE_SEPARATOR = 6
    STATE_VALUE = 7
    STATE_VALUE_END = 8

    attr_reader :items

    def initialize
      @state = STATE_START
      @stack = []

      @current_comment = nil
      @current_key = nil
      @current_value = nil

      @items = []

      @offset = 0
      @line = 1
      @column = 1
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockLength
    def <<(data)
      data.each_char do |ch|
        case @state
        when STATE_START
          start_value(ch)
        when STATE_COMMENT_START
          @state = STATE_COMMENT if scan_character(ch, TOK_ASTERISK, strict: true)
        when STATE_COMMENT
          if ch == TOK_SLASH && @stack.last == TOK_ASTERISK
            @state = STATE_COMMENT_END
            @current_comment = @stack.slice(0, @stack.length - 1).join.strip
            @stack.clear
          else
            @stack << ch
          end
        when STATE_COMMENT_END
          @state = STATE_KEY if scan_character(ch, TOK_QUOTE)
        when STATE_KEY
          if ch == TOK_QUOTE && @stack.last != TOK_ESCAPE
            @state = STATE_KEY_END
            @current_key = @stack.join
            @stack.clear
          else
            @stack.pop if ch == TOK_QUOTE && @stack.last == TOK_ESCAPE
            @stack << ch
          end
        when STATE_KEY_END
          @state = STATE_VALUE_SEPARATOR if scan_character(ch, TOK_EQUALS)
        when STATE_VALUE_SEPARATOR
          if ch == TOK_QUOTE
            @state = STATE_VALUE
          else
            unless ch.strip.empty?
              raise ParsingError,
                    "Unexpected character '#{ch}' at line #{@line}, column #{@column} (offset: #{@offset})"
            end
          end
        when STATE_VALUE
          if ch == TOK_QUOTE && @stack.last != TOK_ESCAPE
            @state = STATE_VALUE_END
            @current_value = @stack.join
            @stack.clear

            @items << Item.new(
              comment: @current_comment,
              key: @current_key,
              value: @current_value
            )
          else
            @stack.pop if ch == TOK_QUOTE && @stack.last == TOK_ESCAPE

            @stack << ch
          end
        when STATE_VALUE_END
          @state = STATE_START if scan_character(ch, TOK_SEMICOLON)
        end

        update_position(ch)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockLength

    private

    def update_position(ch)
      @offset += 1

      if ch == TOK_NEW_LINE
        @column = 1
        @line += 1
      else
        @column += 1
      end
    end

    def scan_character(ch, expected, options = {})
      return true if ch == expected

      strict = options[:strict] || false

      if strict || !ch.strip.empty?
        raise ParsingError, "Unexpected character '#{ch}' at line #{@line}, column #{@column} (offset: #{@offset})"
      end

      false
    end

    def start_value(ch)
      case ch
      when TOK_SLASH
        @state = STATE_COMMENT_START
        reset_state
      when TOK_QUOTE
        @state = STATE_KEY
        reset_state
      else
        raise ParsingError, "Unexpected character '#{ch}' at #{@position}" unless ch.strip.empty?
      end
    end

    def reset_state
      @current_comment = nil
      @current_key = nil
      @current_value = nil
    end
  end
end
