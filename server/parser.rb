class BaseParser
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





