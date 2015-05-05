require 'maicoin'
require 'json'

# Public API
client = MaiCoin::Client.new
puts 'Get prices'
puts client.prices
puts client.prices 'USD'

puts 'Get currencies'
puts client.currencies

# Authorized API
API_KEY = ENV['API_KEY'] # Replace with your MaiCoin api key
API_SECRET = ENV['API_SECRET'] # Replace with your MaiCoin api secret
client = MaiCoin::Client.new(API_KEY, API_SECRET)

puts 'Account'
puts client.balance
puts client.user
puts client.receive_address
puts client.addresses
puts client.generate_receive_address
pin = '1234'
puts client.create_account_pin(pin)

puts 'Orders'
puts client.orders
puts client.orders(1, {limit: 10})
puts client.buy_btc 1.5
puts client.sell_btc 8.67548553

puts 'Transactions'
puts client.transactions
puts client.transactions(1, {limit: 5})
puts client.transaction('b09af0fc364a2d1b5cfe3e2a9e717dfe7309f302a9de386d')
trans = client.request_btc('yute@maicoin.com', 1, 'btc', {notes: 'Show me the coin'})
puts trans
puts client.cancel_request_btc(trans['transaction']['id'])
puts client.send_transaction('yute@maicoin.com', 0.001, 'btc', pin)
puts client.send_transaction('1FTv5Ymfq1uT9N9ZrmYRgpKw69U6grnm64', 0.0011, 'btc', pin)

puts 'Checkouts' ## Only available for merchant account
checkout = MaiCoin::CheckoutParamBuilder.new
checkout.set_checkout_data(5, 'twd', 'http://my.com/return', 'http://my.com/cancel', 'http://i.my.com/callback',
                           {'merchant_ref_id'=>'32', 'pos_data'=>'Test POS data', 'locale'=>'en'})
checkout.set_buyer_data('name' => 'abc', 'address1'=> 'apt 123', 'address2'=> 'road 456', 'city'=> 'sf',
                        'state'=> 'ca', 'zip'=> '94305', 'email'=>'abc@gmail.com',
                        'phone'=>'6504349399', 'country'=>'US')
checkout.add_item('description'=>'desc1', 'code'=> '1111', 'price'=> '3243', 'currency_type'=> 'twd', 'is_physical'=> true)
checkout.add_item('description'=> 'desc2', 'code'=> '2222', 'price'=> '3243', 'currency_type'=> 'twd', 'is_physical'=> false)
puts checkout.build.to_json
checkout_result = client.create_checkout(checkout.build)
puts checkout_result
puts checkout_result['checkout']['checkout_url']

puts client.checkout(checkout_result['checkout']['uid']).to_json
puts client.checkouts(2, {limit: 1}).to_json
