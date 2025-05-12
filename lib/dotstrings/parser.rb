# frozen_string_literal: true

require 'dotstrings/errors'

module DotStrings
  # rubocop:disable Metrics/ClassLength

  ##
  # Parser for .strings files.
  #
  # You can use this class directly, but it is recommended to use
  # {File.parse} and {File.parse_file} wrappers instead.
  class Parser
    # Special tokens
    TOK_SLASH        = '/'
    TOK_ASTERISK     = '*'
    TOK_QUOTE        = '"'
    TOK_SINGLE_QUOTE = "'"
    TOK_BACKSLASH    = '\\'
    TOK_EQUALS       = '='
    TOK_SEMICOLON    = ';'
    TOK_NEW_LINE     = "\n"
    TOK_N            = 'n'
    TOK_R            = 'r'
    TOK_T            = 't'
    TOK_CAP_U        = 'U'
    TOK_ZERO         = '0'
    TOK_HEX_DIGIT    = /[0-9a-fA-F]/

    # States
    STATE_START               = 0
    STATE_COMMENT_START       = 1
    STATE_COMMENT             = 2
    STATE_MULTILINE_COMMENT   = 3
    STATE_COMMENT_END         = 4
    STATE_KEY                 = 5
    STATE_KEY_END             = 6
    STATE_VALUE_SEPARATOR     = 7
    STATE_VALUE               = 8
    STATE_VALUE_END           = 9
    STATE_UNICODE             = 10
    STATE_UNICODE_SURROGATE   = 11
    STATE_UNICODE_SURROGATE_U = 12

    ##
    # Returns a new Parser instance.
    #
    # @param strict [Boolean] Whether to parse in strict mode.
    def initialize(strict: true)
      @strict = strict

      @state = STATE_START
      @temp_state = nil

      @buffer = []
      @unicode_buffer = []
      @high_surrogate = nil

      @escaping = false

      @current_comment = nil
      @current_key = nil
      @current_value = nil

      @item_block = nil

      @offset = 0
      @line = 1
      @column = 1
    end

    ##
    # Specifies a block to be called when a new item is parsed.
    def on_item(&block)
      @item_block = block
    end

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/BlockLength

    ##
    # Feeds data to the parser.
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
          comment_end(ch)
        when STATE_KEY
          parse_string(ch) do |key|
            @current_key = key
            @state = STATE_KEY_END
          end
        when STATE_KEY_END
          if ch == TOK_EQUALS
            @state = STATE_VALUE_SEPARATOR
          else
            raise_error("Unexpected character '#{ch}', expecting '#{TOK_EQUALS}'") unless whitespace?(ch)
          end
        when STATE_VALUE_SEPARATOR
          if ch == TOK_QUOTE
            @state = STATE_VALUE
          else
            raise_error("Unexpected character '#{ch}'") unless whitespace?(ch)
          end
        when STATE_VALUE
          parse_string(ch) do |value|
            @current_value = value
            @state = STATE_VALUE_END

            @item_block&.call(Item.new(
              comment: @current_comment,
              key: @current_key,
              value: @current_value
            ))
          end
        when STATE_VALUE_END
          if ch == TOK_SEMICOLON
            @state = STATE_START
          else
            raise_error("Unexpected character '#{ch}', expecting '#{TOK_SEMICOLON}'") unless whitespace?(ch)
          end
        when STATE_UNICODE
          parse_unicode(ch) do |unicode_ch|
            @buffer << unicode_ch
            # Restore state
            @state = @temp_state
          end
        when STATE_UNICODE_SURROGATE
          if ch == TOK_BACKSLASH
            @state = STATE_UNICODE_SURROGATE_U
          else
            raise_error("Unexpected character '#{ch}', expecting another unicode codepoint")
          end
        when STATE_UNICODE_SURROGATE_U
          if ch == TOK_CAP_U
            @state = STATE_UNICODE
          else
            raise_error("Unexpected character '#{ch}', expecting '#{TOK_CAP_U}'")
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
        parse_escaped_character(ch)
      else
        case ch
        when TOK_BACKSLASH
          @escaping = true
        when TOK_QUOTE
          block.call(@buffer.join)
          @buffer.clear
        else
          @buffer << ch
        end
      end
    end

    # rubocop:disable Metrics/CyclomaticComplexity

    def parse_escaped_character(ch)
      @escaping = false

      case ch
      when TOK_QUOTE, TOK_SINGLE_QUOTE, TOK_BACKSLASH
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
        raise_error("Unexpected character '#{ch}'") if @strict
        @buffer << ch
      end
    end

    # rubocop:enable Metrics/CyclomaticComplexity

    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def parse_unicode(ch, &block)
      raise_error("Unexpected character '#{ch}', expecting a hex digit") unless TOK_HEX_DIGIT.match?(ch)

      @unicode_buffer << ch

      # Check if we have enough digits to form a codepoint.
      return if @unicode_buffer.length < 4

      codepoint = @unicode_buffer.join.hex

      if codepoint.between?(0xD800, 0xDBFF)
        unless @high_surrogate.nil?
          raise_error(
            'Found a high surrogate code point after another high surrogate'
          )
        end

        @high_surrogate = codepoint
        @state = STATE_UNICODE_SURROGATE
      elsif codepoint.between?(0xDC00, 0xDFFF)
        if @high_surrogate.nil?
          raise_error(
            'Found a low surrogate code point before a high surrogate'
          )
        end

        character = ((@high_surrogate - 0xD800) * 0x400) + (codepoint - 0xDC00) + 0x10000
        @high_surrogate = nil

        block.call(character.chr('UTF-8'))
      else
        unless @high_surrogate.nil?
          raise_error(
            "Invalid unicode codepoint '\\U#{codepoint.to_s(16).upcase}' after a high surrogate code point"
          )
        end

        block.call(codepoint.chr('UTF-8'))
      end

      # Clear buffer after codepoint is parsed
      @unicode_buffer.clear
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

    def update_position(ch)
      @offset += 1

      if ch == TOK_NEW_LINE
        @column = 1
        @line += 1
      else
        @column += 1
      end
    end

    def start_value(ch, resets: true)
      case ch
      when TOK_SLASH
        @state = STATE_COMMENT_START
        reset_state if resets
      when TOK_QUOTE
        @state = STATE_KEY
        reset_state if resets
      else
        raise_error("Unexpected character '#{ch}'") unless whitespace?(ch)
      end
    end

    def comment_end(ch)
      if @strict
        # In strict mode, we expect a key to follow the comment.
        if ch == TOK_QUOTE
          @state = STATE_KEY
        else
          raise_error("Unexpected character '#{ch}'") unless whitespace?(ch)
        end
      else
        # In lenient mode, we allow comments to be followed by anything.
        start_value(ch, resets: false)
      end
    end

    def reset_state
      @current_comment = nil
      @current_key = nil
      @current_value = nil
    end

    def whitespace?(ch)
      ch.strip.empty?
    end
  end
  # rubocop:enable Metrics/ClassLength
end
