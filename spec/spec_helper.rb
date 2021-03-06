# encoding: utf-8

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

load File.dirname(__FILE__) + '/schema.rb'
require File.dirname(__FILE__) + '/models.rb'

require 'spreadsheet_importer'
