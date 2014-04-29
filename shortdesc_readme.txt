Name: shortdesc.rb
Description: Parses main ditamap extracting all <shortdesc> elements in each topic.
Written by: Wayne Brissette (wayne.brissette@arm.com)
Version: 1.0
Date: 2014-04-24
Changes: 1.0 - Initial Version
v1.1 - Removed DITA ID and replaced with permissions since CCMS ID and filename match.


shortdesc.rb 
===========

shortdesc.rb is a Ruby script enabling ARM authors to get all <shortdesc> elements in a map in a single text, html, or tab separated values file (excel). This enables you to quickly scan your topics and view the short descriptions in an entire map. You can quickly identify missing short descriptions and short descriptions that need improving. 

In order to use this script, you must export your DITA bookmap from the DITA CMS. 

Prerequisites
-------------

* Ruby 1.9.x or Ruby 2.x
* Ruby gems: nokogiri
             htmlentities

Installing Ruby (Windows)
-------------------------

1: Download Ruby 1.9.x or Ruby 2.x from rubyinstaller.org
   Link - http://rubyinstaller.org/downloads/ 
		
2: Run the Ruby installer.
   Note- Select 'Add Ruby executables to your PATH' and 'Associate .rb and .rbw files with this Ruby installation.

3: Open either Windows PowerShell or the Windows Command Prompt. 

4: Test to ensure Ruby was properly installed by entering the following at the prompt: ruby -v
   If properly installed, the version of Ruby installed appears. If you receive an error about Ruby not being recognized, then ruby needs to be added to your PATH. 
   
Note: For Mac OS X, I recommend you use the RVM package manager. 
https://www.ruby-lang.org/en/installation/#rvm

Installing Ruby Gems
---------------------

Two Ruby gems are used by shortdesc.rb. 

1 - htmlentities: used for converting html code like &gt; into >
2 - nokogiri: used for xpath processing.

: Install both the htmlentities and nokogiri gem by entering the following at the prompt: gem install nokogiri htmlentities

This installs all the required software on your computer. 


Exporting the DITA bookmap
---------------------------

1: Right-click the bookmap from within the DITA Maps pane of DITA CMS.

2: Choose Generate Output... from the contextual menu.

3: Choose ARM-export from the Generate Output dialog.

4: Use the following options on the Generate Output dialog:
   a: Customer Source?      Choose YES
   b: Export Images?        Choose NO    (default)
   c: Keep conrefs?         Choose NO    (default)
   d: Keep draft-comments?  Choose NO    (default)
   
5: Click the Create button.

6: Choose an output directory when prompted.


Using the Script
----------------

1: Extract the files in the exported DITA zip file

2: Open a command prompt

3: Type: ruby shortdesc.rb [option] [ditamap]

    output formatting options
    -------------------------
    -t  : plain text format (.txt)
    -x  : Excel/tab separated values file  (.tsv)
    -w  : web/html format (.htm)
    
    If no option is selected, an html file is used.
    
Tip: You may find that you have to provide the path to the ruby script and ditamap depending on your current location in the file system. An easy way to provide the path is to use drag-and-drop from the Windows explorer to the command window. 

For example, just type: ruby[space], then locate the shortdesc.rb script using the Windows explorer GUI and drag it into the command prompt window. Add a space, then type the option you want to use, then add another space. Locate the bookmap you want to process and drag it into the command window. Then the only thing you need to do is press the return key. 

All outputs are placed in the same directory as your source files and are named like this: 

- bookmapid_shortdesc.[ext]

Example: lou1375305364946_shortdesc.htm





