==================================
==================================
==========   README   ============
==================================
==================================

8 Queens (Homework Assignment #1)

==================================

Author Name:  Ibrahim Sardar
Program Name: 8queens.rb
Program Date: 02/07/2017

==================================

Language: Ruby 2.3.3p222
 - Compatible Versions: Ruby 2.3 or higher
 - Website: https://www.ruby-lang.org/en/

Libraries: Gosu
 - Website: https://www.libgosu.org/ruby.html

==================================

Setup Instructions:

----- Windows: (easiest) -----

 > If you don't have Ruby version 2.3 or higher...

	a) download installer from "https://www.ruby-lang.org/en/downloads/" (version 2.3 or higher)

 > If you don't have Gosu installed (you probably don't)

	a) open up windows powershell
	b) type in  "ruby -v"  to make sure you have the correct version of ruby
	c) type in  "gem install gosu"
	
	if you have any trouble) check out: "https://www.libgosu.org/ruby.html"

----- Mac/Linux -----

 > Since I don't own a Mac or a Linux PC, I can only direct you to helpful instruction pages:

	for Ruby 2.3+) download installer from: "https://www.ruby-lang.org/en/downloads/"
	for Ruby setup tips) check out: "https://learnrubythehardway.org/book/ex0.html"

	for Gosu on Mac) check out: "https://github.com/gosu/gosu/wiki/Getting-Started-on-OS-X"
	for Gosu on Linux) check out: "https://github.com/gosu/gosu/wiki/Getting-Started-on-Linux"

==================================

Run Instructions:

 > Open Powershell/Terminal:

 > "cd" into the directory with my program and its resource files

 > Now you have some options:

	> type in "ruby 8queens.rb random <N> <SEED>"
	 where <N> is the number of queens you want and
	 <SEED> is the random seed. (default is N=8,SEED=0)

	> OR, you can type in "ruby 8queens.rb <x0,y0>...<x1,y1>...<x2,y2>...etc"
	 where <x0,y0> is the first queens position on the board
	 and <x1,y1> is the second queen's position on the board and so on.
	 
	 ...An example would like so: "ruby 8queens.rb 0,0...1,0...2,0"
	 This will make a 3x3 board and place 3 queens along the top row initially

==================================

Output:

 > Output will include:

	a) visual aid of board and queens
	b) visual aid with number of queen moves (moves limited to 333)
	c) visual aid with number of queens placed
	d) output of the queen coordinates (final state)
	e) output if the solution could be found

==================================

I can be emailed if any technical issues arise at:  ibrysar@gmail.com

Thanks For All The Help Mr.Saha and Dr.Hasan !!
