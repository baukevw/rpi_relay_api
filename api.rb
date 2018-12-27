require 'sinatra'
require 'json'
require 'pi_piper'
require 'httparty'
require 'dotenv'

class RelayAPI < Sinatra::Base
  Dotenv.load

  before do
    halt 401 unless request.env["HTTP_AUTHORIZATION"] == ENV['AUTHORIZATION_KEY']
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

  post '/api/change/' do
    selected_pin = eval("PIN_#{params[:pin_number]}")
    if change_pin(selected_pin, params[:action])
      send_notification(params[:pin_number], params[:action])
      status 200
      return { 'Status' => '200' }.to_json
    else
      send_notification(params[:pin_number], params[:action])
      status 400
      return { 'Status' => '400' }.to_json
    end
  end

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
