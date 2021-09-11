#!/usr/bin/ruby
module RbShell
  @@last_pwd = nil
  class Shell
    def run(str)
      cur_pwd = Dir.pwd
      com = Command.new
      ret = com.instance_eval(str)
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
        File.unlink(Dir.glob(File.expand_path(path)))
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
      def method_missing(c)
        #Should return an error class with to_c of "command not found" instead
        "command not found"
      end
    end
  end
end

