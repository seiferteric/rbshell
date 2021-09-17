#!/usr/bin/ruby

require 'magic'
require 'ptools'

class Result
  attr_accessor :command, :args, :data
  def initialize()
    yield self
  end
end

class ResultArray < Result
  # include Result
  include Enumerable
  def initialize(n)
    @data = Array.new(n)
    super()
  end
  def +(other)
    self.class.new(data + other.data)
  end

  def each(*args, &block)
    data.each(*args, &block)
  end
end

class RbShell
  @last_pwd = nil
  def run(str)
    args = str.split
    args[1..] = args[1..].map {|a| "'" + a + "'"}
    cur_pwd = Dir.pwd
    com = Command.new
    ret = com.instance_eval(args.join(' '))
    if Dir.pwd != cur_pwd
      @@last_pwd = cur_pwd
    end
    return ret
  end

  class Command
    def ls(path=".")
      data = Dir.entries(File.expand_path(path))#.sort

      ResultArray.new(data) do |r|
        r.args = {command: 'ls', path: path}
        class << r
          def to_s
            data.join(" ")
          end
        end
      end
    end

    def rm(path)
      File.unlink(File.expand_path(path))
    end
    def touch(path)
      open(Dir.glob(File.expand_path(path)), "w").close
    end
    def cd(path=nil)
      if path
        if path == "-"
          if @@last_pwd
            Dir.chdir(File.expand_path(@@last_pwd))
          end
        else
          Dir.chdir(File.expand_path(path))
        end
      else
        Dir.chdir
      end
      return nil
    end
    def pwd
      Dir.pwd
    end
    def file(path)
      Magic.guess_file_mime(File.expand_path(path))
    end
    def echo(str)
      p str
    end
    def sh(cmd)
      system(cmd)
    end
    def exit
      exit!
    end
    def reload
      exec File.join(__dir__, File.basename($0))
    end
    def method_missing(c, args="")
      cmd = c.to_s.split
      if File.which(cmd[0])
        system(c.to_s + ' ' + args)
      else
        #Should return an error class with to_c of "command not found" instead
        "command not found"
      end

    end
  end
end


