require 'sinatra'
require 'pi_piper'

# Sinatra configuration
configure do
  set :views, File.join(Sinatra::Application.root, "views")
  Tilt.register Tilt::ERBTemplate, 'html.erb'
end

class RelayAPI < Sinatra::Base
  include PiPiper

  PINS = [17,18,27,22,23,24,25,04]
  PINS.each_with_index do |pin_id, index|
    eval("PIN_#{index} = PiPiper::Pin.new(pin: #{pin_id}, direction: :out)")
  end

  get '/' do
    erb :index
  end

  get '/status' do
    erb :status
  end

  post '/change/' do
    selected_pin = eval("PIN_#{params[:pin_number]}")
    if change_pin(selected_pin, params[:action])
      200
      return { 'Status' => '200' }
    else
      400
      return { 'Status' => '400' }
    end
  end

  def change_pin(selected_pin, action)
    if action == 'on'
      selected_pin.on
      return true
    end
    if action == 'off'
      selected_pin.off
      return true
    end
    false
  end

  def convert_on_off(value)
    return 'on' if value == 1
    'off'
  end
end
