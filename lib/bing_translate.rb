module BingTranslate
  require 'net/http'
  require 'json'

  HOST        = 'api.microsofttranslator.com'
  SERVICE     = '/V2/Http.svc/Translate'
  QUERY_LIMIT = 2000000
  LOCALES_MAP = {
    :cn => :'zh-CN'
  }

  def self.get_api
    config_file = "#{Rails.root}/config/google_translate.yml"
    #config_file = File.expand_path('../google_translate.yml', __FILE__)
    if File.exists?(config_file)
      @@goole_translate_api = YAML.load_file(config_file)['api']
      raise GoogleTranslateException.new("No API key found in '#{config_file}'") if @@goole_translate_api.blank?
      return @@goole_translate_api
    else
      raise GoogleTranslateException.new("No config file found '#{config_file}'")
    end
    return nil
  end

  def self.map(locale)
    mapped = LOCALES_MAP[locale]
    mapped.nil? ? locale : mapped
  end

  def self.perform(params)
    query[:text] = CGI::escape(params[:q].to_s[0..QUERY_LIMIT])
    query[:from] = map params[:source]
    query[:to] = map params[:target]
    query.merge!(:appId => 'DC63F9F0F8805837BEA3247EB2EBF0EB4C0A3D3A', :contentType => 'text/html', :category => 'general')
    data = []
    query.each_pair { |k,v| data << "#{k}=#{v}" }
    query_string = data.join('&')
    http = Net::HTTP.new(HOST, 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response, data = http.post(SERVICE, query_string, 'X-HTTP-Method-Override' => 'GET')
    puts response.body
    puts data
    if response.code == 200
      json = JSON.parse(data)
      if json['data'] && json['data']['translations'] && json['data']['translations'].first['translatedText']
        return CGI::unescapeHTML(json['data']['translations'].first['translatedText'])
      else
        raise GoogleTranslateException.new(error(json))
      end
    else
      json = JSON.parse(response.body)
      raise GoogleTranslateException.new(error(json))
    end
  end

  private

  def error(json)
    if json['error'] && json['error']['errors'] && json['error']['errors'].first['message']
      return json['error']['errors'].first['message']
    else
      return 'Unknown error'
    end
  end
end

class GoogleTranslateException < StandardError; end