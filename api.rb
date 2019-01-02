require 'sinatra'
require 'sinatra/cross_origin'
require 'json'
require 'pi_piper'
require 'httparty'
require 'dotenv'
require 'logger'

FILE = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
LOGGER = Logger.new(FILE)

class RelayAPI < Sinatra::Base
  Dotenv.load

  configure do
    enable :logging
    enable :cross_origin

    FILE.sync = true
    use Rack::CommonLogger, FILE

    LOGGER.formatter = proc do |severity, datetime, progname, msg|
       "LOG: #{msg}\n"
    end
  end

  before do
    response.headers["Access-Control-Allow-Origin"] = "*"

    if request.request_method == 'OPTIONS'
      response.headers["Access-Control-Allow-Methods"] = ["GET", "POST"]
      response.headers["Access-Control-Allow-Headers"] = ["Authorization", "Content-Type"]
      halt 200
    end
    content_type :json
    halt 401, { 'Status' => '401' }.to_json unless request.env["HTTP_AUTHORIZATION"] == ENV['AUTHORIZATION_KEY']
  end

  include PiPiper

  PINS = [17,18,27,22,23,24,25,4]

  PINS.each_with_index do |pin_id, index|
    eval("PIN_#{index} = PiPiper::Pin.new(pin: #{pin_id}, direction: :out)")
    eval("PIN_#{index}.on")
  end

  get '/api/status/' do
    output = Hash.new
    PINS.each_with_index do |pin_id, index|
      output.store(index.to_s, eval("PIN_#{index}").read.to_s)
    end
    output.to_json
  end

  get '/api/status/pin/' do
    payload = params
    payload = JSON.parse(request.body.read, symbolize_names: true) unless params[:path]

    output = Hash.new
    selected_pin = eval("PIN_#{payload[:pin_number]}")
    output.store(payload[:pin_number], convert_on_off(selected_pin.read.to_s))
    output.to_json
  end

  post '/api/change/' do
    payload = params
    payload = JSON.parse(request.body.read, symbolize_names: true) unless params[:path]

    selected_pin = eval("PIN_#{payload[:pin_number]}")
    if change_pin(selected_pin, payload[:action])
      send_notification(payload[:pin_number], payload[:action])
      status 200
      return { 'Status' => '200' }.to_json
    else
      send_notification(payload[:pin_number], payload[:action])
      status 400
      return { 'Status' => '400' }.to_json
    end
  end

  private

  def change_pin(selected_pin, action)
    if action == 'on'
      selected_pin.off
      return true
    end
    if action == 'off'
      selected_pin.on
      return true
    end
    false
  end

  def convert_on_off(value)
    return 'on' if value == 0
    'off'
  end

  def send_notification(pin, action)
    HTTParty.post(
        ENV["NOTIFY_WEBHOOK_URL"],
        { :body => { "rpi_relay_api" => { "type" => "change", "pin_number" => "#{pin}", "action" => "#{action}" }}}
      )
  end
end
