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
      options.switch   = "log"
      options.name     = ARGV.shift.downcase.strip
      options.duration = ARGV.shift
      options.reason   = ARGV.shift
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
      puts help.strip.light_blue
    end

    options.db_path = ARGV.shift || DEFAULT_SQLITE_DB_PATH if options.switch
    options
  end

end


class Database
  attr_accessor :db

  def self.create(db_path)
    if File.exists?(db_path)
      puts "Using #{db_path}...".yellow
    else
      puts "Creating database #{db_path}...".green
    end

    db = Database.new
    begin
      db.db = SQLite3::Database.new(db_path)
      db.create_table
    rescue Exception => e
      puts "Cannot create/load #{db_path}...".red
      puts e.message.red
      puts "#{e.backtrace.join("\n")}".red
    end
    db
  end

  CREATE_LOGS_TABLE = <<DB_TABLE
  CREATE TABLE IF NOT EXISTS Logs(
    id INTEGER PRIMARY KEY UNIQUE,
    name VARCHAR(20) NOT NULL,
    duration INTEGER NOT NULL default '0',
    reason TEXT
  )
DB_TABLE

  def create_table
    begin
      @db.execute(CREATE_LOGS_TABLE)
    rescue Exception => e
      puts "Cannot create Logs table...".red
      puts e.message.red
      puts "#{e.backtrace.join("\n")}".red
    end
  end

  LIST_LOGS = "SELECT name, duration, reason FROM Logs"
  def list_logs
    begin
      list = []
      @db.execute(LIST_LOGS) do |log|
        list << {name: log[0], duration: log[1], reason: log[2]}
      end
      return list
    rescue Exception => e
      puts "Cannot get list of logs...".red
      puts e.message.red
      puts "#{e.backtrace.join("\n")}".red
    end
  end

  INSERT_LOGS = "INSERT INTO LOGS(name, duration, reason) VALUES"
  def insert_log(name, duration, reason)
    begin
      @db.execute(INSERT_LOGS + " (?, ?, ?)", name, duration, reason)
    rescue Exception => e
      puts "Cannot insert logs into database...".red
      puts e.message.red
      puts "#{e.backtrace.join("\n")}".red
    end
  end

  TOTAL_LOGS = "SELECT SUM(duration) AS total from Logs"
  def total_duration
    begin
      total = @db.get_first_value(TOTAL_LOGS)
      return total
    rescue Exception => e
      puts "Cannot get total logs from database...".red
      puts e.message.red
      puts "#{e.backtrace.join("\n")}".red
    end
  end

  HITLIST_LOGS = "SELECT name, SUM(duration) AS duration from Logs GROUP BY name"
  def hitlist
    begin
      hitlist = []
      @db.execute(HITLIST_LOGS) do |log|
        hitlist << {name: log[0], duration: log[1]}
      end
      return hitlist
    rescue Exception => e
      puts "Cannot get hitlist from database...".red
      puts e.message.red
      puts "#{e.backtrace.join("\n")}".red
    end
  end

end

options = OptionParser.parse(ARGV)
db      = Database.create(options.db_path) if options.db_path

case options.switch
when "log"
  db.insert_log(options.name, options.duration, options.reason)
when "list"
  db.list_logs.each do |log|
    puts "#{log[:name]}\t\t#{log[:duration]}\t\"#{log[:reason]}\""
  end
when "total"
  puts db.total_duration
when "hitlist"
  db.hitlist.each do |log|
    puts "#{log[:name]}\t\t#{log[:duration]}"
  end
end
