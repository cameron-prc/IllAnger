Dir.chdir __dir__

require 'inifile'
require 'logger'

Dir['./core/*.rb'].each { |file| require file }
Dir['./processors/*.rb'].each { |file| require file }
Dir['./services/*.rb'].each { |file| require file }
Dir['./adapters/*.rb'].each { |file| require file }
Dir['./errors/*.rb'].each { |file| require file }

module IllAnger

  CONFIG_DIR = File.join(File.expand_path('..'), '/config')

  LOGGER = Logger.new(File.join(File.expand_path('..'), '/log/log.txt'))#


  def self.new
    IllAnger::Base.new
  end

end

IllAnger.new