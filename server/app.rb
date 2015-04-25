require 'sinatra'
require 'sinatra/activerecord'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'thin'
require './parser'

# class AvitoRuParser<BaseParser
#   def initialize
#     @remote_base_url = "http://avito.ru/"
#   end
#
#   def prepare_url maker, model, page = 1
#     url = URI.join(@remote_base_url,"/rossiya/avtomobili_s_probegom/",maker,model)
#     params = {:p => page, :s => 3}
#     url.query = URI.encode_www_form params
#     p url
#     url
#   end
#
#   def prepare_car maker,model,xml
#     p xml
#     year = xml.css('a').text.split(',').second.rstrip.lstrip.to_i
#     price = xml.css(".about").text
#     price = price.to_s.split("\n")
#     price = price.second.tr('^0-9','').to_i
#     milage = xml.css(".param").to_a[2].text
#     milage = milage.tr('^0-9','').to_i
#     description = xml.css(".param").to_a[0..1].join
#     place = xml.css(".data").text.split("\n  ").map {|item| item.rstrip.lstrip }.uniq
#     place.pop
#     place.shift
#     place = place[place.size - 1]
#     months = {"января"=>"January", "февраля"=>"February", "марта"=>"March", "апреля"=>"April",
#                 "мая"=>"May", "июня"=>"June", "июля"=>"Jule", "августа"=>"August",
#                 "сентября"=>"September", "октября"=>"October", "ноября"=>"November",
#                 "декабря"=>"December", "Вчера"=>"Yesterday"}
#
#     time = xml.css(".data").text.split("\n  ").map{|item| item.rstrip.lstrip}.uniq
#     time = time[time.size - 1]
#     if time.split(' ').size==3
#       time = time.split(' ')[0..1].join(' ')
#     end
#     months.each{|key,value|
#       time = time.gsub(key, value)
#     }
#     time = Chronic.parse(time, :now => Time.now).prev_year
#     id = xml['id']
#     if Auto.find_by(uid: id).nil?
#       auto = Auto.create! maker: maker, model: model, year: year, price: price, milage: milage, short_description: description,
#                           town: place, uid: id, new: 1
#       "new"
#     else
#       "old"
#     end
#   end
#
#   def load_makers
#     @url = "https://www.avito.ru/rossiya/avtomobili_s_probegom"
#     page = Nokogiri.HTML(open(@url))
#     makers = page.css('.marks-col-a').map{|item|
#       {item:item.text.to_s.lstrip.rstrip, autoruname: item['href'].gsub('/cars/','').gsub('/all/','')}
#     }.sort_by{|item| item['item']}.uniq
#     makers.each{|maker|
#       if Maker.find_by(maker: maker['item']).nil?
#         _maker = Maker.create! maker: maker[:item], autoru: 1, autoruname: maker[:autoruname]
#       end
#     }
#     makers
#   end
#
#   def load_models maker
#     _maker = maker.autoruname
#     maker_id = maker.id
#     @url = "http://auto.ru/cars/#{maker.autoruname}/all"
#     page = Nokogiri.HTML(open(@url))
#     models = page.css('.showcase-modify-title-link').map {|item|
#       {item: item.text.to_s.lstrip.rstrip, autoruname: item['href'].gsub('/cars/','').gsub('/all/','').gsub(maker.autoruname+'/','')}
#     }.sort_by{|item| item[:item]}
#     models.each{|model|
#       if Model.find_by(maker_id: maker_id, model: model[:item]).nil?
#         _model = Model.create! maker_id: maker_id, model: model[:item], autoru: 1, autoruname: model[:autoruname]
#       end
#     }
#   end
#
# end
# class AutoRuParser<BaseParser
#   def initialize
#     @remote_base_url = "http://auto.ru/"
#   end
#
#   def prepare_url maker, model, used, page = 1
#     url = URI.join(@remote_base_url,"/cars/",maker,model,used)
#     params = {:p => page, :output_type => "table"}
#     url.query = URI.encode_www_form params
#     p url
#     url
#   end
#
#   def prepare_car maker,model,xml
#     year = xml.css('.sales-table-cell_year')[0].text.to_i
#     price = xml.css('.sales-table-cell_price')[0].text.tr('^0-9', '').to_i
#     milage = xml.css('.sales-table-cell_run')[0].text.tr('^0-9', '').to_i
#     description = xml.css('.sales-table-cell_engine')[0].text
#     place = xml.css('.sales-table-region').text
#     #time = Date.strptime(xml.css('.sales-table-date')[0].text,"%d.%m.%y")
#     id = xml['data-sale_id']
#     #auto = Auto.new maker, model, year, price, place, milage, description, id
#     if Auto.find_by(uid: id).nil?
#       auto = Auto.create! maker: maker, model: model, year: year, price: price, milage: milage, short_description: description,
#                           town: place, uid: id, new: 1
#       "new"
#     else
#       "old"
#     end
#   end
#
#
# def run(opts)
#   EM.run do
#     web_app = opts[:app]
#     server  = opts[:server] || 'thin'
#
#     dispatch = Rack::Builder.app do
#       map '/' do
#         run web_app
#       end
#     end
#
#     unless ['thin', 'hatetepe', 'goliath'].include? server
#       raise "Need an EM webserver, but #{server} isn't"
#     end
#
#     # Start the web server. Note that you are free to run other tasks
#     # within your EM instance.
#     Thin::Server.start ParserApp, '0.0.0.0', 3000
#   end
# end
#
# class ParserApp < Sinatra::Base
#
#   register Sinatra::ActiveRecordExtension
#
#
#   configure do
#     set :threaded, false
#     set :database, {adapter: "sqlite3", database: "autos.sqlite3"}
#     set :views, 'views'
#   end
#
#   get '/' do
#     'hello'
#   end
#   #
#   # # Request runs on the reactor thread (with threaded set to false)
#   # get '/hello' do
#   #   'Hello World'
#   # end
#   #
#   # # Request runs on the reactor thread (with threaded set to false)
#   # # and returns immediately. The deferred task does not delay the
#   # # response from the web-service.
#   # get '/delayed-hello' do
#   #   EM.defer do
#   #     sleep 5
#   #   end
#   #   'I\'m doing work in the background, but I am still free to take requests'
#   # end
#   #
#   # get '/load/auto/:maker/:model' do
#   #   _parser = AutoRuParser.new
#   #   _parser.maker = params[:maker]
#   #   _parser.model = params[:model]
#   #   cars = []
#   #
#   #   worked_count = 0
#   #     (1..100).each do |i|
#   #       url = _parser.prepare_url("#{params[:maker]}/","#{params[:model]}/","used", i)
#   #       http = EventMachine::HttpRequest.new(url).get :redirects => 5
#   #       http.errback { p 'Uh oh'; EM.stop }
#   #       http.callback {
#   #         worked_count += 1
#   #         if http.response_header.status == 200
#   #           p http.response_header
#   #           page = Nokogiri.HTML http.response
#   #           elements = page.css('.sales-table-row' )
#   #           cars = cars.concat(elements.map {|car|
#   #                                _parser.prepare_car( _parser.maker, _parser.model, car)
#   #                              })
#   #         end
#   #       }
#   #     cars.to_json
#   #   end
#   # end
#   #
#   # get '/load/makers/avito' do
#   #   _parser = AvitoRuParser.new
#   #   makers = _parser.load_makers
#   #   makers.to_json
#   # end
#   #
#   # get '/load/models/avito' do
#   #   _parser = AvitoRuParser.new
#   #   models = []
#   #   Maker.all.each{ |maker|
#   #     models = _parser.load_models maker
#   #   }
#   #   models.to_json
#   # end
#   #
#   # get '/load/auto/:maker' do
#   #   _parser = AutoRuParser.new
#   #   _parser.callbacks = Hash.new
#   #   maker = Maker.find_by(autoruname: params[:maker])
#   #   models = []
#   #   if !maker.nil?
#   #     models = Model.where(maker_id:maker.id)
#   #     models.each{|model|
#   #       _parser.maker = maker
#   #       _parser.model = model
#   #       worked_count = 0
#   #       (1..5).each do |i|
#   #         url = _parser.prepare_url("#{_parser.maker.autoruname}/","#{_parser.model.autoruname}/","used/", i)
#   #         _parser.callbacks[url.to_s] = {maker: maker, model:model}
#   #         http = EventMachine::HttpRequest.new(url).get :redirects => 5
#   #         http.errback { p 'Uh oh'; EM.stop }
#   #         http.callback {
#   #           info = _parser.callbacks[http.req.uri.to_s]
#   #           if !info.nil?
#   #             maker = _parser.callbacks[http.req.uri.to_s][:maker]
#   #             model = _parser.callbacks[http.req.uri.to_s][:model]
#   #             worked_count += 1
#   #             if http.response_header.status == 200
#   #               page = Nokogiri.HTML http.response
#   #               elements = page.css('.sales-table-row' )
#   #               elements.map {|car|
#   #                 _parser.prepare_car( maker, model, car) }
#   #             end
#   #           else
#   #             p http.req.uri.to_s
#   #           end
#   #           EM.defer do
#   #             sleep 1
#   #           end
#   #         }
#   #       end
#   #     }
#   #   end
#   #   models.to_json
#   # end
#   #
#   # get '/load/avito/:maker/:model' do
#   #   _parser = AvitoRuParser.new
#   #   _parser.maker = params[:maker]
#   #   _parser.model = params[:model]
#   #   cars = []
#   #   worked_count = 0
#   #   (1..20).each do |i|
#   #     url = _parser.prepare_url("#{params[:maker]}/","#{params[:model]}/", i)
#   #     http = EventMachine::HttpRequest.new(url).get :redirects => 5, :head => {"Accept" => "*/*", "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5) AppleWebKit/600.2.5 (KHTML, like Gecko) Version/7.1.2 Safari/537.85.11", "Referer" => "http://www.google.ru/", "Keep-alive" => "true" }
#   #     http.errback { p 'Uh oh'; EM.stop }
#   #     http.callback {
#   #       worked_count += 1
#   #       if http.response_header.status == 200
#   #         page = Nokogiri.HTML http.response
#   #         elements = page.css('.item_table' ).to_a
#   #         cars = cars.concat(elements.map {|car|
#   #                              _parser.prepare_car( _parser.maker, _parser.model, car)
#   #                            })
#   #       end
#   #     }
#   #     cars.to_json
#   #   end
#   #   cars.to_json
#   # end
#   #
#   # get '/load/makers/auto' do
#   #   _parser = AutoRuParser.new
#   #   makers = _parser.load_makers
#   #   makers.to_json
#   # end
#   #
#   # get '/load/models/auto' do
#   #   _parser = AutoRuParser.new
#   #   models = []
#   #   Maker.all.each{ |maker|
#   #     models = _parser.load_models maker
#   #   }
#   #   models.to_json
#   # end
#   #
#   # get '/load/cars/auto' do
#   #   # _parser = AutoRuParser.new
#   #   # Model.all.each{|model|
#   #   #   maker_name = Maker.find_by(id: model.maker_id).autoruname
#   #   #   model_name = model.autoruname
#   #   #
#   #   #   cars = []
#   #   #
#   #   #   worked_count = 0
#   #   #   (1..1000).each do |i|
#   #   #     url = _parser.prepare_url("#{maker_name}/","#{model_name}/","used", i)
#   #   #     http = EventMachine::HttpRequest.new(url).get :redirects => 5
#   #   #     http.errback { p 'Uh oh'; EM.stop }
#   #   #     http.callback {
#   #   #       worked_count += 1
#   #   #       if http.response_header.status == 200
#   #   #         p http.response_header
#   #   #         page = Nokogiri.HTML http.response
#   #   #         elements = page.css('.sales-table-row' )
#   #   #         cars = cars.concat(elements.map {|car| _parser.prepare_car( maker_name, model_name, car) })
#   #   #       end
#   #   #     }
#   #   #     cars.to_json
#   #   #   end
#   #   # }
#   #   # set reverse order!
#   # end
# end
