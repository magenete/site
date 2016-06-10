#
# Copyright (c) 2015 Magenete Systems OÜ <magenete.systems@gmail.com>.
#

require 'sinatra'
require 'sinatra/default_charset'
require 'slim'


module MAGENETE
  class Application < Sinatra::Base

    PATH_ROOT = SEPARATOR + ':locale'
    PATH_PAGE = PATH_ROOT + SEPARATOR + '*'

    configure do
      set :environment, CONFIGURATION[:env]
      set :port, CONFIGURATION[:server][:port]
      set :server, CONFIGURATION[:server][:name]
      set :bind, CONFIGURATION[:server][:bind]

      set :haml, :format => CONFIGURATION[:html]
      set :default_charset, ENCODING_DEFAULT
      set :public_folder, PUBLIC_DIR
      set :views, VIEWS_DIR
      set :root, ROOT_DIR

      set :sessions, true

      enable :static_cache_control
      disable :show_exceptions
    end

    before do
      if request.path_info[-1, 1] == SEPARATOR && request.path_info != SEPARATOR
        request.path_info = request.path_info.chop
      end
    end

    helpers do
      def _t(*args)
        I18n.t(*args)
      end
      include Rack::Utils
      alias_method :h, :escape_html
    end

    get "#{SEPARATOR}*.css" do
      content_type "text#{SEPARATOR}css"
      pass
    end

    get SEPARATOR do
      redirect SEPARATOR + MAGENETE.set_locale(nil).to_s
    end

    get PATH_ROOT do |locale|
      MAGENETE.set_locale(locale)
      if locale.to_sym == I18n.locale
        @js_file = :slide_show
        @root = true
        slim :root, :locals => {:page => :root,
                                :title => _t(:root)[:title],
                                :keywords => _t(:root)[:keywords],
                                :description => _t(:root)[:description]}
      else
        redirect SEPARATOR + I18n.locale.to_s
      end
    end

    get PATH_PAGE do |locale, page|
      MAGENETE.set_locale(locale)
      if CONFIGURATION[:pages][:path].keys.include?(page)
        if locale.to_sym == I18n.locale
          CONFIGURATION[:pages][:path][page][:titles].clear
          _t(:pages)[page = page.to_sym][:page] = page
          _t(:pages)[page].merge!(CONFIGURATION[:pages][:path][page.to_s])
          _t(:pages)[page][:pathes].each do |path|
            _t(:pages)[page][:titles] << I18n.t(:pages)[path.to_sym][:title]
          end
          @view_map = _t(:pages)[page][:view_map]
p _t(:pages)[page]
          slim page, :locals => _t(:pages)[page]
        else
          redirect SEPARATOR + I18n.locale.to_s + SEPARATOR + page
        end
      else
        redirect SEPARATOR + I18n.locale.to_s
      end
    end

    not_found do
      redirect SEPARATOR
    end

    error do
      redirect SEPARATOR
    end

  end
end
