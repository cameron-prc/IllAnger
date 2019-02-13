Dir['./services/movies/imdb/*.rb'].each { |file| require file }
require 'open-uri'

module IllAnger
  module Services
    module Movies
      module Imdb

        def self.new(x)
          Services::Movies::Imdb::Base.new(x)
        end

        class Base

          attr_accessor :sub_sources, :config

          def initialize(sub_sources = :default)

            @config = IniFile.load(File.join(IllAnger::CONFIG_DIR, 'imdb.ini'))

            @sub_sources = find_all_sources
          end

          def process
            data = []

            @sub_sources.each do |sub_source|

              IllAnger::LOGGER.debug "Processing #{sub_source}"

              #
              # Select the HTML parser for this time of collection
              # Some lists use different formats
              parser_type = @config[:parsers][sub_source]

              root_url = @config[:urls]['root_url']
              url = root_url + @config[:urls][sub_source]

              parser = Imdb.const_get("#{parser_type}Parser").new

              html = open(url, {'Accept-Language' => 'en'})

              new_data = parser.parse html

              data << new_data
            end

            data.flatten
          end

          private

          def find_all_sources
            @config[:movie_sources].map {|key, value|
              key if value == 1
            }
          end
        end
      end
    end
  end
end
