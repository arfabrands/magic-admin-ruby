# frozen_string_literal: true

# Magic Ruby bindings
require "etc"
require "json"
require "net/http"
require "uri"
require "base64"
require "eth"

# Version
require "magic_admin/version"

# Magic API Classes
require "magic_admin/util"
require "magic_admin/config"
require "magic_admin/errors"

# HTTP Classes
require "magic_admin/http/client"
require "magic_admin/http/request"
require "magic_admin/http/response"

# Magic Resource Classes
require "magic_admin/token"
require "magic_admin/user"

# Magic Class to access resources
class Magic
  attr_reader :secret_key, :http_client

  # Description:
  #   The constructor allows you to specify your own API secret key
  #   and HTTP request strategy when your application is interacting
  #   with the Magic API.
  #
  #   it will automatically configuring required argument
  #   using following environment variables
  #   MAGIC_API_SECRET_KEY
  #   MAGIC_API_RETRIES
  #   MAGIC_API_TIMEOUT
  #   MAGIC_API_BACKOFF

  # Arguments:
  #   api_secret_key: Your API Secret Key retrieved from the Magic Dashboard.
  #   retries: Total number of retries to allow.
  #   timeout: A period of time the request is going to wait for a response.
  #   backoff: A backoff factor to apply between retry attempts.
  #
  # Returns:
  #   A Magic object that provides access to all the supported resources.

  def initialize(api_secret_key: nil,
                 retries: nil,
                 timeout: nil,
                 backoff: nil)
    secret_key!(api_secret_key)
    http_client!(retries, timeout, backoff)
  end

  # Description:
  #   Method provides you User object
  #   for interacting with the Magic API.
  #
  # Returns:
  #   A User object that provides access to all the supported resources.

  def user
    MagicAdmin::User.new(self)
  end

  # Description:
  #   Method provides you Token object
  #   for various utility methods of Token.
  #
  # Returns:
  #   A Token object that provides access to all the supported resources.

  def token
    MagicAdmin::Token.new
  end

  private

  def secret_key?
    !(secret_key.nil? || secret_key.empty?)
  end

  def secret_key!(api_secret_key)
    @secret_key = api_secret_key || ENV["MAGIC_API_SECRET_KEY"]
    message = "Magic api secret key was not found."

    raise MagicAdmin::MagicError.new(message) unless secret_key?
  end

  def http_client!(retries, timeout, backoff)
    @http_client = MagicAdmin::Http::Client
                   .new(MagicAdmin::Config.api_base,
                        retries || ENV["MAGIC_API_RETRIES"] || 3,
                        timeout || ENV["MAGIC_API_TIMEOUT"] || 5,
                        backoff || ENV["MAGIC_API_BACKOFF"] || 0.02)
  end
end