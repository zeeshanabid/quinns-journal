#!/usr/bin/ruby
require 'ostruct'

class String
  # Easy colorization
  COLORS = {
    :red        => 31,
    :green      => 32,
    :yellow     => 33,
    :blue       => 34,
    :pink       => 35,
    :light_blue => 36,
  }

  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(COLORS[:red])
  end

  def green
    colorize(COLORS[:green])
  end

  def yellow
    colorize(COLORS[:yellow])
  end

  def blue
    colorize(COLORS[:blue])
  end

  def pink
    colorize(COLORS[:pink])
  end

  def light_blue
    colorize(COLORS[:light_blue])
  end
end


class OptionParser
  # Simple option parser. No need to use any utiltity class at this point
  def self.parse(args)
    options = OpenStruct.new
    switch  = ARGV.shift
    case switch
    when "log"
      options.switch = "log"
    when "list"
      options.switch = "list"
    when "total"
      options.switch = "total"
    when "hitlist"
      options.switch = "hitlist"
    else
      help = <<HELP
Usage: journal.rb [log|list|total|hitlist]

Commands:
log [NAME] [DURATION] [REASON] \t Logs the entry in the database
list \t\t\t\t Lists all the log entries
total \t\t\t\t Total interuptions in minutes
hitlist \t\t\t List of all interuptions by name
HELP
    puts help.yellow
    end

    options
  end

end

options = OptionParser.parse(ARGV)
