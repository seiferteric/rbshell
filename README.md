# RbShell

This is an experiment to see if I can turn a ruby [DSL](https://en.wikipedia.org/wiki/Domain-specific_language) into a fully fledged linux/unix system shell. The idea is that I can replace most linux/unix commands with custom methods that will return ruby objects. This will allow you to operate on these returned objects instead of parsing strings like you normally do in bash etc.

There is a lot of talk of wanting a new kind of shell that supports structured data à la PowerShell (which is available for Linux) but not PowerShell... Anyway, it seems that writing a shell is hard... Even harder is that all the existing shell utilities output text, not structured data, so you would either need to have some sort of parsing templates for these, or just re-implement them all... I made this project because I knew ruby was good at DSLs and I thought it was a good and simple place to start instead of re-implementing everything (parsing lexing etc) and I like ruby for quick one-liner type scripts anyway so it seems like a good fit. 

This shell aims to re-implement all common unix/linux utilities as internal functions, but will still allow you to run utilities that are not included, you will just get back a blob of text instead of a structured object.


## Install

    git clone https://github.com/seiferteric/rbshell.git
    cd rbshell
    gem install bundler
    bundle install
    ./rbshell

## Usage

It is pretty rough right now, but you can see the basic idea:

	eseifert@gandalf:~/dev/rbshell:(master)$ ./rbshell 
	eseifert@gandalf:/home/eseifert/dev/rbshell$ ls
	["LICENSE",
	 "README.md",
	 ".gitignore",
	 "Gemfile",
	 "Gemfile.lock",
	 ".",
	 "..",
	 ".git",
	 "rbshell"]
	eseifert@gandalf:/home/eseifert/dev/rbshell$ ls.filter{|f|f.start_with?("G")}
	["Gemfile", "Gemfile.lock"]
	eseifert@gandalf:/home/eseifert/dev/rbshell$ pwd
	"/home/eseifert/dev/rbshell"
	eseifert@gandalf:/home/eseifert/dev/rbshell$ file rbshell
	"text/x-ruby; charset=us-ascii"
	eseifert@gandalf:/home/eseifert/dev/rbshell$ cd
	eseifert@gandalf:/home/eseifert$ pwd
	"/home/eseifert"
	eseifert@gandalf:/home/eseifert$ cd -
	eseifert@gandalf:/home/eseifert/dev/rbshell$ pwd
	"/home/eseifert/dev/rbshell"
	eseifert@gandalf:/home/eseifert/dev/rbshell$ 