require 'adafruit/io'
require 'rubyserial'

def read_and_publish
  avocado_feed = get_feed
  serial = set_serial
  return unless serial

  negative_readings = 0
  while true do
    reading = serial.read(20)[/(?<=Readout: )\d*(?= units)/]
    if reading
      puts "Sensor read as #{reading} after #{negative_readings} negatives"
      avocado_feed.data.create({ value: reading })
      sleep 10
      negative_readings = 0
    end
    negative_readings += 1
  end
end

def get_feed
  aio = Adafruit::IO::Client.new key: "71ff75e6dc663f6f4c7c31b262a6499e773c4a55"
  aio.feeds("avocado-soil-moisture")
end

def set_serial
  if osx?
    Serial.new "/dev/cu.usbmodem1411", 9600
  elsif linux?
    Serial.new "/dev/ttyACM0", 9600
  else
    puts "Unsupported OS"
    false
  end
end

def osx?
  if RUBY_PLATFORM =~ /darwin/
    puts "OS X detected"
    true
  end
end

def linux?
  if RUBY_PLATFORM =~ /linux/
    puts "Linux detected"
    true
  end
end

read_and_publish
