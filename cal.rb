require 'date'
require 'optparse'

=begin

A simple script to track anything done per day and produce averages over time.

Input file is a file with a date, a pipe, a number/count (1 or 2 digit),
one entry per line, like:

YYYY-MM-DD | NN

=end

class Days
  attr_accessor :first, :last, :days, :total_count, :total_days, :avg

  def initialize(file)
    lines = IO.readlines(file) 
    @first  = Date.strptime(lines[0].split('|')[0].strip, "%Y-%m-%d")
    @last   = Date.strptime(lines.last.split('|')[0].strip, "%Y-%m-%d")
    @days   = []
    @total_count = 0;
    @total_days = 0;

    lines.each do |line|
      date = Date.strptime(line.split('|')[0], "%Y-%m-%d")
      count = line.split('|')[1].strip
      @total_count += count.to_f
      @total_days += 1
      @days.push( Day.new(date, count) )
    end
  end

  def avg
    return @total_count / @total_days
  end
end

class Day
  attr_accessor :date, :count
  def initialize(date, count)
    @date = date
    @count = count || 0
  end
end

class WeeklyReport
  def initialize(ds)
    @ds = ds
    @by_weeks = {};
    @ds.days.each do |d|
      year_week = d.date.cwyear.to_s + " " + sprintf("%02d", d.date.cweek).to_s
      @by_weeks[ year_week ] ||= []
      @by_weeks[ year_week ].push(sprintf("%02d", d.count))
    end
  end

  def simple
    @by_weeks.keys.sort.each do |d|
      print "#{d} : "
      count = 0;
      days_in_week = 0;
      @by_weeks[d].each do |c|
        print "#{c} "
        count = count + c.to_f # to_f for float here: ruby seems to round DOWN. I <3 ruby
        days_in_week = days_in_week + 1
      end
      print "\tcount: #{count} "
      wavg = 0.0
      wavg = count / days_in_week
      print "\tavg: #{wavg}\n"
    end
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: cal.rb [options]"
  opts.on('-d', '--data FILE', 'data file') { |v| options[:data] = v }
end.parse!

ds = Days.new(options[:data])

print "#{ds.first} .. #{ds.last}\n"
print "total average for #{ds.total_days} days: #{ds.avg}\n";

weekly = WeeklyReport.new(ds)
weekly.simple
