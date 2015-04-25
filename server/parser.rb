require 'open-uri'
require 'nokogiri'
require 'active_record'
require 'sinatra'
require 'sinatra/activerecord'
require 'sqlite3'
require 'json'
require 'yaml'
require 'redis'

# set :database_file, "config/database.yml"
ActiveRecord::Base.establish_connection(
    :adapter  => "mysql2",
    :host     => "127.0.0.1",
    :username => "root",
    :password => "111",
    :database => "cars"
)
redis = Redis.new

class Auto  < ActiveRecord::Base
end

class User < ActiveRecord::Base

end

class BaseParser

  def prefix
    "auto"
  end

  def initialize
    @remote_base_url = ""
  end

  def maker= _maker
    @maker = _maker
  end

  def maker
    @maker
  end

  def model
    @model
  end

  def model= _model
    @model = _model
  end

  def prepare_url maker, model, page = 1
    url = URI.join(@remote_base_url,"/cars/",maker,model,used)
    params = {:p => page, :output_type => "table"}
    url.query = URI.encode_www_form params
    url

  end

  def prepare_car maker,model,xml

  end

  def load_makers
  end

  def load_models maker
  end

  def callbacks
    @callbacks
  end

  def callbacks= cbs
    @callbacks = cbs
  end
end

class AutoruParser < BaseParser
  def initialize
    @remote_base_url = "http://auto.ru"
  end
  def prepare_url maker,model,page = 1
    used = "used"
    url = URI.join(@remote_base_url,"/cars/",maker+"/",model+"/",used)
    params = {:p => page, :output_type => "table"}
    params["sort[set_date]"] = 'desc'
    url.query = URI.encode_www_form params
    p url
    url
  end

  def get_url url
    Nokogiri.HTML(open(url))
  end

  def parse page,maker,model
    cars = []
    elements = page.css('.sales-table-row' )
    count = 0
    cars.concat(elements.map {|car|
         count += prepare_car( maker, model, car)
       })
    count
  end

  def prepare_car maker,model,xml
    year = xml.css('.sales-table-cell_year')[0].text.to_i
    price = xml.css('.sales-table-cell_price')[0].text.tr('^0-9', '').to_i
    milage = xml.css('.sales-table-cell_run')[0].text.tr('^0-9', '').to_i
    description = xml.css('.sales-table-cell_engine')[0].text
    place = xml.css('.sales-table-region').text
    fuel = description.split(',')[1].lstrip
    volume = description.tr('^0-9.','')
    gearbox = description.split(',')[0].split(' ').last

    #time = Date.strptime(xml.css('.sales-table-date')[0].text,"%d.%m.%y")
    id = xml['data-sale_id']
    #TODO: create full set of properties for car
    count = 0
    if Auto.find_by(uid: id).nil?
      url = "http://auto.ru/cars/used/sale/" + id
      html_code = get_url url
      _hp = html_code.css('.card-info-value')[3].text.split('/')[1]
      hp = _hp.tr('^0-9.','').to_i if !_hp.nil?
      body = html_code.css('.card-info-value')[2].text
      steering_wheel = html_code.css('.card-info-value')[7].text
      wd = html_code.css('.card-info-value')[5].text
      color = html_code.css('.card-color')[0]['style'].split(';').first.split(':').last

      #getting phones
      url = "http://auto.ru/cars/used/sale/get_phones/" + id
      phone = url

      auto = Auto.create! maker: maker, model: model, year: year, price: price, milage: milage, short_description: description,
                          town: place, uid: id, new: 1, fuel: fuel, volume: volume, gearbox: gearbox, hp: hp, color: color,
                          steering_wheel: steering_wheel, body: body, wd: wd, phone: phone

      count += 1
      "new"
    else
      "old"
    end
    count
  end

  def load_makers
    # @url = "http://auto.ru/#all"
    # page = Nokogiri.HTML(open(@url))
    # makers = page.css('.marks-col-a').map{|item|
    #   {item:item.text.to_s.lstrip.rstrip, autoruname: item['href'].gsub('/cars/','').gsub('/all/','')}
    # }.sort_by{|item| item['item']}.uniq
    # makers.each{|maker|
    #   if Maker.find_by(maker: maker['item']).nil?
    #     _maker = Maker.create! maker: maker[:item], autoru: 1, autoruname: maker[:autoruname]
    #   end
    # }
    # makers
  end

  def load_models maker
    # _maker = maker.autoruname
    # maker_id = maker.id
    # @url = "http://auto.ru/cars/#{maker.autoruname}/all"
    # page = Nokogiri.HTML(open(@url))
    # models = page.css('.showcase-modify-title-link').map {|item|
    #   name = item['href'].gsub('/cars/','').gsub('/all/','').gsub(maker.autoruname+'/','')
    #              #.sort_by{|item| item[:item]}
    #  _item = item.text.to_s.lstrip.rstrip
    # {item: _item, autoruname: name}
    # }
    # models.each{|model|
    #   if Model.where("lower(model) = ? AND maker_id = ?",model[:item].downcase,maker_id).to_a.empty?
    #     _model = Model.create! maker_id: maker_id, model: model[:item], autoruname: model[:autoruname]
    #   else
    #     _model = Model.where("lower(model) = ? AND maker_id = ?",model[:item].downcase,maker_id).to_a.first
    #     _model[:autoruname] = model[:autoruname]
    #     _model.save!
    #   end
    # }
  end
end


class AvitoRuParser<BaseParser
  def initialize
    @remote_base_url = "http://avito.ru/"
  end

  def prepare_url maker, model, page = 1
    url = URI.join(@remote_base_url,"/rossiya/avtomobili_s_probegom/",maker,model)
    params = {:p => page, :s => 3}
    url.query = URI.encode_www_form params
    p url
    url
  end

  def prepare_car maker,model,xml
    p xml
    year = xml.css('a').text.split(',').second.rstrip.lstrip.to_i
    price = xml.css(".about").text
    price = price.to_s.split("\n")
    price = price.second.tr('^0-9','').to_i
    milage = xml.css(".param").to_a[2].text
    milage = milage.tr('^0-9','').to_i
    description = xml.css(".param").to_a[0..1].join
    place = xml.css(".data").text.split("\n  ").map {|item| item.rstrip.lstrip }.uniq
    place.pop
    place.shift
    place = place[place.size - 1]
    months = {"января"=>"January", "февраля"=>"February", "марта"=>"March", "апреля"=>"April",
                "мая"=>"May", "июня"=>"June", "июля"=>"Jule", "августа"=>"August",
                "сентября"=>"September", "октября"=>"October", "ноября"=>"November",
                "декабря"=>"December", "Вчера"=>"Yesterday"}

    time = xml.css(".data").text.split("\n  ").map{|item| item.rstrip.lstrip}.uniq
    time = time[time.size - 1]
    if time.split(' ').size==3
      time = time.split(' ')[0..1].join(' ')
    end
    months.each{|key,value|
      time = time.gsub(key, value)
    }
    time = Chronic.parse(time, :now => Time.now).prev_year
    id = xml['id']
    new_count = 0
    if Auto.find_by(uid: id).nil?
      auto = Auto.create! maker: maker, model: model, year: year, price: price, milage: milage, short_description: description,
                          town: place, uid: id, new: 1
      "new"
      new_count += 1
    else
      "old"
    end
    new_count
  end

  # def load_makers
  #   @url = "https://www.avito.ru/rossiya/avtomobili_s_probegom"
  #   page = Nokogiri.HTML(open(@url))
  #   items_script = page.css('script').to_a.map{|script| script.text}.select{|script| script.include?("avito.counters[0]")}.first
  #   items = items_script.split("avito.counters[0] =").second
  #   js = JSON.parse(items[0..items.length-4])
  #   js.each{|item|
  #     if Maker.where("lower(maker) = ?",item['name'].downcase).to_a.empty?
  #       _maker = Maker.create! maker: item['name'], avitoname: item['url'].split('/').last
  #     else
  #       _maker = Maker.where("lower(maker) = ?", item['name'].downcase).to_a.first
  #       _maker.avitoname = item['url'].split('/').last
  #       _maker.save!
  #     end
  #   }
  #   js
  # end

  # def load_models maker
  #   _maker = maker.avitoname
  #   maker_id = maker.id
  #   @url = "https://www.avito.ru/rossiya/avtomobili_s_probegom/#{ _maker}"
  #   page = Nokogiri.HTML(open(@url))
  #   models = page.css('.js-catalog-counts__link').select{|item|
  #     item['href'].include?("/rossiya/avtomobili_s_probegom/#{_maker}")
  #   }.map {|item|
  #     {item: item.text.to_s.lstrip.rstrip, avitoname: item['href'].gsub("/rossiya/avtomobili_s_probegom/#{_maker}/",'')}
  #   }#.sort_by{|item| item[:item]}
  #
  #   models.each{|model|
  #     if Model.where("lower(model) = ? AND maker_id = ?",model[:avitoname].downcase, maker_id).to_a.empty?
  #       _model = Model.create! maker_id: maker_id, model: model[:item], avitoname: model[:avitoname]
  #     else
  #       _model = Model.where("lower(model) = ? AND maker_id = ?",model[:avitoname].downcase,maker_id).to_a.first
  #       p _model
  #     end
  #     p model
  #     # if Model.find_by(maker_id: maker_id, model: model[:item]).nil?
  #     #   _model = Model.create! maker_id: maker_id, model: model[:item], autoru: 1, autoruname: model[:autoruname]
  #     # end
  #   }
  # end

end


autoparser = AutoruParser.new
avitoParser = AvitoRuParser.new

makers = YAML.load(File.read('config/makers.yaml', :encoding => 'utf-8'))['cars']

use Rack::Session::Cookie, :key => 'rack.session',
    :domain => 'localhost',
    :path => '/',
    :expire_after => 2592000, # In seconds
    :secret => 'fuck_you'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'admin' and password == 'admin'
end

set :public_folder, Proc.new { File.join(root, "public") }

get '/' do
  makers.to_json
end

get '/makers' do
  makers.to_json
end

get '/load/auto/:maker/:model' do
  count = 0
  (0..200).each{|page|
    begin
      url = autoparser.prepare_url params[:maker], params[:model], page
      xml = autoparser.get_url(url)
    rescue OpenURI::HTTPError => e
      print "page #{url} not found "
      break
    end
    current_count = autoparser.parse(xml, params[:maker], params[:model])
    break if current_count.eql?(0)
    count += current_count
  }
  count
end

get '/cars/:maker/:model' do
  Auto.where(:maker => params[:maker], :model => params[:model]).map{|car|
    car.attributes.delete_if { |k, v| v.nil? }
  }.to_json
end

get '/users/create' do

end

get '/users/:user_id/select' do
  params[:user_id]
  redis.set("user_#{params[:user_id]}", "foo")
end

get '/users/:user_id/get_selection' do
  redis.get("user_#{params[:user_id]}")
end

get '/app' do
  erb :app
end

get '/app/:view' do
  view = 'app/' + params[:view] + '.erb'
  @makers = makers
  content = File.read(File.join(settings.views, view))
  erb content, { :layout => false }
end