#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'optparse'

options = {}

optparse = OptionParser.new do |opts|

  opts.banner = "Usage: games-scraper.rb -s -d -r -c -y"

  opts.on('-s', '--stage [STAGE]', 'Stage of competition') do |stage|
    options[:stage] = stage.to_i || 1
  end

  opts.on('-d', '--division [DIV]', 'Which divions of competition') do |div|
    options[:division] = div.to_i || 1
  end

  opts.on('-r', '--region [REG]', 'Region of competition') do |reg|
    options[:region] = reg.to_i || 0
  end

  opts.on('-c', '--competition [LEVEL]', 'Competition level (open, regionals, games)') do |comp|
    options[:competition] = comp.to_i || 0
  end

  opts.on('-y', '--year [YEAR]', 'Yeah you want to scrape') do |year|

    options[:year] = year[-2,2].to_i || 13
  end

  opts.on('-h', '--help', 'Display help') do
    puts opts
    exit
  end

end
optparse.parse!

athletes = []
current_page = 1
finished = false

while !finished do
  url = "http://games.crossfit.com/scores/leaderboard.php?stage=#{options[:stage]}&sort=0&division=#{options[:division]}&region=#{options[:region]}&numberperpage=100&page=#{current_page}&competition=#{options[:competition]}&year=#{options[:year]}"

  page = Nokogiri::HTML(open(url))

  page.css('table tr').each do |tr|
    athlete = {}
    tr.css('.name').each do |name|
      athlete[:uid] = name.to_s.match(/\/\d{1,}\"/)[0][1..-2]
      athlete[:name] = name.at_css('a').content
    end

    athlete[:place] = []
    athlete[:score] = []
    tr.css('.display').each do |score|
      if match = score.content.match(/(\d{0,}.)(\(\d{0,}\))/)
        p, s = match.captures
        athlete[:place].push p.strip.to_i
        athlete[:score].push s[1..-2].to_i
      end
    end
    athletes.push athlete if athlete[:uid] && athlete[:name]
  end
  
  if athletes.count % 100 == 0
    current_page += 1
  else
    finished = true
  end

  puts "Athletes scanned: #{athletes.count}"
end

puts "Writing to athletes_#{options[:stage]}_#{options[:division]}_#{options[:region]}_#{options[:competition]}_#{options[:year]}.csv ..."

open("athletes_#{options[:stage]}_#{options[:division]}_#{options[:region]}_#{options[:competition]}_#{options[:year]}.csv", 'w') do |file|
  file.write "uid, name, places, scores\n"
  athletes.each do |athlete|
    file.write "#{athlete[:uid]},\"#{athlete[:name]}\",\"#{athlete[:place]}\",\"#{athlete[:score]}\"\n"
  end
end

puts "Done."
