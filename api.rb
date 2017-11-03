require 'sinatra'
require 'json'
require 'pi_piper'

# Sinatra configuration
configure do
  set :views, File.join(Sinatra::Application.root, "views")
  Tilt.register Tilt::ERBTemplate, 'html.erb'
end

class RelayAPI < Sinatra::Base
  include PiPiper

  PINS = [17,18,27,22,23,24,25,4]
  PINS.each_with_index do |pin_id, index|
    eval("PIN_#{index} = PiPiper::Pin.new(pin: #{pin_id}, direction: :out)")
    eval("PIN_#{index}.on")
  end

  get '/' do
    erb :index
  end

  get '/status' do
    erb :status
  end

  get '/api/status/' do
    output = Hash.new
    PINS.each_with_index do |pin_id, index|
      output.store(index.to_s, eval("PIN_#{index}").read.to_s)
    end
    output.to_json
  end

  post '/api/change/' do
    puts request.body
    selected_pin = eval("PIN_#{params[:pin_number]}")
    if change_pin(selected_pin, params[:action])
      status 200
      return { 'Status' => '200' }.to_json
    else
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
end
