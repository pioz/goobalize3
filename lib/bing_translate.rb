module BingTranslate
  require 'net/http'
  require 'nokogiri'

  URI         = URI.parse('http://api.microsofttranslator.com/V2/Http.svc/Translate')
  QUERY_LIMIT = 2000000
  LOCALES_MAP = {
    :cn => :'zh-CNT'
  }

  def self.get_api
    config_file = "#{Rails.root}/config/goobalize.yml"
    #config_file = File.expand_path('../bing_translate.yml', __FILE__)
    if File.exists?(config_file)
      @@bing_translate_api = YAML.load_file(config_file)['bing_app_id']
      raise GoobalizeTranslateError.new("No APP ID found in '#{config_file}'") if @@bing_translate_api.blank?
      return @@bing_translate_api
    else
      raise GoobalizeTranslateException.new("No config file found '#{config_file}'")
    end
    return nil
  end

  def self.map(locale)
    mapped = LOCALES_MAP[locale]
    mapped.nil? ? locale : mapped
  end

  def self.perform(params)
    @@bing_translate_api ||= get_api
    query = {}
    query[:text] = CGI::escape(params[:q].to_s[0..QUERY_LIMIT])
    query[:from] = map params[:source]
    query[:to] = map params[:target]
    query.merge!(:appId => @@bing_translate_api, :contentType => 'text/html', :category => 'general')
    data = []
    query.each_pair { |k,v| data << "#{k}=#{v}" }
    query_string = data.join('&')
    result = Net::HTTP.new(URI.host, URI.port).get("#{URI.path}?#{query_string}")
    begin
      Nokogiri.parse(result.body).xpath('//xmlns:string').first.content
    rescue
      raise GoobalizeTranslateError.new('Translation failed')
    end
  end
end
