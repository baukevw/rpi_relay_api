require 'bundler'
Bundler.setup
Bundler.require

class RelayAPI < Sinatra::Base

  PINS = [0, 1, 2, 3, 4, 5, 6, 7]

  IO = WiringPi::GPIO.new do |gpio|
    PINS.each do |pin|
      gpio.pin_mode(pin, WiringPi::OUTPUT)
    end
  end

  get '/' do
    "RPI Relay API"
  end

  get '/status' do
    PINS.each do |pin|
      puts "Pin #{pin} is #{convert_on_off(gpio_status(pin))}"
    end
    true
  end

  post '/change/:pin_number/:action' do
    change_pin(params[:pin_number], params[:action])
  end

  def gpio_status(pin_number)
    IO.digital_read(pin_number)
  end

  def change_pin(pin_number, action)
    if action == 'on'
      IO.digital_write(pin_number, WiringPi::HIGH)
    else
      IO.digital_write(pin_number, WiringPi::LOW)
    end
  end

  def convert_on_off(value)
    return 'on' if value == 1
    'off'
  end
end
