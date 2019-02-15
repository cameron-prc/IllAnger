

# Remove dependancy on services.
#
#  Should error if no valid services are found however run if at least one is
#
module IllAnger
  class Base

    attr_reader :config

    def initialize

      # noinspection RubyResolve
      @config = IniFile.load(File.join(IllAnger::CONFIG_DIR, 'illAnger.ini'))

      IllAnger::LOGGER.level = Logger.const_get(@config[:logging]['level'])

    end

    def process

      media_finder = MediaFinder.new

      @config[:media_types].each do |media_type, active|

        next unless active == 1

        if media_finder.load_service(media_type)

          media_finder.process

        elsif

          IllAnger::LOGGER.warn "Cancelling #{media_type} run"

        end

      end

    end

  end

end
