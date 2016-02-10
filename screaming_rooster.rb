# require 'sinatra'
puts 'starting the app..'

require 'httparty'
require 'eventmachine'
require 'em-http'
require 'json'

$api_token = ENV['fd_api_token']
$organization = 'redant'
$flow = 'public-release'

http = EM::HttpRequest.new("https://stream.flowdock.com/flows/#{$organization}/#{$flow}",
                            :keepalive => true,
                            :connect_timeout => 0,
                            :inactivity_timeout => 0
)

class FlowdockResponse
  def initialize(json)
    @title = json['thread']['title'] if json['thread']
  end

  def chicken?
    if @title
      @title.match /:rubber-chicken:/
    end
  end
end

class MikeMachine
  include HTTParty
  base_uri 'http://192.168.2.59'

  def self.rock_on(track = 1)
    get("/play?track=#{track}")
  end

  def self.noize(level = 20)
    get("/level?level=#{level}")
  end

end

EventMachine.run do
  stream = http.get(:head => {
    'Authorization' => [$api_token, ''],
    'accept' => 'application/json'
  })

  buffer = ''

  stream.stream do |chunk|
    buffer << chunk
    while line = buffer.slice!(/.+\r\n/)
      response = FlowdockResponse.new(JSON.parse(line))
      if response.chicken?
        MikeMachine.noize
        MikeMachine.rock_on
      end
    end
  end

end
