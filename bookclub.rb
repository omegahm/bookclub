# encoding: UTF-8
require 'sinatra'
require 'sinatra/reloader'

require './config/goodreads'

require 'nokogiri'
require 'open-uri'
require 'date'

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
    shelf = bl.css('td:nth(5) a').text()
    book = {
      img:         bl.css('td:nth(1) a img')[0]['src'],
      link:        bl.css('td:nth(2) a')[0]['href'],
      title:       bl.css('td:nth(2) a')[0].text(),
      author:      bl.css('td:nth(3) a').text(),
      author_link: bl.css('td:nth(3) a')[0]['href']
    }

    book[:date_chosen] = begin
      Date.parse(bl.css('td:nth(6)').text())
    rescue
      Date.new
    end

    book[:date_discussed] = begin
      Date.parse(bl.css('td:nth(7)').text())
    rescue
      Date.new
    end
    @shelves[shelf] << book
  end

  @shelves['to-read'] = @shelves['to-read'].shuffle
  @shelves['read']    = @shelves['read'].sort_by { |book| book[:date_chosen] }.reverse

  erb :index
end
