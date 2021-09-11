#!/usr/bin/ruby

require_relative 'rbshell.rb'
require "readline"
shell = RbShell::Shell.new
while buf = Readline.readline("> ", true)
  begin
    if !buf.empty?
      r = shell.run(buf)
      if r != nil
        pp r
      end
    end
  rescue => e
    p "invalid command: " + e.to_s
  end

end

