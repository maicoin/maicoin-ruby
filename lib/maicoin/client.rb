require 'httparty'
require 'multi_json'
require 'hashie'
require 'money'
require 'monetize'
require 'time'
require 'securerandom'

module MaiCoin
  class Client
    include HTTParty

    BASE_URI = 'https://api.maicoin.com/v1'

    def initialize(api_key='', api_secret='', options={})
      @api_key = api_key
      @api_secret = api_secret

      # defaults
      options[:base_uri] ||= BASE_URI
      @base_uri = options[:base_uri]
      options[:format]   ||= :json
      options.each do |k,v|
        self.class.send k, v
      end
    end

    ######### Start of API #########

    ### Prices
    def prices (currency='TWD')
      get '/prices/' + currency
    end

    ### Currencies
    def currencies
      get '/currencies'
    end

    ### Account
    def balance
      get '/account/balance'
    end

    def receive_address(currency='btc')
      get "/account/receive_address/#{currency}"
    end

    def addresses(currency='btc')
      get "/account/addresses/#{currency}"
    end

    def generate_receive_address(currency='btc', options={})
      options.merge!({currency: currency})
      post '/account/receive_address', options
    end

    def user
      get '/user'
    end

    def create_account_pin(pin, options={})
      options.merge!( {pin: pin})
      post '/user/account_pin', options
    end

    def update_account_pin(old_pin, new_pin, options={})
      options.merge!( {old_pin: old_pin, new_pin: new_pin})
      put '/user/account_pin', options
    end

    ### Orders, options:{limit:25}
    def orders (page=1, options ={})
      get '/orders',{page: page}.merge(options)
    end

    def order (txid)
      get "/orders/#{txid}"
    end

    def buy_btc (amount)
      buy_order(amount, 'btc')
    end

    def buy_order(amount, currency='btc')
      options = {amount: amount, type: 'buy', currency: currency}
      create_order(options)
    end

    def sell_btc (amount)
      options = {amount: amount, type: 'sell'}
      create_order(options)
    end

    def create_order (options={})
      post '/orders', options
    end

    ### Transactions, option:{limit:25}
    def transactions (page=1, options={})
      get '/transactions', {page:page}.merge(options)
    end

    def transaction (txid)
      get "/transactions/#{txid}"
    end

    # options:{notes: ""}
    def request_btc (address, amount, currency, options = {})
      request_transaction(address, amount, currency, options)
    end

    def cancel_request_btc (txid)
      cancel_request_transaction(txid)
    end

    # btc transactions
    def send_transaction(address, amount, currency, account_pin=nil, options={})
      options.merge!( { type: 'send',
                        account_pin: account_pin,
                        currency: currency,
                        address: address,
                        amount: amount})
      post '/transactions', options
    end

    def request_transaction(address, amount, currency, options={})
      options.merge!( { type: 'request',
                        address: address,
                        amount: amount,
                        currency: currency})
      post '/transactions', options
    end

    def cancel_request_transaction(txid)
      delete "/transactions/#{txid}"
    end

    ### Checkouts
    def create_checkout(options = {})
      post '/checkouts', options
    end

    def checkout(uid)
      get "/checkouts/#{uid}"
    end

    def checkouts (page=1, options={})
      get '/checkouts', {page:page}.merge(options)
    end

    ######### End of API #########


    # Wrappers for the main HTTP verbs
    def get(path, options={})
      http_verb :get, path, options
    end

    def post(path, options={})
      http_verb :post, path, options
    end

    def put(path, options={})
      http_verb :put, path, options
    end

    def delete(path, options={})
      http_verb :delete, path, options
    end

    def self.whitelisted_cert_store
      @@cert_store ||= build_whitelisted_cert_store
    end

    def self.build_whitelisted_cert_store
      path = File.expand_path(File.join(File.dirname(__FILE__), 'ca-maicoin.crt'))

      certs = [ [] ]
      File.readlines(path).each{|line|
        next if ["\n","#"].include?(line[0])
        certs.last << line
        certs << [] if line == "-----END CERTIFICATE-----\n"
      }

      result = OpenSSL::X509::Store.new

      certs.each{|lines|
        next if lines.empty?
        cert = OpenSSL::X509::Certificate.new(lines.join)
        result.add_cert(cert)
      }

      result
    end

    def ssl_options
      { verify: true, cert_store: self.class.whitelisted_cert_store }
    end

    def http_verb(verb, path, options={})

      nonce = options[:nonce] || (Time.now.to_f * 1e6).to_i

      if [:get, :delete].include? verb
        request_options = {}
        path = "#{path}?#{URI.encode_www_form(options)}" if !options.empty?
        hmac_message = nonce.to_s + @base_uri + path
      else
        request_options = {body: options.to_json}
        hmac_message = nonce.to_s + @base_uri + path + options.to_json
      end

      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @api_secret, hmac_message)

      headers = {
        'ACCESS_KEY' => @api_key,
        'ACCESS_SIGNATURE' => signature,
        'ACCESS_NONCE' => nonce.to_s,
        'Content-Type' => 'application/json',
      }
      request_options[:headers] = headers
      r = self.class.send(verb, path, request_options.merge(ssl_options))
      Hashie::Mash.new(JSON.parse(r.body))
    end

    class Error < StandardError; end
  end

  class CheckoutParamBuilder

    def initialize
      @checkout_data = {}
      @buyer_data = {}
      @items = []
    end

    def set_checkout_data(amount, currency, return_url, cancel_url, callback_url,options={})
      @checkout_data.merge!({
        'amount'=>amount.to_s,
        'currency'=>currency.to_s,
        'return_url'=>return_url.to_s,
        'cancel_url'=>cancel_url.to_s,
        'callback_url'=>callback_url.to_s,
        'merchant_ref_id'=>options['merchant_ref_id'].to_s,
        'pos_data'=>options['pos_data'].to_s,
        'locale'=>options['locale'].to_s
      })
    end

    def set_buyer_data(options={})
      @buyer_data.merge!({
        'buyer_name' => options['name'].to_s,
        'buyer_address1' => options['address1'].to_s,
        'buyer_address2' => options['address2'].to_s,
        'buyer_city' => options['city'].to_s,
        'buyer_state' => options['state'].to_s,
        'buyer_zip' => options['zip'].to_s,
        'buyer_email' => options['email'].to_s,
        'buyer_phone' => options['phone'].to_s,
        'buyer_country' => options['country'].to_s
      })
    end

    def add_item(options={})
      @items << {
        'item' => {
          'description'=>options['description'].to_s,
          'code'=>options['code'].to_s,
          'price'=>options['price'].to_s,
          'currency'=>options['currency_type'].to_s,
          'is_physical'=>options['is_physical'].to_s}
      }
    end

    def build
      buyer = {'buyer'=>@buyer_data}
      items = {'items'=>@items}
      result = {
        'checkout' => @checkout_data.merge(buyer).merge(items)
      }
      return result
    end

  end
end
