require 'sinatra'
require 'pi_piper'


class RelayAPI < Sinatra::Base
  include PiPiper

  PIN = PiPiper::Pin.new(:pin => 17, :direction => :out)


  get '/' do
    "RPI Relay API"
  end

  get '/status' do
    "Status"
  end

  post '/change/:pin_number/:action' do
    change_pin(PIN, params[:action])
  end

  def change_pin(pin, action)
    if action == 'on'
      pin.on
    else
      pin.off
    end
  end
end
