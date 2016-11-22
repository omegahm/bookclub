# encoding: UTF-8
require 'sinatra'
require 'sinatra/reloader'

require './config/goodreads'

require 'nokogiri'
require 'open-uri'

set server: 'thin'
register Sinatra::Reloader

get '/' do
  @page = Nokogiri::HTML(open(BOOK_URL).read)
  @page.encoding = 'utf-8'
  book_lines = @page.css('table#groupBooks tr')

  @categories = [
    {
      key:   'currently-reading',
      title: 'Currently reading',
      color: 'info'
    },
    {
      key:   'to-read',
      title: 'To read',
      color: 'warning',
    },
    {
      key:   'read',
      title: 'Read',
      color: 'success'
    }
  ]

  @shelves = {
    'currently-reading' => [],
    'to-read'           => [],
    'read'              => []
  }

  book_lines.drop(1).each do |bl|
    @shelves[bl.css('td:nth(5) a').text()] ||= []
    @shelves[bl.css('td:nth(5) a').text()] << {
      link:   bl.css('td:nth(2) a')[0]['href'],
      title:  bl.css('td:nth(2) a').text(),
      author: bl.css('td:nth(3) a').text()
    }
  end

  erb :index
end
