#!/usr/bin/ruby
require 'ostruct'
require 'sqlite3'

DEFAULT_SQLITE_DB_PATH = "journal.sqlite.db"

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

    db_path = ARGV.shift || DEFAULT_SQLITE_DB_PATH
    options.db_path = db_path

    options
  end

end

class Database
  attr_accessor :db

  def initialize
  end

  def self.create(db_path)
    db = Database.new
    if File.exists?(db_path)
      puts "Using #{db_path}...".yellow
    else
      puts "Creating database #{db_path}...".green
    end

    begin
      db.db = SQLite3::Database.new( db_path )
    rescue Exception => e
      puts "Cannot create/load #{db_path}...".red
      puts e.message.red
      puts "#{e.backtrace.join("\n")}".red
    end
    return db
  end
end

options = OptionParser.parse(ARGV)
db      = Database.create(options.db_path)
