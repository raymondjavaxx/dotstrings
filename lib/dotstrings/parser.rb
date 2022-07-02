# frozen_string_literal: true

require 'dotstrings/errors'

module DotStrings
  # rubocop:disable Metrics/ClassLength
  class Parser
    # Special tokens
    TOK_SLASH = '/'
    TOK_ASTERISK = '*'
    TOK_QUOTE = '"'
    TOK_ESCAPE = '\\'
    TOK_EQUALS = '='
    TOK_SEMICOLON = ';'
    TOK_NEW_LINE = "\n"
    TOK_N = 'n'
    TOK_R = 'r'
    TOK_T = 't'
    TOK_CAP_U = 'U'
    TOK_ZERO = '0'
    TOX_HEX_DIGIT = /[0-9a-fA-F]/.freeze

    # States
    STATE_START             = 0
    STATE_COMMENT_START     = 1
    STATE_COMMENT           = 2
    STATE_MULTILINE_COMMENT = 3
    STATE_COMMENT_END       = 4
    STATE_KEY               = 5
    STATE_KEY_END           = 6
    STATE_VALUE_SEPARATOR   = 7
    STATE_VALUE             = 8
    STATE_VALUE_END         = 9
    STATE_UNICODE           = 10

    attr_reader :items

    def initialize
      @state = STATE_START
      @temp_state = nil

      @buffer = []
      @unicode_buffer = []

      @escaping = false

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
          case ch
          when TOK_SLASH
            @state = STATE_COMMENT
          when TOK_ASTERISK
            @state = STATE_MULTILINE_COMMENT
          else
            raise_error("Unexpected character '#{ch}'")
          end
        when STATE_COMMENT
          if ch == TOK_NEW_LINE
            @state = STATE_COMMENT_END
            @current_comment = @buffer.join.strip
            @buffer.clear
          else
            @buffer << ch
          end
        when STATE_MULTILINE_COMMENT
          if ch == TOK_SLASH && @buffer.last == TOK_ASTERISK
            @state = STATE_COMMENT_END
            @current_comment = @buffer.slice(0, @buffer.length - 1).join.strip
            @buffer.clear
          else
            @buffer << ch
          end
        when STATE_COMMENT_END
          @state = STATE_KEY if ch == TOK_QUOTE
        when STATE_KEY
          parse_string(ch) do |key|
            @current_key = key
            @state = STATE_KEY_END
          end
        when STATE_KEY_END
          @state = STATE_VALUE_SEPARATOR if ch == TOK_EQUALS
        when STATE_VALUE_SEPARATOR
          if ch == TOK_QUOTE
            @state = STATE_VALUE
          else
            raise_error("Unexpected character '#{ch}'") unless ch.strip.empty?
          end
        when STATE_VALUE
          parse_string(ch) do |value|
            @current_value = value
            @state = STATE_VALUE_END

            @items << Item.new(
              comment: @current_comment,
              key: @current_key,
              value: @current_value
            )
          end
        when STATE_VALUE_END
          @state = STATE_START if ch == TOK_SEMICOLON
        when STATE_UNICODE
          parse_unicode(ch) do |unicode_ch|
            @buffer << unicode_ch
          end
        end

        update_position(ch)
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockLength

    private

    def raise_error(message)
      raise ParsingError, "#{message} at line #{@line}, column #{@column} (offset: #{@offset})"
    end

    def parse_string(ch, &block)
      if @escaping
        parse_escaped_character(ch, &block)
      else
        case ch
        when TOK_ESCAPE
          @escaping = true
        when TOK_QUOTE
          block.call(@buffer.join)
          @buffer.clear
        else
          @buffer << ch
        end
      end
    end

    def parse_escaped_character(ch)
      @escaping = false

      case ch
      when TOK_QUOTE, TOK_ESCAPE
        @buffer << ch
      when TOK_N
        @buffer << "\n"
      when TOK_R
        @buffer << "\r"
      when TOK_T
        @buffer << "\t"
      when TOK_CAP_U
        @temp_state = @state
        @state = STATE_UNICODE
      when TOK_ZERO
        @buffer << "\0"
      else
        raise_error("Unexpected character '#{ch}'")
      end
    end

    def parse_unicode(ch, &block)      
      case ch
      when TOX_HEX_DIGIT
        @unicode_buffer << ch
        if @unicode_buffer.length == 4
          block.call(@unicode_buffer.join.hex.chr('UTF-8'))
          @unicode_buffer.clear
          # Restore state
          @state = @temp_state
        end
      else
        raise_error("Unexpected character '#{ch}'")
      end
    end

    def update_position(ch)
      @offset += 1

      if ch == TOK_NEW_LINE
        @column = 1
        @line += 1
      else
        @column += 1
      end
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
  # rubocop:enable Metrics/ClassLength
end
