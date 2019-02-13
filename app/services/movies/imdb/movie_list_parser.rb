require 'nokogiri'

module IllAnger
  module Services
    module Movies
      module Imdb

        # Parses a standard IMDB list
        class MovieListParser

          # Takes an html page and strips out the movie information
          def parse(html)
            media_list = []

            doc = Nokogiri::HTML(html)

            doc.css('#main table tr').each do |data|
              media = {
                  title: data.css('.titleColumn a').text,
                  year: data.css('.titleColumn > span.secondaryInfo').text.tr('()', ''),
                  id: data.css('.watchlistColumn div').to_s.split('"')[3]
              }

              media_list.push(media) unless media[:title].strip.empty? or media[:year].strip.empty?
            end

            media_list
          end
        end
      end
    end
  end
end