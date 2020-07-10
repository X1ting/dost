module DOST
  class Data
    attr_reader :lines, :headers_delimiters, :values_delimiters

    def initialize(lines:, headers_delimiters:, values_delimiters:)
      @lines = lines.map(&:chomp)
      @headers_delimiters = headers_delimiters
      @values_delimiters = values_delimiters
    end

    def headers
      @headers ||= parse_headers
    end

    def values
      @values ||= parse_values
    end

    def parse_headers
      raw_headers = header_lines.map { |header_line| calc_ranges(header_line) }

      first_row = raw_headers.first
      second_row = raw_headers.last

      first_row.map do |(first_key, first_range)|
        values_inside = second_row.select do |(lk, lr)|
          (lr.first..(lk.length + lr.first)).overlaps?(first_range.first..(first_range.first + first_key.length))
        end

        if values_inside.present? && values_inside.count > 1
          values_inside.map.with_index do |(second_item_key, second_item_range), index|
            key = (first_key.to_s + second_item_key.to_s.prepend('_')).to_sym
            is_last_item = (index == values_inside.count - 1)
            left_bound = index.zero? ? [second_item_range.first, first_range.first].min : second_item_range.first
            right_bound = is_last_item ? [second_item_range.last, first_range.last].min : second_item_range.last

            range = left_bound..right_bound
            [key, range]
          end
        else
          [[first_key, first_range]]
        end
      end.flatten(1)
    end

    def parse_values
      values_lines.map do |line|
        headers.map do |(name, range)|
          [name, line[range].strip]
        end.to_h
      end
    end

    def calc_ranges(header_line)
      header_line.split(%r{(^\s*\S*\s*)|(\S*\s*)}).reject(&:empty?).reduce([]) do |acc, key|
        index = acc.last&.last&.last || -1;
        acc.push([key.strip.downcase.to_sym, (index + 1)..(index + (key.length))])
      end
    end

    def values_lines
      lines_between_delimiters(values_delimiters.first, values_delimiters.last)
    end

    def header_lines
      lines_between_delimiters(headers_delimiters.first, headers_delimiters.last)
    end

    def lines_between_delimiters(delimiter_start, delimiter_end)
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

    def delimiter?(line)
      line.chars.uniq.count == 1 && delimiter_char(line).present?
    end

    def delimiter_char(line)
      line.chars.uniq.first
    end
  end
end
