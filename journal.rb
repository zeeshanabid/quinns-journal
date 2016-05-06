#!/usr/bin/ruby

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
