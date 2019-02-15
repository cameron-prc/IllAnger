Dir['./services/movies/*'].each { |file| require file }

module IllAnger
  module Services
    class MovieFinder

      attr_accessor :sources, :config, :processor

      def initialize(sources: :default, processor: :default)

        # noinspection RubyResolve
        @config = IniFile.load(File.join(IllAnger::CONFIG_DIR, 'movies.ini'))

        begin

          parse_sources sources
          validate_sources
          set_movie_processor(processor == :default ? @config[:main]['processor'] : processor)

        rescue Errors::SystemError => e

          p e

          raise Errors::InitialisationFailure.new "Movie finder failed to initialize"

        end

      end

      def process

        begin

          movies = find_movies

          @processor.process movies

        rescue IllAnger::Errors::SystemError => error

          raise IllAnger::Errors::ProcessingFailure.new "Failed to process movies: #{error.class}"

        end

      end

      private

      def find_movies

        IllAnger::LOGGER.debug "Initiating movie scan"

        data = []

        @sources.each do |source|

          data << process_source(source)

        end

        IllAnger::LOGGER.debug "#{data.length} results found"

        data.flatten

      end

      def parse_sources(sources)

        if sources.is_a? Array

          @sources = sources

        elsif sources == :default

          @sources = find_all_sources

        else

          @sources = [sources]

        end

      end

      def validate_sources

        IllAnger::LOGGER.debug "Validating sources"

        @sources.delete_if do |source|

          begin

            !(Services::Movies::const_get(source.capitalize))

          rescue NameError

            IllAnger::LOGGER.warn "Unable to load movie source #{source}, removing from list: #{IllAnger::Errors::InvalidMediaSource}"

            true

          end

        end

        raise IllAnger::Errors::InsufficientMediaSources.new if @sources.length < 1

      end

      def process_source(source)

        IllAnger::LOGGER.debug "Processing #{source}"

        Services::Movies.const_get(source.capitalize).new(:default).process

      end

      def find_all_sources

        @config[:sources].map do |key, value|

          key if value == 1

        end

      end

      def set_movie_processor(processor)

        IllAnger::LOGGER.debug "Setting application processor to #{processor}"

        begin

          @processor = IllAnger::Processors.const_get(processor).new

        rescue NameError, IllAnger::Errors::SystemError => error

          IllAnger::LOGGER.warn "Unable to load system processor: #{error.message}"
          IllAnger::LOGGER.warn "Unable to load system processor: #{error.message}"

          raise IllAnger::Errors::InitialisationFailure.new error.message

        end

      end

    end

  end

end
