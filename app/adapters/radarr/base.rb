module IllAnger
  module Adapters
    module Radarr

      def self.new
        Base.new
      end

      class Base

        attr_accessor :connected

        def initialize
          IllAnger::LOGGER.debug "Initialising Radarr adapter"

          @config = IniFile.load(File.join(IllAnger::CONFIG_DIR, "radarr.ini"))
          @client = Radarr::Client.new

          system_status = @client.check_system_status # Ensure that a connection to the server can be made

          @connected = (not system_status[:error])

        end

        def add_to_wanted movie
          IllAnger::LOGGER.debug "Adding #{movie[:title]} (#{movie[:year]}) to wanted list"

          # Get id from TMDB
          #
          tmdb_Id = TheMovieDatabaseAdapter.get_id movie[:title], movie[:year]
          image_url = TheMovieDatabaseAdapter.get_poster_url tmdb_Id

          params = {
              title: movie[:title],
              year: movie[:year].to_i,
              qualityProfileId: @config[:movies]['quality_profile_id'],
              profileId: @config[:movies]['profile_id'],
              tmdbid: tmdb_Id.to_i,
              titleSlug: "#{movie[:title]}-#{tmdb_Id}",
              monitored:true,
              images: [{
                           coverType: 'poster',
                           url: image_url
                       }],
              rootFolderPath: @config[:movies]['root_dir']
          }

          if tmdb_Id and image_url
            response = @client.post("/movie", params)

            p response
            p response[:error]

            if response[:error]
              message = JSON.parse response[:message], {:symbolize_names => true}

              IllAnger::LOGGER.warn "Unable to add #{movie[:title]} (#{movie[:year]}) to wanted list:"
              IllAnger::LOGGER.warn "\t#{message[0][:errorMessage]}"
            else
              IllAnger::LOGGER.info "#{movie[:title]} (#{movie[:year]}) added to wanted list"
            end
          else
            IllAnger::LOGGER.warn "Unable to add #{movie[:title]} (#{movie[:year]}) to wanted list:"
            IllAnger::LOGGER.warn "\tUnable to find imdbid or image url"
            IllAnger::LOGGER.warn "\tTMDB id: #{tmdb_Id || 'nil'}"
            IllAnger::LOGGER.warn "\tImage url: #{image_url || 'nil'}"

            { error: true, message: "Unable to load movie info" }
          end
        end

        def get_known_movies
          IllAnger::LOGGER.debug "Getting known movie list"

          response = @client.get('/movie')

          if response[:error]
            IllAnger::LOGGER.warn "Failed to retrieve known movie list"
            IllAnger::LOGGER.warn response[:message]

            Array.new
          else
            IllAnger::LOGGER.debug "Known movie list retrieved"

            response[:message]
          end
        end
      end
    end
  end
end
