require 'sinatra'
require 'pi_piper'

class RelayAPI < Sinatra::Base
  include PiPiper

  PINS = [17,8,27,22,23,24, 25, 04]
  PINS.each_with_index do |pin_id, index|
    eval("PIN_#{index} = PiPiper::Pin.new(pin: #{pin_id}, direction: :out)")
  end

  get '/' do
    "RPI Relay API"
  end

  get '/status' do
    puts "Pin #{PIN_0.inspect} is #{convert_on_off(PIN_0.read)}"
    200
  end

  post '/change/:pin_number/:action' do
    selected_pin = eval("PIN_#{params[:pin_number]}")
    return 200 if change_pin(selected_pin, params[:action])
    400
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
