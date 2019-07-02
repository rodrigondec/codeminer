#!/usr/bin/ruby -w
# frozen_string_literal: true

require './game'
require 'pp'

# Class for parsing the games.log
class LogParser
  def initialize(file_path)
    file = File.open(file_path)
    @data = []
    file.each_line do |line|
      @data.push(line)
    end
    file.close
    @games = []
  end
end