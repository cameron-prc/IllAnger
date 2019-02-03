


module IllAnger
  class Base

    attr_reader :config

    def initialize
      @config = IniFile.load(File.join(IllAnger::CONFIG_DIR, 'illAnger.ini'))
      @movies_config = IniFile.load(File.join(IllAnger::CONFIG_DIR, 'movies.ini'))

      IllAnger::LOGGER.level = Logger.const_get(@config[:logging]['level'])

      set_movie_processor(@config[:processors]["movies"])
    end

    def process_movies(sources = :default)

      IllAnger::LOGGER.debug "Processing movies"

      movies = Services::MovieFinder.new(sources, @movies_config).find_movies

      @movie_processor.process movies

    end

    private

    def set_movie_processor(processor)

      IllAnger::LOGGER.debug "Setting application processor to #{processor}"

      begin
        @movie_processor = IllAnger::Processors.const_get(processor).new
      rescue IllAnger::Errors::ProcessorInitialisationFailure => error
        IllAnger::LOGGER.error "Unable to load system processor: #{error.class}"
        IllAnger::LOGGER.error "Exiting..."
        
        exit 1
      end
    end
  end
end
