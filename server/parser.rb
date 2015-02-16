require 'open-uri'
require 'nokogiri'
require 'active_record'
require 'sinatra'
require 'sinatra/activerecord'
require 'sqlite3'
require 'json'

set :database, {adapter: "sqlite3", database: "auto.sqlite3"}
class Auto  < ActiveRecord::Base
end

class Model < ActiveRecord::Base
  belongs_to :maker
end

class Maker < ActiveRecord::Base
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
  def prepare_url maker,model,page
    used = "used"
    url = URI.join(@remote_base_url,"/cars/",maker,model,used)
    params = {:p => page, :output_type => "table"}
    url.query = URI.encode_www_form params
    p url
    url
  end

  def get_url url
    Nokogiri.HTML(open(url))
  end

  def parse page,maler,model
    cars = []
    elements = page.css('.sales-table-row' )
    cars = cars.concat(elements.map {|car|
         prepare_car( maker, model, car)
       })
    cars
  end

  def prepare_car maker,model,xml
    year = xml.css('.sales-table-cell_year')[0].text.to_i
    price = xml.css('.sales-table-cell_price')[0].text.tr('^0-9', '').to_i
    milage = xml.css('.sales-table-cell_run')[0].text.tr('^0-9', '').to_i
    description = xml.css('.sales-table-cell_engine')[0].text
    place = xml.css('.sales-table-region').text
    #time = Date.strptime(xml.css('.sales-table-date')[0].text,"%d.%m.%y")
    id = xml['data-sale_id']
    #auto = Auto.new maker, model, year, price, place, milage, description, id
    if Auto.find_by(uid: id).nil?
      auto = Auto.create! maker: maker, model: model, year: year, price: price, milage: milage, short_description: description,
                          town: place, uid: id, new: 1
      "new"
    else
      "old"
    end
  end

  def load_makers
    @url = "http://auto.ru/#all"
    page = Nokogiri.HTML(open(@url))
    makers = page.css('.marks-col-a').map{|item|
      {item:item.text.to_s.lstrip.rstrip, autoruname: item['href'].gsub('/cars/','').gsub('/all/','')}
    }.sort_by{|item| item['item']}.uniq
    makers.each{|maker|
      if Maker.find_by(maker: maker['item']).nil?
        _maker = Maker.create! maker: maker[:item], autoru: 1, autoruname: maker[:autoruname]
      end
    }
    makers
  end

  def load_models maker
    _maker = maker.autoruname
    maker_id = maker.id
    @url = "http://auto.ru/cars/#{maker.autoruname}/all"
    page = Nokogiri.HTML(open(@url))
    models = page.css('.showcase-modify-title-link').map {|item|
      name = item['href'].gsub('/cars/','').gsub('/all/','').gsub(maker.autoruname+'/','')
                 #.sort_by{|item| item[:item]}
     _item = item.text.to_s.lstrip.rstrip
    {item: _item, autoruname: name}
    }
    models.each{|model|
      if Model.where("lower(model) = ? AND maker_id = ?",model[:item].downcase,maker_id).to_a.empty?
        _model = Model.create! maker_id: maker_id, model: model[:item], autoruname: model[:autoruname]
      else
        _model = Model.where("lower(model) = ? AND maker_id = ?",model[:item].downcase,maker_id).to_a.first
        _model[:autoruname] = model[:autoruname]
        _model.save!
      end
    }
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
    if Auto.find_by(uid: id).nil?
      auto = Auto.create! maker: maker, model: model, year: year, price: price, milage: milage, short_description: description,
                          town: place, uid: id, new: 1
      "new"
    else
      "old"
    end
  end

  def load_makers
    @url = "https://www.avito.ru/rossiya/avtomobili_s_probegom"
    page = Nokogiri.HTML(open(@url))
    items_script = page.css('script').to_a.map{|script| script.text}.select{|script| script.include?("avito.counters[0]")}.first
    items = items_script.split("avito.counters[0] =").second
    js = JSON.parse(items[0..items.length-4])
    js.each{|item|
      if Maker.where("lower(maker) = ?",item['name'].downcase).to_a.empty?
        _maker = Maker.create! maker: item['name'], avitoname: item['url'].split('/').last
      else
        _maker = Maker.where("lower(maker) = ?", item['name'].downcase).to_a.first
        _maker.avitoname = item['url'].split('/').last
        _maker.save!
      end
    }
    js
  end

  def load_models maker
    _maker = maker.avitoname
    maker_id = maker.id
    @url = "https://www.avito.ru/rossiya/avtomobili_s_probegom/#{ _maker}"
    page = Nokogiri.HTML(open(@url))
    models = page.css('.js-catalog-counts__link').select{|item|
      item['href'].include?("/rossiya/avtomobili_s_probegom/#{_maker}")
    }.map {|item|
      {item: item.text.to_s.lstrip.rstrip, avitoname: item['href'].gsub("/rossiya/avtomobili_s_probegom/#{_maker}/",'')}
    }#.sort_by{|item| item[:item]}

    models.each{|model|
      if Model.where("lower(model) = ? AND maker_id = ?",model[:avitoname].downcase, maker_id).to_a.empty?
        _model = Model.create! maker_id: maker_id, model: model[:item], avitoname: model[:avitoname]
      else
        _model = Model.where("lower(model) = ? AND maker_id = ?",model[:avitoname].downcase,maker_id).to_a.first
        p _model
      end
      p model
      # if Model.find_by(maker_id: maker_id, model: model[:item]).nil?
      #   _model = Model.create! maker_id: maker_id, model: model[:item], autoru: 1, autoruname: model[:autoruname]
      # end
    }
  end

end


parser = AutoruParser.new
avitoParser = AvitoRuParser.new
#avitoParser.load_models Maker.find(1)
parser.load_models Maker.find(1)
# p parser.parse(parser.get_url(parser.prepare_url "audi/","a3/",1),"audi","a3")
get '/' do
  parser.load_makers
  Maker.all.to_json
end

get '/models.json' do
  Model.all.to_json
end

get '/makers' do
  Maker.all.to_json
end

get '/update' do
  parser.load_makers
  avitoParser.load_makers
  makers = Maker.all
  makers.each {|maker|
    parser.load_models maker
    avitoParser.load_models maker
  }
end