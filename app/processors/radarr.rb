module IllAnger
  module Processors
    class Radarr

      def initialize
        @known_movies = []
        @adapter = IllAnger::Adapters::Radarr.new

        unless @adapter.connected
          IllAnger::LOGGER.error "Unable to initialise Radarr processor"

          throw new IllAnger::Errors::ProcessorInitialisationFailure
        end
      end

      def process(movies)

        # Update the list of known movies to reduce duplicate movie requests
        refresh_known_movie_list

        movies.each do |movie|
          @adapter.add_to_wanted movie unless movie_exists? movie
        end
      end

      private

      # TODO: store movies locally here
      def refresh_known_movie_list
        begin
          @known_movies = @adapter.get_known_movies
        rescue Exception => e

          IllAnger::LOGGER.warn "Unable to fetch known movie list"
          IllAnger::LOGGER.warn e

          exit 1
        end
      end

      #
      # Searches a movies title and alternate titles looking for a name year match
      #
      # This isn't the most accurate way of comparing however the chances of getting
      # a name year collision are slim enough that this will do
      #
      def movie_exists?(movie)

        titles = []
        title_match = false
        year_match = false

        @known_movies.any? do |known_movie|

          titles << known_movie[:title]

          known_movie[:alternativeTitles].each do |alternative_title|
            titles << alternative_title[:title]
          end

          titles.each do |title|
            title_match = true if title.to_s.upcase == movie[:title].to_s.upcase
          end

          year_match = true if known_movie[:year].to_s == movie[:year].to_s

          title_match and year_match
        end
      end
    end
  end
end
