 crossfit-games-scraper
======================

A quick ruby scraper that gets data from http://games.crossfit.com/leaderboard

run ./games-scraper.rb -h for help

Usage: games-scraper.rb -s -d -r -c -y
    -s, --stage [STAGE]              Stage of competition
    -d, --division [DIV]             Which divions of competition
    -r, --region [REG]               Region of competition
    -c, --competition [LEVEL]        Competition level (open, regionals, games)
    -y, --year [YEAR]                Yeah you want to scrape
    -h, --help                       Display help

Tested with Ruby 2.0
 Requires:
  require 'nokogiri'
  require 'open-uri'
  require 'optparse'
