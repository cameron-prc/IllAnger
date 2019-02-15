module IllAnger
  module Processors
    class Radarr

      def initialize

        @known_movies = Array.new

        begin

          @adapter = IllAnger::Adapters::Radarr.new

        rescue StandardError => er

          p er

          raise IllAnger::Errors::InitialisationFailure.new "Unable to initialise Radarr processor"

        end


      end

      def process(movies)

        movies_added = 0
        additions_failed = 0


        # Update the list of known movies to reduce duplicate movie requests

        begin

          refresh_known_movie_list

        rescue Errors::ExternalCommunicationFailure => error

          IllAnger::LOGGER.warn "Cancelling movie processing: #{error.message}"

          raise

        end

        IllAnger::LOGGER.debug "#{@known_movies.length} existing movies found"


        movies.each do |movie|

          IllAnger::LOGGER.debug "Processing #{movie}"

          unless movie_exists? movie

            begin

              @adapter.add_to_wanted(movie)

              movies_added += 1

              IllAnger::LOGGER.debug "#{movie} has been added to Radarr"

            rescue Errors::ExternalCommunicationFailure => error

              IllAnger::LOGGER.info error.message

              additions_failed += 1

            end

          end

        end

        IllAnger::LOGGER.info "Movie processing successful. #{movies_added} movies added, #{additions_failed} movies failed to add, #{movies.length - movies_added - additions_failed} movies skipped"

      end

      private

      def refresh_known_movie_list

        begin

          @known_movies = @adapter.get_known_movies

        rescue Errors::ExternalCommunicationFailure => error

          IllAnger::LOGGER.warn "Unable to fetch known movie list: #{error.message}"

          raise

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
