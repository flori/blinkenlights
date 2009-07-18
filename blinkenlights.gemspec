# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  s.name = 'blinkenlights'
  s.version = '0.1.0'
  s.summary = 'Control the Blinkenlights on your keyboard with Ruby'
  s.description =
    'This library allows you to turn the keyboard LEDs on and of with Ruby.'

  s.files = ["CHANGES", "COPYING", "README", "Rakefile", "VERSION", "blinkenlights.gemspec", "examples", "examples/loadbar.rb", "examples/netblinker.rb", "install.rb", "lib", "lib/blinkenlights", "lib/blinkenlights.rb", "lib/blinkenlights/version.rb", "make_doc.rb", "tests", "tests/test.rb"]

  s.require_path = 'lib'

  s.has_rdoc = true
  s.rdoc_options << '--title' <<  'BlinkenLights in Ruby' << '--main' << 'doc-main.txt'
  s.extra_rdoc_files << 'doc-main.txt'
  s.test_files << 'tests/test.rb'

  s.author = "Florian Frank"
  s.email = "flori@ping.de"
  s.homepage = "http://blinkenlights.rubyforge.org"
  s.rubyforge_project = "blinkenlights"
end
