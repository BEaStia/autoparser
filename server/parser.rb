require 'open-uri'
require 'nokogiri'
require 'active_record'
require 'sinatra'
require 'sinatra/activerecord'
require 'sqlite3'

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
    {item: item.text.to_s.lstrip.rstrip, autoruname: item['href'].gsub('/cars/','').gsub('/all/','').gsub(maker.autoruname+'/','')}.sort_by{|item| item[:item]}}
    models.each{|model|
      if Model.find_by(maker_id: maker_id, model: model[:item]).nil?
        _model = Model.create! maker_id: maker_id, model: model[:item], autoru: 1, autoruname: model[:autoruname]
      end
    }
  end
end
