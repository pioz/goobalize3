module GoogleTranslate
  require 'net/http'
  require 'json'

  HOST        = 'www.googleapis.com'
  SERVICE     = '/language/translate/v2'
  QUERY_LIMIT = 5000

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

  def self.perform(params)
    @@goole_translate_api ||= get_api
    params[:q] = CGI::escape(params[:q].to_s[0..QUERY_LIMIT])
    params.merge!(:key => @@goole_translate_api, :format => 'html')
    data = []
    params.each_pair { |k,v| data << "#{k}=#{v}" }
    query_string = data.join('&')
    http = Net::HTTP.new(HOST, 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    response, data = http.post(SERVICE, query_string, 'X-HTTP-Method-Override' => 'GET')
    json = JSON.parse(data)
    raise GoogleTranslateException.new(json['error']['errors'].first['message']) if json['error']
    if json['data'] && json['data']['translations'] && json['data']['translations'].first['translatedText']
      return CGI::unescapeHTML(json['data']['translations'].first['translatedText'])
    else
      raise GoogleTranslateException.new('Unknown error')
    end
  end
end

class GoogleTranslateException < StandardError; end