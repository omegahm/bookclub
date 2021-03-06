# encoding: UTF-8
require 'sinatra'
require 'sinatra/reloader'

require './config/goodreads'
require 'dalli'
dc = Dalli::Client.new('localhost:11211', namespace: 'bookclub_v1', compress: true)

require 'nokogiri'
require 'open-uri'
require 'date'

set server: 'thin'
register Sinatra::Reloader

get '/update_ratings' do
  content_type :text

  PEOPLE.each do |name, rss|
    feed = Nokogiri::XML(open(rss).read)
    feed.css('item').each do |book|
      book_title = book.css('title')[0].text()
      ratings = dc.get(book_title) || {}
      ratings[name] = book.css('user_rating')[0].text()
      dc.set(book_title, ratings)
    end
  end

  'OK.'
end

get '/' do
  @page = Nokogiri::HTML(open(BOOK_URL).read)
  @page.encoding = 'utf-8'
  book_lines = @page.css('table#groupBooks tr')

  @categories = [
    {
      key:   'currently-reading',
      title: 'Igangværende',
      color: 'info'
    },
    {
      key:   'to-read',
      title: 'Fremtidige bøger',
      color: 'warning',
    },
    {
      key:   'read',
      title: 'Læst',
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
    book_title = bl.css('td:nth(2) a')[0].text()
    book = {
      img:         bl.css('td:nth(1) a img')[0]['src'].sub(/(\d+)s/, '\1l'),
      link:        "https://www.goodreads.com#{bl.css('td:nth(2) a')[0]['href']}",
      title:       bl.css('td:nth(2) a')[0].text(),
      author:      bl.css('td:nth(3) a').text().sub(/(.*), (.*)/, '\2 \1'),
      author_link: "https://www.goodreads.com#{bl.css('td:nth(3) a')[0]['href']}",
      ratings:     dc.get(book_title) || {},
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

  @mobile = request.env['X_MOBILE_DEVICE']

  erb :index
end
