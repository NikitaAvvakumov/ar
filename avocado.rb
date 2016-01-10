require 'yaml'
require 'adafruit/io'
require 'rubyserial'

SENSOR_UPPER_LIMIT = 800

def read_and_publish
  serial = set_serial
  return unless serial

  while true do
    # Arduino prints to serial port messages in the format
    # "soil moisture xxx.xx%, air temp xxx.xxC." with \r\n between lines.
    # To ensure that the regex can always match, need to read 60 characters to
    # account for the worst-case scenario:
    # "oisture xxx.xx%, air temp xxx.xxC.\r\nsoil moisture xxx.xx%"
    serial_out = serial.read(60)
    soil = serial_out[/(?<=moisture )\d{1,3}\.\d{1,2}(?=%)/]
    air_temp = serial_out[/(?<=temp )-?\d{1,3}\.\d{1,2}(?=C)/]
    if soil && air_temp
      publish_to_aio(soil, feed: "avocado-soil-moisture")
      publish_to_aio(air_temp, feed: "avocado-air-temp")
      sleep 30
    end
  end
end

def publish_to_aio(value, feed:)
  aio_feed = get_aio_feed(feed)
  begin
    aio_feed.data.create({ value: value })
    puts "Published #{value} to #{feed}"
  rescue => e
    # adafruit-io's exceptions are undocumented,
    # therefore rescuing from everything
    puts "Unable to publish #{value} to #{feed}: #{e.message}"
  end
end

def get_aio_feed(feed)
  set_aio_client
  @aio_client.feeds(feed)
end

def set_aio_client
  @aio_key ||= YAML.load_file("aio_key.yml")["aio_key"]
  @aio_client ||= Adafruit::IO::Client.new key: @aio_key
end

def set_serial
  if host_is_osx?
    set_osx_serial
  elsif host_is_linux?
    set_linux_serial
  else
    puts "Unsupported OS"
    false
  end
end

def host_is_osx?
  if RUBY_PLATFORM =~ /darwin/
    puts "OS X detected"
    true
  end
end

def host_is_linux?
  if RUBY_PLATFORM =~ /linux/
    puts "Linux detected"
    true
  end
end

def set_osx_serial
  # on OS X, address of serial port seems to alter between these two values
  # when Arduino is reconnected
  begin
    Serial.new "/dev/cu.usbmodem1411", 9600
  rescue RubySerial::Exception
    Serial.new "/dev/cu.usbmodem1421", 9600
  end
end

def set_linux_serial
  Serial.new "/dev/ttyACM0", 9600
end

read_and_publish
