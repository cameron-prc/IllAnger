require 'open-uri'

# Quick and dirty scraper used while I sort an api key out

module IllAnger
  module Adapters
    module TheMovieDatabaseAdapter

      # Should convert to use api but this will do for now
      def self.get_id title, year
        movie_title = title#movie.get_default_title
        movie_year = year#movie.get_default_year

        search_url = "https://www.themoviedb.org/search?query=#{URI.encode movie_title}+y%3A#{movie_year}"

        begin
          html = open(search_url)
          doc = Nokogiri::HTML(html)
          doc.css('.results')[0].children[1].children[1].children[1].attributes['id'].value[6..-1]
        rescue
          nil
        end


      end

      def self.get_poster_url id

        search_url = "https://www.themoviedb.org/movie/#{id}"

        begin
          html = open(search_url)
          doc = Nokogiri::HTML(html)

          doc.css('img')[0].attributes['src'].value
        rescue
          nil
        end
      end
    end
  end
end
