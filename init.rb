require 'stakr/string_utilities/metrics'
require 'stakr/string_utilities/url_generator'

String.class_eval do
  include Stakr::StringUtilities::Metrics
  include Stakr::StringUtilities::UrlGenerator
end
