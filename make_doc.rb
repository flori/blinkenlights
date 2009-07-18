#!/usr/bin/env ruby

require 'rbconfig'
bindir = Config::CONFIG['bindir']

system "#{bindir}/ruby #{bindir}/rdoc -d -m doc-main.txt doc-main.txt lib/blinkenlights.rb"
