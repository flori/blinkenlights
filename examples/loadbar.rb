#!/usr/bin/env ruby

require 'blinkenlights'
include BlinkenLights::Constants

proc_loadavg = '/proc/loadavg'

bl = BlinkenLights.new(ARGV.shift || '/dev/tty8')
trap(:INT) do
  bl.close if bl
  exit
end

bl.off
loop do
  loadavg = File.read(proc_loadavg).scan(/\d+\.\d+/)[0].to_f
  case loadavg
  when 0.00..0.25 then  bl.digital = 0
  when 0.25..0.50 then  bl.digital = LED_LEFT
  when 0.50..0.75 then  bl.digital = LED_LEFT | LED_MIDDLE
  when 0.75..1.00 then  bl.digital = LED_LEFT | LED_MIDDLE | LED_RIGHT
  when 1.00..2.00 then  bl.off ; bl.digital = LED_RIGHT
  when 2.00..3.00 then  bl.off ; bl.digital = LED_RIGHT | LED_MIDDLE
  else                  bl.flash
  end
end
