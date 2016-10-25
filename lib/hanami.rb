require 'thread'

# A complete web framework for Ruby
#
# @since 0.1.0
#
# @see http://hanamirb.org
module Hanami
  require 'hanami/version'
  require 'hanami/frameworks'
  require 'hanami/environment'
  require 'hanami/app'
  require 'hanami/application'
  require 'hanami/components'
  require 'hanami/configuration'

  # @api private
  # @since 0.6.0
  DEFAULT_PUBLIC_DIRECTORY = 'public'.freeze

  # @api private
  # @since x.x.x
  @_mutex = Mutex.new

  # Configure Hanami project
  #
  # Please note that the code for this method is generated by `hanami new`.
  #
  # @param blk [Proc] the configuration block
  #
  # @since x.x.x
  #
  # @example
  #   # config/environment.rb
  #
  #   # ...
  #
  #   Hanami.configure do
  #     mount Admin::Application, at: "/admin"
  #     mount Web::Application,   at: "/"
  #
  #     model do
  #       adapter type: :sql, url: ENV['DATABASE_URL']
  #
  #       migrations "db/migrations"
  #       schema     "db/schema.sql"
  #
  #       mapping do
  #         # ...
  #       end
  #     end
  #
  #     mailer do
  #       root "lib/bookshelf/mailers"
  #
  #       delivery do
  #         development :test
  #         test        :test
  #         # production :smtp, address: ENV['SMTP_HOST'], port: 1025
  #       end
  #     end
  #   end
  def self.configure(&blk)
    @_mutex.synchronize do
      @_configuration = Hanami::Configuration.new(&blk)
    end
  end

  # Hanami configuration
  #
  # @return [Hanami::Configuration] the configuration
  #
  # @see Hanami.configure
  #
  # @since x.x.x
  # @api private
  def self.configuration
    @_mutex.synchronize do
      raise "Hanami not configured" unless defined?(@_configuration)
      @_configuration
    end
  end

  # Boot Hanami project
  #
  # @since x.x.x
  # @api private
  def self.boot
    Components.resolve('apps.configurations')
  end

  # Main application that mounts many Rack and/or Hanami applications.
  #
  # This is used as integration point for:
  #
  #   * `config.ru` (`run Hanami.app`)
  #   * Feature tests (`Capybara.app = Hanami.app`)
  #
  # @return [Hanami::App] the app
  #
  # @since x.x.x
  # @api private
  def self.app
    App.new(configuration, environment)
  end

  # Return root of the project (top level directory).
  #
  # @return [Pathname] root path
  #
  # @since 0.3.2
  #
  # @example
  #   Hanami.root # => #<Pathname:/Users/luca/Code/bookshelf>
  def self.root
    environment.root
  end

  # Project public directory
  #
  # @return [Pathname] public directory
  #
  # @since 0.6.0
  # @api private
  #
  # @example
  #   Hanami.public_directory # => #<Pathname:/Users/luca/Code/bookshelf/public>
  def self.public_directory
    root.join(DEFAULT_PUBLIC_DIRECTORY)
  end

  # Return the current environment
  #
  # @return [String] the current environment
  #
  # @since 0.3.1
  #
  # @see Hanami::Environment#environment
  #
  # @example
  #   Hanami.env => "development"
  def self.env
    environment.environment
  end

  # Check to see if specified environment(s) matches the current environment.
  #
  # If multiple names are given, it returns true, if at least one of them
  # matches the current environment.
  #
  # @return [TrueClass,FalseClass] the result of the check
  #
  # @since 0.3.1
  #
  # @see Hanami.env
  #
  # @example Single name
  #   puts ENV['HANAMI_ENV'] # => "development"
  #
  #   Hanami.env?(:development)  # => true
  #   Hanami.env?('development') # => true
  #
  #   Hanami.env?(:production)   # => false
  #
  # @example Multiple names
  #   puts ENV['HANAMI_ENV'] # => "development"
  #
  #   Hanami.env?(:development, :test)   # => true
  #   Hanami.env?(:production, :staging) # => false
  def self.env?(*names)
    environment.environment?(*names)
  end

  # Current environment
  #
  # @return [Hanami::Environment] environment
  #
  # @api private
  # @since 0.3.2
  def self.environment
    Environment.new
  end
end
