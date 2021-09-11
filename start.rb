#!/usr/bin/ruby

require_relative 'rbshell.rb'
require "readline"
while buf = Readline.readline("> ", true)
  begin
    p RbShell.run buf
  rescue => e
    p "invalid command: " + e.to_s
  end

end

