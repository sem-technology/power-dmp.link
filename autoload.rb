require 'bundler'
Bundler.require(:default)

require 'logger'
require 'pp'
require 'time'
require 'json'
require 'open-uri'
require 'csv'

require_relative "./lib/application"
# require_relative "./lib/application/config"
# require_relative "./lib/application/log"

require 'active_support/dependencies'
ActiveSupport::Dependencies.autoload_paths << Application.root.join("lib").to_s
# ActiveSupport::Dependencies.autoload_paths << Application.root.join("app", "services")
# ActiveSupport::Dependencies.autoload_paths << Application.root.join("app", "accounts")
# ActiveSupport::Dependencies.autoload_paths << Application.root.join("lib", "dataset")

