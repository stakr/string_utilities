require 'iconv'

module Stakr #:nodoc:
  module StringUtilities #:nodoc:
    
    module UrlGenerator
      
      REPLACE = { 'ä' => 'ae', 'á' => 'a', 'à' => 'a', 'â' => 'a', 'ã' => 'a', 'å' => 'a', 'æ' => 'ae',
                               'é' => 'e', 'è' => 'e', 'ê' => 'e',               'ë' => 'e',
                               'í' => 'i', 'ì' => 'i', 'î' => 'i',               'ï' => 'i',
                  'ö' => 'oe', 'ó' => 'o', 'ò' => 'o', 'ô' => 'o', 'õ' => 'o', 'ø' => 'oe',
                  'ü' => 'ue', 'ú' => 'u', 'ù' => 'u', 'û' => 'u',
                  'ç' => 'c',
                  'ñ' => 'n',
                  'ß' => 'ss' }
      
      def slug(locale = nil)
        
        friendly = self
        
        # URLs should be downcase
        friendly = friendly.mb_chars.downcase
        
        # localizied versions of ampersands
        friendly =  case locale.to_s
                    when 'de' then friendly.mb_chars.gsub(/&/, ' und ')
                    when 'en' then friendly.mb_chars.gsub(/&/, ' and ')
                    when 'es' then friendly.mb_chars.gsub(/& +(i|hi)/, ' e \1').gsub(/&/, ' y ')
                    when 'fr' then friendly.mb_chars.gsub(/&/, ' et ')
                    when 'it' then friendly.mb_chars.gsub(/& +(e)/, ' ed \1').gsub(/&/, ' e ')
                    else           friendly.mb_chars.gsub(/&/, '')
                    end
        
        # replace some characters with known good replacements
        friendly = friendly.mb_chars.gsub(Regexp.new("[#{REPLACE.keys.join}]")) { |char| REPLACE[char] }
        
        # replace all characters that should be replaced with a space (which becomes a dash later)
        friendly = friendly.mb_chars.gsub(/[\/\-_\s]+/, ' ')
        
        # remove non ASCII chars
        friendly = Iconv.new('ascii//ignore//translit', 'utf-8').iconv(friendly)
        
        # remove unusable chars
        friendly.gsub!(/[^\s\w\d]/, '')
        
        # remove unusable whitespaces
        friendly.strip!
        friendly.squeeze!(' ')
        
        # replace whitespaces with dashes
        friendly.tr!(' ','-')
        
        return friendly
        
      end
      
    end
    
  end
end
