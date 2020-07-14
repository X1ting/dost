module DOST
  class Data
    attr_reader :lines, :headers_delimiters, :values_delimiters, :key_modifier

    def initialize(lines:, headers_delimiters:, values_delimiters:, key_modifier: nil)
      @lines = lines.map(&:chomp)
      @headers_delimiters = headers_delimiters
      @values_delimiters = values_delimiters
      @key_modifier = key_modifier
    end

    def headers
      @headers ||= parse_headers
    end

    def values
      @values ||= parse_values
    end

    def dynamic_offseted_values(left_dynamic_bound_headers = [])
      values_lines.map do |line|
        headers.reverse.map do |(name, range)|
          is_dynamic = left_dynamic_bound_headers.include?(name)
          str = line[range]
          if is_dynamic && range.first > 0
            i = range.first - 1
            while present?(line[i]) && i >= 0 do
              str.prepend(line[i])
              line[i] = ' '
              i -= 1
            end
          end
          [name, str.strip]
        end.reverse.to_h
      end
    end

    private def parse_headers
      raw_headers = header_lines.map { |header_line| calc_ranges(header_line) }

      first_row = raw_headers.first
      second_row = raw_headers[1]

      first_row.map.with_index do |(first_key, first_range)|
        values_inside = second_row.select do |(second_key, second_range)|
          overlaps?(
            ((second_range.first + second_key.index(/(\S)/))..(second_key.strip.length + second_range.first)),
            (first_range.first..(first_key.strip.length + first_range.first))
          )
        end

        if values_inside.empty?
          [[modify_key(first_key), first_range]]
        else
          values_inside.map.with_index do |(second_item_key, second_item_range), index|
            key = (first_key.strip + second_item_key.strip.prepend('_'))
            is_last_item = (index == values_inside.count - 1)
            second_item_left_bound = second_item_range.first + second_item_key.index(/(\S)/)
            left_bound = index.zero? ? [second_item_left_bound, first_range.first].min : second_item_range.first
            right_bound = is_last_item ? [second_item_range.last, first_range.last].min : second_item_range.last

            range = left_bound..right_bound
            [modify_key(key), range]
          end
        end
      end.flatten(1)
    end

    private def parse_values
      values_lines.map do |line|
        headers.map do |(name, range)|
          [name, line[range].strip]
        end.to_h
      end
    end

    private def calc_ranges(header_line)
      header_line.split(%r{(^\s*\S*\s*)|(\S*\s*)}).reject(&:empty?).reduce([]) do |acc, key|
        index = acc.last&.last&.last || -1;
        acc.push([key, (index + 1)..(index + key.length)])
      end
    end

    private def values_lines
      lines_between_delimiters(values_delimiters.first, values_delimiters.last)
    end

    private def header_lines
      lines_between_delimiters(headers_delimiters.first, headers_delimiters.last)
    end

    private def lines_between_delimiters(delimiter_start, delimiter_end)
      lines.reduce([]) do |acc, line|
        if acc.empty?
          acc.push(line) if delimiter?(line) && delimiter_char(line) == delimiter_start
        else
          if delimiter?(line)
            if delimiter_char(line) == delimiter_end
              return acc[1..-1]
            else
              acc = [line]
            end
          else
            acc.push(line)
          end
        end
        acc
      end
    end

    private def delimiter?(line)
      line.chars.uniq.count == 1 && present?(delimiter_char(line))
    end

    private def delimiter_char(line)
      line.chars.uniq.first
    end

    private def blank?(str)
      str !~ /[^[:space:]]/
    end

    private def present?(str)
      !blank?(str)
    end

    # from https://apidock.com/rails/Range/overlaps
    private def overlaps?(orig, other)
      orig.cover?(other.first) || other.cover?(orig.first)
    end

    private def modify_key(key)
      key_modifier.nil? ? keyа : key_modifier.call(key)
    end
  end
end
