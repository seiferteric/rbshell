require 'ripper'
require 'reline'
require 'irb/ruby-lex'
require 'socket'
require 'etc'
require 'magic'
require 'ptools'
require 'colorize'

HOME = File.expand_path("~")
def reduce_path(path)
  if path.start_with? HOME
    return "~" + path[HOME.length..]
  end
  path
end

$config_path = File.expand_path("~/.rbshellrc")
$prompt = Etc.getlogin + "@" + Socket.gethostname.split('.')[0] + ":" + reduce_path(Dir.pwd) + ":$ "
$prompt_proc = Proc.new {|buf| [$prompt, "> "]}


if File.exists? $config_path
  eval(File.open($config_path).read)

end

Reline.prompt_proc = $prompt_proc
Reline.completion_proc = Proc.new { |buf|
    RbShell::Command.instance_methods(false).filter {|m| m.start_with? buf.split[0]}.map {|m| m.to_s}
}

class TerminationChecker < RubyLex
  def terminated?(code)
    code.gsub!(/\n*$/, '').concat("\n")
    @tokens = Ripper.lex(code)
    continue = process_continue
    code_block_open = check_code_block(code)
    indent = process_nesting_level
    ltype = process_literal_type
    if code_block_open or ltype or continue or indent > 0
      false
    else
      true
    end
  end
end

#Do we need the result classes? Or just use raw array, hash, string etc. ?
class Result
  attr_accessor :command, :args
  def initialize()
    yield self
  end
  protected

  attr_reader :data
end

class ResultArray < Result
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
  def method_missing(c, *args)
    data.method(c).call(*args)
  end
end

class ResultString < Result
  def initialize(str)
    @data = String.new(str)
  end
  def +(other)
    self.class.new(data + other)
  end
  def to_s
    data
  end
  def method_missing(c, *args)
    data.method(c).call(*args)
  end
  protected

  attr_reader :data
end

$last_pwd = nil
$exec_path = nil
class RbShell

  def initialize(path)
    $exec_path = path

  end
  def start
    checker = TerminationChecker.new
    code = ""
    while code
      case code.chomp
      when ''
        # NOOP
      else
        begin
          r = self.run(code)
          if r != nil
            #Explicit call to .to_s for array...
            puts (r.to_s)
          end
        rescue ScriptError, StandardError => e
          puts "Traceback (most recent call last):"
          e.backtrace.reverse_each do |f|
            puts "        #{f}"
          end
          puts e.message
        end
      end
      #Need this because it seems to crash on single backspace
      begin
        code = Reline.readmultiline(nil, true) { |code| checker.terminated?(code) }
      rescue
        code = ""
      end
    end
    puts
  end
  def run(str)
    #args = str.split
    #args[1..] = args[1..].map {|a| "'" + a + "'"}
    cur_pwd = Dir.pwd
    com = Command.new
    # ret = com.instance_eval(args.join(' '))
    ret = com.instance_eval(str)
    
    if Dir.pwd != cur_pwd
      $last_pwd = cur_pwd
    end
    return ret
  end

  class Command
    def ls(path=".")
      data = Dir.entries(File.expand_path(path))#.sort
      ResultArray.new(data) do |r|
        r.args = {command: 'ls', path: path}
        @result = r
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
          if $last_pwd
            Dir.chdir(File.expand_path($last_pwd))
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
    def echo(str="", n=false)
      if n
        print str
      else
        puts str
      end
      nil
    end
    def cat(path)
      data = ""
      Dir.glob(File.expand_path(path.to_s)).each { |f| data += File.open(f).read}
      ResultString.new(data) do |r|
        r.args = {command: 'cat', path: path}
        @result = r
      end
    end
    def sh(cmd)
      system(cmd)
    end
    def exit
      exit!
    end
    def reload
      exec("ruby #{$exec_path}")
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
    
    protected

    attr_reader :result
    
  end
end


class Hash
  def [](key)
    if key.is_a? String
      return (fetch key.to_sym, nil)     
    else
      return (fetch key, nil)
    end
  end

  def []=(key,val)
    if (key.is_a? String) || (key.is_a? Symbol) #clear if setting str/sym
        self.delete key.to_sym
        self.delete key.to_s
    else
      self.delete key
    end
    merge!({key => val})
  end
end


