#!/usr/bin/env ruby

start_script = ENV.fetch('START_SCRIPT', 'linael_test')
system("./bin/#{start_script}")
