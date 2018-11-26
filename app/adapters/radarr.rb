Dir['./adapters/radarr/*.rb'].each { |file| require file }


module IllAnger
  module Adapters
    module Radarr
      def self.new
        Adapters::Radarr::Base.new
      end
    end
  end
end