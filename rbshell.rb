#!/usr/bin/ruby

module RbShell

  def self.run(str)
    com = Command.new
    com.instance_eval(str)
  end

  class Command
    def ls(path)
      paths = Dir.glob(File.expand_path(path))
      if paths.length > 1
        Dir.glob(File.expand_path(path)).sum([]) do |f|

      end
      Dir.glob(File.expand_path(path)).sum([]) do |f|
        #if File.directory?(f)
        #  [Dir.entries(f)]
        #else
        #  [f]
        #end
        [f]
      end

    end
    def rm(path)
      File.unlink(Dir.glob(File.expand_path(path)))
    end
    def touch(path)
      open(Dir.glob(File.expand_path(path)), "w").close
    end
    def cd(path)
      Dir.chdir(Dir.glob(File.expand_path(path)))
    end
    def pwd
      Dir.pwd
    end
    def method_missing(c)
      #Should return an error class with to_c of "command not found" instead
      "command not found"
    end
  end

end

