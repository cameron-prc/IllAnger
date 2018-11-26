Dir['./services/movies/*'].each { |file| require file }

module IllAnger
  module Services
    class MovieFinder

      attr_accessor :sources, :config

      def initialize(sources=:default, config)

        @config = config

        if sources.is_a? Array
          @sources = sources
        elsif sources == :default
          @sources = find_all_sources
        else
          @sources = [sources]
        end

      end

      def find_movies

        IllAnger::LOGGER.debug "Initiating movie scan"

        data = []

        @sources.each do |source|
          data << process_source(source)
        end

        data.flatten

      end

      private

      def process_source(source)
        IllAnger::LOGGER.debug "Processing #{source}"

        Services::Movies.const_get(source.capitalize).new(:default).process
      end

      def find_all_sources
        @config[:sources].map do |key, value|
          key if value == 1
        end
      end
    end
  end
end
