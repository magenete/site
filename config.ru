#
# Copyright (c) 2015 Magenete Systems OÜ <magenete.systems@gmail.com>.
#

require 'rubygems'
require "#{File.dirname(File.expand_path(__FILE__))}/lib/magenete"


MAGENETE.init

if File.expand_path($0) == File.expand_path(__FILE__)
  MAGENETE::Application.run!
else
  run MAGENETE::Application
end
