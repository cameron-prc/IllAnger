module IllAnger
  class MediaFinder

    attr_reader :service


    def initialize

    end

    def load_service(service_name)

      begin

        IllAnger::LOGGER.debug "Loading finder service: #{service_name}"

        @service = Services::const_get("#{service_name.capitalize}Finder").new

      rescue NameError => er

        IllAnger::LOGGER.warn "Unable to load #{service_name} finder service"

        @service = nil

      end

      !!@service

    end

    def process

      begin

        @service.process

      rescue Errors::ProcessingFailure => error

        IllAnger::LOGGER.warn "#{@service} processing failed: #{error.class}"

      end

    end

  end

end
