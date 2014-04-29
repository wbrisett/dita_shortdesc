# Name: shortdesc.rb
# Description: Parses main ditamap extracting all <shortdesc> elements in each topic.
# Written by: Wayne Brissette
# Version: 1.1
# Date: 2014-04-23
# Changes: Added Permissions, removed DITA ID since it is the same as the file name.


require 'nokogiri'
require 'optparse'
require 'htmlentities'
@coder = HTMLEntities.new



options = {}

 optparse = OptionParser.new do|opts|
   # Set a banner, displayed at the top
   # of the help screen.
   opts.banner = "Usage: shortdesc.rb [options] <path>/[main ditamap]"

   # Define the options, and what they do

   options[:html] = true
   opts.on( '-w', '--html', 'Write output to web/HTML file (default if no options are selected).' ) do
     options[:html] = true
   end

   options[:text] = false
   opts.on( '-t', '--text', 'Write output to text file.' ) do
     options[:text] = true
     options[:html] = false
   end

   options[:excel] = false
   opts.on( '-x', '--excel', 'Write output to CSV file.' ) do
     options[:excel] = true
     options[:html] = false
   end

    opts.on( '-h', '--help', 'Display this screen' ) do
     puts opts
     puts "\nFrom the command prompt in Windows (or terminal in linux/Unix) type:\n
ruby shortdesc.rb [options] <path>/[main ditamap]
\nNote: You may have to use a path in front of shortdesc.rb script and the ditamap file depending on where items are located on your computer."

     exit
    end

 end

optparse.parse!

def build_text
  @output=""
  @h_map=""
  @all_items_in_map.each_with_index do |entry, indx|
  spaces = (" " * (@map_h_array[indx]))
  @output = @output + "     Title: #{entry.title}\r File Name: #{entry.filename}\r  Doc Permission: #{entry.permission}\rTopic Type: #{entry.type}\r shortdesc: #{entry.shortdesc}\r\r"
  if indx == 0
  else
    @h_map = @h_map + "#{spaces}#{entry.title}\r"
  end

  end
  @output = "#{@all_items_in_map[0].title}\r--------------------------\r#{@h_map}\r\r============================\rEmpty Short Descriptions: #{@emptycount-1}\rTotal Number of Topics: #{@all_items_in_map.count-1}\r============================\r\r\r" + @output

end

def build_excel
  @output="Title\tFile Name\tDoc Permission\tTopic Type\tShort Description\r"
  @h_map=""
  @all_items_in_map.each_with_index do |entry, indx|
    spaces = (" " * (@map_h_array[indx]))
    entry.shortdesc.gsub!(/\t/, " ") if !entry.shortdesc.nil?
    @output = @output + "#{spaces}#{entry.title}\t#{entry.filename}\t#{entry.permission}\t#{entry.type}\t#{entry.shortdesc}\r"
  end
  @output = @output + "\rEmpty Short Descriptions: #{@emptycount-1}\t\t\t\t\rTotal Number of Topics: #{@all_items_in_map.count-1}\t\t\t\t\r"
end

def build_html
 @output = "
  <!DOCTYPE html>
  <html>
    <head>
      <meta content=\"text/html; charset=UTF-8\" http-equiv=\"content-type\">
      <title>#{@all_items_in_map[0].title} short descriptions</title>
      <style type=\"text/css\">
      #sd20140414 {
                   text-align: left;
                   font-family: Helvetica,Arial,sans-serif;
                   font-size: 10pt;
                   }
      #heading {
              text-align: center;
              color: white;
              font-weight: bold;
              background-color: #4571d3;
             }

      #white {
              background-color: white;
              vertical-align: top;
             }

      #l_blue {
              background-color: #B4CEFF;
              vertical-align: top;
              }

          </style>
        </head>
        <body>
          <table id=\"sd20140414\" border=\"1\" cellpadding=\"5\" cellspacing=\"0\">
            <thead id=\"heading\">
              <tr>
                <td style=\"width: 27%;\">Title</td>
                <td style=\"width: 10%;\">File Name</td>
                <td style=\"width: 9%;\">Doc Permission</td>
                <td style=\"width: 6%;\">Topic Type</td>
                <td style=\"width: 48%;\">Short Description</td>
              </tr>
            </thead>
            <tbody>"

   @all_items_in_map.each_with_index do |entry, indx|

     if indx == 0
       spaces = ""
     else
      spaces = ("&nbsp;" * (@map_h_array[indx]))
     end
   if (indx % 2 ==0) #even
     @output =  @output + "<tr><td id=\"white\">#{spaces}#{entry.title}</td><td id=\"white\">#{entry.filename}</td><td id=\"white\">#{entry.permission}</td><td id=\"white\">#{entry.type}</td><td id=\"white\">#{entry.shortdesc}</td></tr>\r"
   else  #odd
     @output =  @output + "<tr><td id=\"l_blue\">#{spaces}#{entry.title}</td><td id=\"l_blue\">#{entry.filename}</td><td id=\"l_blue\">#{entry.permission}</td><td id=\"l_blue\">#{entry.type}</td><td id=\"l_blue\">#{entry.shortdesc}</td></tr>\r"
   end

   end
  @output = @output + "
 <tr><td colspan=\"5\" style=\"background-color: #EEEEEE\"><b>Empty Topics: </b>#{@emptycount-1}</td></tr>
 <tr><td colspan=\"5\" style=\"background-color: #EEEEEE\"><b>Total Number of Topics: </b>#{@all_items_in_map.count-1}</td></tr>
</tbody></table></body></html>"

end

class Map <
  Struct.new(:title, :filename, :permission, :shortdesc, :type)
end

def has_slash(directory)
  last_char = directory.split('').last
  directory =  "#{directory}/" if !last_char.match("/")
  return directory
end


def cleanup_text(text)
  if !text.nil? || text ==""
    text.gsub!(/\n/, "")
    text.gsub!(/\t/, " ")
    text.lstrip
  end

end

def openfile(fileid)
  indv_item = Map.new
  indv_filepath = "#{@folder_path}#{fileid}"
  indv_filecontents = Nokogiri::XML(File.open(indv_filepath))        # XML node tree of file
  filecontents_text = indv_filecontents.xpath("//*").first.to_s      #  text of file

  i_type = filecontents_text.match(/(?<=\<).*?(?=\sxmlns)/).to_s     # Type of file
  i_title = indv_filecontents.xpath("//title").first.text.to_s
  i_permission = indv_filecontents.xpath("//*/prolog/permissions/@view").first.text.to_s
  i_desc = indv_filecontents.xpath("//*/shortdesc").text.to_s

  @emptycount +=1 if i_desc.nil? || i_desc == ""                     # counter for empty descriptions
  cleanup_text(i_desc)

  indv_item.title = @coder.decode(i_title)
  cleanup_text(i_title)

  indv_item.permission = i_permission

  indv_item.shortdesc = i_desc
  indv_item.type = i_type
  indv_item.filename = @coder.decode(fileid.to_s)
  @all_items_in_map.push(indv_item)
end

def buid_hierarchy(ditamap)
@map_h_array = []
     ditamap.lines.each do |line|
       newline = line.match(/\s.*?<topicref.*/).to_s
       unless newline.nil? || newline.empty?
         spaces = newline.match(/\s.*?(?=<topicref)/).to_s
        @map_h_array << spaces.count(" ")
       end
     end
end



# for the temporary variable use @ditmap = "/Users/wayneb/ARM_WORK/shortdesc/shortdesc/lou1375305364946.ditamap"


@emptycount = 0

@ditamap = ARGV[0]
if @ditamap.nil?
  puts "You must provide a ditamap. Use -h for a list of options available.\n\nFrom the command prompt in Windows (or terminal in linux/Unix) type:\n
  ruby shortdesc.rb [options] <path>/[main ditamap]
  \nNote: You may have to use a path in front of shortdesc.rb script and the ditamap file depending on where items are located on your computer."
  exit
 # @ditamap = "/Users/wayneb/ARM_WORK/shortdesc/shortdesc/ARM_Cortex__A57_MPCore_Processor_Technical_Referen.ARM-export.English/way1383153806660.ditamap"
end



@folder_path = File.dirname(@ditamap)
@folder_path = has_slash(@folder_path)

# Open file
map_contents = Nokogiri::XML(File.open(@ditamap))
@mainmap_id =  map_contents.xpath("/*/@id").first.to_s
main_title = map_contents.xpath("//title").to_s
@main_title = @coder.decode(main_title)

if @main_title =="" or @main_title.nil?
  main_title = map_contents.xpath("//*/booktitle").text
end

cleanup_text(@main_title)

text_map = map_contents.to_s

buid_hierarchy(text_map)

## parse XML

@all_items_in_map = Array.new
map_contents.xpath('//topicref/@href').each do |href|
  # open each file
  openfile(href)
end


 if options [:text]
   build_text
   @out_filename="#{@folder_path}#{@mainmap_id}_shortdesc.txt"
 end

if options [:html]
  build_html
  @out_filename="#{@folder_path}#{@mainmap_id}_shortdesc.htm"
end

if options [:excel]
  build_excel
  @out_filename="#{@folder_path}#{@mainmap_id}_shortdesc.tsv"
end

#write out file

 File.open(@out_filename, 'w+') {|f| f.write(@output)  }


