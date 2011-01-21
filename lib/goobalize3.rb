module Goobalize3
  require File.expand_path('../google_translate', __FILE__)

  def translate(targets = nil)
    if self.class.translates?
      cur_locale = I18n.locale
      targets ||= I18n.available_locales - [I18n.locale]
      targets.each do |locale|
        autotranslated_attributes = {}
        self.class.translated_attribute_names.each do |attr_name|
          autotranslated_attributes[attr_name] = GoogleTranslate.perform(:source => cur_locale, :target => locale, :q => self.send(attr_name))
        end
        I18n.locale = locale
        self.update_attributes(autotranslated_attributes)
      end
      I18n.locale = cur_locale
    end
  end

end

Globalize::ActiveRecord::InstanceMethods.send(:include, Goobalize3)