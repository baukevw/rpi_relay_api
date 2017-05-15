require 'sinatra'
require 'pi_piper'

class RelayAPI < Sinatra::Base
  include PiPiper

  PINS = [17,8,27,22,23,24, 25, 04]
  PINS.each_with_index do |pin_id, index|
    eval("PIN_#{index} = PiPiper::Pin.new(pin: #{pin_id}, direction: :out")
  end

  get '/' do
    "RPI Relay API"
  end

  get '/status' do
    puts "Pin #{PIN_0.inspect} is #{convert_on_off(PIN_0.read)}"
    true
  end

  post '/change/:pin_number/:action' do
    change_pin(params[:pin_number].to_i, params[:action])
  end

  def change_pin(pin_number, action)
    if action == 'on'
      PIN_0.on
    else
      PIN_0.off
    end
  end

  def convert_on_off(value)
    return 'on' if value == 1
    'off'
  end
end
