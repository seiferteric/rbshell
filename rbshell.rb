#!/usr/bin/ruby


require_relative 'rbshell.rb'
require "readline"
require 'socket'
require 'etc'
require 'magic'
require 'ptools'

module RbShell
  @@last_pwd = nil
  class Shell
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

    class Command < Shell
      def ls(path=".")
        #paths = Dir.glob(File.expand_path(path))
        #if paths.length > 1
        #  Dir.glob(File.expand_path(path)).sum([]) do |f|
        #    f
        #  end

        #end
        #Dir.glob(File.expand_path(path)).sum([]) do |f|
        #  #if File.directory?(f)
        #  #  [Dir.entries(f)]
        #  #else
        #  #  [f]
        #  #end
        #  [f]
        #end
        Dir.entries(File.expand_path(path))

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
end

shell = RbShell::Shell.new


while buf = Readline.readline(Etc.getlogin + "@" + Socket.gethostname + ":" + Dir.pwd + "$ ", true)
  begin
    if !buf.empty?
      r = shell.run(buf)
      if r != nil
        pp r
      end
    end
  rescue Exception => e
    p "invalid command: " + e.to_s
  end

end
