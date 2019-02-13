require 'net/http'
require 'json'
require 'open-uri'
require 'rest-client'

module IllAnger
  module Adapters
    module Radarr
      class Client
        def initialize

          @config = IniFile.load(File.join(IllAnger::CONFIG_DIR, 'radarr.ini'))

          method = @config[:client]['protocol']
          host_address = @config[:client]['host_address']
          port = @config[:client]['host_port']
          api_root = @config[:client]['api_root']
          api_key = @config[:client]['api_key']

          @root_url = "#{method}://#{host_address}:#{port}/#{api_root}"
          @api_auth_query_string = "?apikey=#{api_key}"
        end

        def check_system_status

          uri = uri_builder('/system/status')
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Get.new(uri.request_uri)

          response = begin
            http.request(request)
          rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
            IllAnger::LOGGER.error "Unable to connect to Radarr server: #{e.class}"
          end

          { error: !(response.kind_of? Net::HTTPSuccess) }

        end

        def post(url, params)

          uri = uri_builder(url)
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
          request.body = params.to_json

          response = http.request(request)


          if response.kind_of? Net::HTTPSuccess

            { error: false, code: response.code }

          else

            data = JSON.parse(response.body, {:symbolize_names => true})[0]

            { error: true, code: response.code, message: data[:errorMessage] }

          end


        end

        def get(url)

          uri = uri_builder(url)
          http = Net::HTTP.new(uri.host, uri.port)

          request = Net::HTTP::Get.new(uri.request_uri)
          response = http.request(request)

          data = JSON.parse response.body, {:symbolize_names => true}

          if response.kind_of? Net::HTTPSuccess

            { error: false, code: response.code, data: data }

          else

            { error: true, code: response.code, message: data[0][:errorMessage] }

          end

        end

        private

        def uri_builder(url)
          URI.parse("#{@root_url}#{url}#{@api_auth_query_string}")
        end

        def construct_error_message(code)
          "Radarr server returned a #{code} response"
        end

      end
    end
  end
end