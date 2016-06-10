#
# Copyright (c) 2015 Magenete Systems OÜ <magenete.systems@gmail.com>.
#

require 'yaml'
require 'i18n'
require 'i18n/backend/fallbacks'


module MAGENETE

  SEPARATOR = '/'

  YAML_FILE_EXTENSION = '.yml'
  RUBY_FILE_EXTENSION = '.rb'

  REG_SPACES = /[\s\t]/

  NAME = File.basename(__FILE__, RUBY_FILE_EXTENSION)

  ROOT_DIR = File.dirname(File.dirname(File.expand_path(__FILE__)))
  CONFIG_DIR = ROOT_DIR + SEPARATOR + 'config' + SEPARATOR
  PUBLIC_DIR = ROOT_DIR + SEPARATOR + 'public'
  VIEWS_DIR = ROOT_DIR + SEPARATOR + 'views'

  LOCALES_FILES = CONFIG_DIR + 'locales/**/*' + YAML_FILE_EXTENSION
  APPLICATION_FILES = File.dirname(File.expand_path(__FILE__)) + SEPARATOR + NAME + SEPARATOR + '**/*' + RUBY_FILE_EXTENSION

  ENV_DEFAULT = :development
  ENCODING_DEFAULT = 'utf-8'
  LOCALE_DEFAULT = :en
  HTML_DEFAULT = :html5

  CONFIGURATION = {}

  def self.set_locale(locale)
    locale = locale.to_sym if locale
    I18n.locale = (CONFIGURATION[:locale][:list].keys.include?(locale))?(locale):(I18n.default_locale)
  end

  def self.get_copyright
    if CONFIGURATION[:company][:year] == Time.now.year
      "#{CONFIGURATION[:company][:year]} #{CONFIGURATION[:company][:copyright]}. #{I18n.t(:vendor)[:copyright]}."
    else
      "#{CONFIGURATION[:company][:year]}-#{Time.now.year} #{CONFIGURATION[:company][:copyright]}. #{I18n.t(:vendor)[:copyright]}."
    end
  end

  def self.init
    CONFIGURATION[:env] = ENV['RACK_ENV']
    if CONFIGURATION[:env]
      CONFIGURATION[:env] = CONFIGURATION[:env].to_sym
    else
      CONFIGURATION[:env] = ENV_DEFAULT
    end

    YAML.load_file(CONFIG_DIR + NAME + YAML_FILE_EXTENSION)[NAME].each do |i|
      if i[1].kind_of?(Hash)
        i[1].keys.each do |ii|
          if i[1][ii].kind_of?(Hash)
            i[1][ii].keys.each do |iii|
              i[1][ii][iii.to_sym] = i[1][ii].delete(iii) if iii.kind_of?(String)
            end
          end
          i[1][ii.to_sym] = i[1].delete(ii)
        end
      end
      CONFIGURATION[i[0].to_sym] = i[1]
    end

    if CONFIGURATION[:html]
      CONFIGURATION[:html] = CONFIGURATION[:html].to_sym
    else
      CONFIGURATION[:html] = HTML_DEFAULT
    end

    CONFIGURATION[:locale] = {} unless CONFIGURATION[:locale]
    if CONFIGURATION[:locale][:list]
      CONFIGURATION[:locale][:list] = CONFIGURATION[:locale][:list].split(REG_SPACES).map!{|i| i.to_sym}
    else
      CONFIGURATION[:locale][:list] = []
    end
    if CONFIGURATION[:locale][:default]
      CONFIGURATION[:locale][:default] = CONFIGURATION[:locale][:default].to_sym
    else
      CONFIGURATION[:locale][:default] = LOCALE_DEFAULT
    end
    unless CONFIGURATION[:locale][:list].include?(CONFIGURATION[:locale][:default])
      CONFIGURATION[:locale][:list] << CONFIGURATION[:locale][:default]
    end

    I18n.enforce_available_locales = false
    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[LOCALES_FILES].sort
    I18n.backend.load_translations
    I18n.default_locale = CONFIGURATION[:locale][:default]
    I18n.available_locales = CONFIGURATION[:locale][:list] & I18n.available_locales
    CONFIGURATION[:locale][:list] = {}
    I18n.available_locales.each do |l|
      I18n.locale = l
      CONFIGURATION[:locale][:list][l] = I18n.t(:vendor)[:locale]
    end
    I18n.locale = I18n.default_locale

    CONFIGURATION[:pages] = {
      :menu => [],
      :path => {}
    }
    I18n.t(:pages).keys.each do |page|
      page = page.to_s
      CONFIGURATION[:pages][:path][page] = {
        :pathes => [],
        :titles => [],
        :name => page.split(SEPARATOR)
      }
      (0..CONFIGURATION[:pages][:path][page][:name].size - 1).each do |i|
        CONFIGURATION[:pages][:path][page][:pathes] << CONFIGURATION[:pages][:path][page][:name][0..i].join(SEPARATOR)
      end
      CONFIGURATION[:pages][:path][page].delete(:name)

      @size = CONFIGURATION[:pages][:path][page][:pathes].size
      if @size == 1
        CONFIGURATION[:pages][:menu] << [I18n.t(:pages)[page.to_sym][:id], CONFIGURATION[:pages][:path][page][:pathes][0], []]
      elsif @size == 2
        CONFIGURATION[:pages][:menu].each do |i|
          if i[1] == CONFIGURATION[:pages][:path][page][:pathes][0]
            i[2] << [I18n.t(:pages)[page.to_sym][:id], CONFIGURATION[:pages][:path][page][:pathes][1], []]
            break
          end
        end
      else

      end
      CONFIGURATION[:pages][:menu] = CONFIGURATION[:pages][:menu].sort
      CONFIGURATION[:pages][:menu].each do |i|
        i[2] = i[2].sort
      end
    end

    CONFIGURATION[:server] = {}
    YAML.load_file(CONFIG_DIR + 'server' + YAML_FILE_EXTENSION)[CONFIGURATION[:env].to_s].each do |i|
      CONFIGURATION[:server][i[0].to_sym] = i[1]
    end

    if CONFIGURATION[:locale][:list].keys.include?(CONFIGURATION[:locale][:default])
      Dir[APPLICATION_FILES].reverse.each do |f|
        require f if File.file?(f)
      end
    end

    instance_variables.each do |i|
      remove_instance_variable(i)
    end
  end

end
