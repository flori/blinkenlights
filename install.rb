#!/usr/bin/env ruby

require 'rbconfig'
require 'fileutils'
include FileUtils::Verbose
include Config

dest = CONFIG["sitelibdir"]
mkdir_p(dest)
file = 'lib/blinkenlights.rb'
install(file, dest)
