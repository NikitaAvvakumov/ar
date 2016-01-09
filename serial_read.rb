# script to fine-tune use of rubyserial gem

require 'rubyserial'

def read_serial
  50.times do
    serial = Serial.new "/dev/cu.usbmodem1411", 9600
    readout = serial.read(30)
    p readout
    value = readout[/(?<=Readout: )\d*(?= units)/]
    if value
      sleep 10
    end
  end
end

read_serial
