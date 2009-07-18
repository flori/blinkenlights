#!/usr/bin/env ruby

require 'blinkenlights'
include BlinkenLights::Constants

proc_net_dev = '/proc/net/dev'
dev = ARGV.shift || 'eth0'

bl = BlinkenLights.new(ARGV.shift || '/dev/tty8')
trap(:INT) do
  bl.close if bl
  exit
end

old_rx, old_tx = 0, 0
loop do
  bl.off
  line = File.read(proc_net_dev).grep(/#{dev}:/)
  line.empty? and fail "Unknown device #{dev} in #{proc_net_dev}"
  parts = line[0].scan(/\s+\d+/)
  rx, tx = parts[0].to_i, parts[8].to_i
  bl.digital = case [ rx != old_rx, tx != old_tx ]
  when [  true, true  ] then LED_ALL
  when [ false, true  ] then LED_RIGHT
  when [  true, false ] then LED_LEFT
  else                       0
  end
  old_rx, old_tx = rx, tx
end
