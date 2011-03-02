module Goobalize3
  require File.expand_path('../google_translate', __FILE__)

  def translate(*args)
    if self.class.translates?
      cur_locale = I18n.locale
      targets = I18n.available_locales - [I18n.locale]
      args.map!{|l| l.to_s.downcase.to_sym}
      targets = targets & args unless args.empty?
      targets.each do |locale|
        autotranslated_attributes = {}
        self.class.translated_attribute_names.each do |attr_name|
          begin
            autotranslated_attributes[attr_name] = GoogleTranslate.perform(:source => cur_locale, :target => locale, :q => self.send(attr_name, cur_locale))
          rescue GoogleTranslateException => e
            Rails.logger.error(e.to_s)
          end
        end
        I18n.locale = locale
        self.update_attributes(autotranslated_attributes)
      end
      I18n.locale = cur_locale
    end
  end

end

Globalize::ActiveRecord::InstanceMethods.send(:include, Goobalize3)