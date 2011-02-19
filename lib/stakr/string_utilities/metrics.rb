module Stakr #:nodoc:
  module StringUtilities #:nodoc:
    
    # Collection of methods handling Strings according to their metrics. Methods taking a <tt>length</tt> parameter
    # specify the width of a String in <tt>em</tt> (width of the letter 'm').
    module Metrics
      
      METRICS = { ' ' => 0.333, '!' => 0.333, '"' => 0.423, '#' => 0.666, '$' => 0.666, '%' => 1.063, '&' => 0.801, '\'' => 0.225, '(' => 0.396, ')' => 0.396, '*' => 0.468, '+' => 0.702, ',' => 0.333, '-' => 0.396, '.' => 0.333, '/' => 0.333, ':' => 0.333, ';' => 0.333, '<' => 0.702, '=' => 0.702, '>' => 0.702, '?' => 0.666, '@' => 1.216, '[' => 0.333, '\\' => 0.333, ']' => 0.333, '^' => 0.558, '_' => 0.666, '{' => 0.396, '|' => 0.315, '}' => 0.396, '§' => 0.666, '´' => 0.396,
                  '0' => 0.666, '1' => 0.666, '2' => 0.666, '3' => 0.666, '4' => 0.666, '5' => 0.666, '6' => 0.666, '7' => 0.666, '8' => 0.666, '9' => 0.666,
                  'A' => 0.801, 'B' => 0.801, 'C' => 0.864, 'D' => 0.864, 'E' => 0.801, 'F' => 0.729, 'G' => 0.927, 'H' => 0.864, 'I' => 0.333, 'J' => 0.603, 'K' => 0.801, 'L' => 0.666, 'M' => 1.0, 'N' => 0.864, 'O' => 0.927, 'P' => 0.801, 'Q' => 0.927, 'R' => 0.864, 'S' => 0.801, 'T' => 0.729, 'U' => 0.864, 'V' => 0.801, 'W' => 1.135, 'X' => 0.801, 'Y' => 0.801, 'Z' => 0.729,
                  'a' => 0.666, 'b' => 0.666, 'c' => 0.603, 'd' => 0.666, 'e' => 0.666, 'f' => 0.333, 'g' => 0.666, 'h' => 0.666, 'i' => 0.270, 'j' => 0.270, 'k' => 0.603, 'l' => 0.270, 'm' => 1.0, 'n' => 0.666, 'o' => 0.666, 'p' => 0.666, 'q' => 0.666, 'r' => 0.396, 's' => 0.603, 't' => 0.333, 'u' => 0.666, 'v' => 0.603, 'w' => 0.864, 'x' => 0.603, 'y' => 0.603, 'z' => 0.603 }
      
      DEFAULT_WIDTH = METRICS['m']
      
      # Truncates this String, appends the specified <tt>suffix</tt> and returns a String with the specified total
      # <tt>length</tt> in <tt>em</tt>.
      def truncate(length, suffix = '...')
        
        # determine result width
        result_width = length * DEFAULT_WIDTH
        
        # return self if string does not need to be truncated
        if self.width <= result_width
          return self 
        end
        
        # determine truncated string
        result_width -= suffix.width
        truncated_string_width = 0
        truncated_string = ''
        self.each_char do |char|
          char_width = METRICS[char] || DEFAULT_WIDTH
          if truncated_string_width + char_width <= result_width
            truncated_string_width += char_width
            truncated_string << char
          else
            break
          end
        end
        
        # return truncated string
        return truncated_string + suffix
        
      end
      
      # Truncates this String which is interpreted as URL to the specified total <tt>length</tt> in <tt>em</tt>.
      # This method shortens the parts of the URL in reversed order to their significance.
      # 
      # Parts by significance:
      # * Protocol, host and port
      # * Last path component (i.e. the file name)
      # * Path components between the host or port and the last path component.
      # 
      def url_truncate(length)
        
        begin
          
          # parse URL
          uri = URI.parse(self)
          
          # determine relevant parts of URL
          prefix = ((uri.scheme.blank? || uri.scheme == 'http') ? '' : (uri.scheme.to_s + '://')) +
                   uri.host.to_s +
                   (((uri.port.blank? || uri.port == uri.default_port) ? '' : (':' + uri.port.to_s)))
          parts = uri.path.split(/\//).map { |c| c.blank? ? nil : c }.compact
          if parts.empty?
            file = ''
            path = ''
          else
            file = '/' + parts.delete_at(-1)
            path = parts.empty? ? '' : ('/' + parts.join('/'))
          end
          
          # determine result width
          result_width = length * DEFAULT_WIDTH
          
          # determine widths
          prefix_width = prefix.width
          path_width = path.width
          file_width = file.width
          dots_width = '/...'.width
          
          # return complate URL if possible
          if prefix_width + path_width + file_width <= result_width
            return prefix + path + file
          end
          
          # determine which parts of URL can be used
          if (path_width > dots_width) # it makes sense to truncate path
            if prefix_width + dots_width + file_width <= result_width # it's sufficient to truncate path
              result_path_width = result_width - prefix_width - file_width
              return prefix + path.truncate(result_path_width / DEFAULT_WIDTH) + file
            else # it's NOT sufficient to truncate path
              result_file_width = result_width - prefix_width - dots_width
              if result_file_width > dots_width # it make sense to truncate file
                return (prefix + '/...' + file).truncate(length)
              else # it make NO sense to truncate file
                return (prefix + '/...').truncate(length)
              end
            end
          else # it makes NO sense to truncate path
            return (prefix + path + file).truncate(length)
          end
          
        rescue
          if ENV['RAILS_ENV'] == 'production'
            return self.truncate
          else
            raise $!
          end
        end
        
      end
      
      # Returns the width of this String in <tt>em</tt>.
      def width
        width = 0
        self.each_char do |char|
          char_width = METRICS[char] || DEFAULT_WIDTH
          width += char_width
        end
        return width
      end
      
    end
    
  end
end
