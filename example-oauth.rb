require 'maicoin'

#### OAuth2
client_id = ENV['CLIENT_ID'] # Replace with your MaiCoin OAuth2 application id
client_secret = ENV['CLIENT_SECRET'] # Replace with your MaiCoin OAuth2 application secret
access_token = ENV['ACCESS_TOKEN'] # Replace with user's access token
refresh_token = ENV['REFRESH_TOKEN'] # Replace with user's refresh token

user_credentials = {
  :access_token => access_token,
  :refresh_token => refresh_token,
  :expires_at => Time.now + 7200
}

client = MaiCoin::OAuthClient.new(client_id, client_secret, user_credentials)

puts 'Account'
puts client.user
puts client.balance
pin = '1234'
puts client.create_account_pin(pin)
puts client.receive_address
puts client.addresses
puts client.generate_receive_address

puts 'Orders'
puts client.orders
puts client.orders(1, {limit: 10})
puts client.buy_btc 1.5
puts client.sell_btc 8.67548553

puts 'Transactions'
puts client.transactions
puts client.transactions(1, {limit: 5})
puts client.transaction('3186b3ed822e8db414e4a6145a45934e01e3038911ebd9ef')
trans = client.request_btc('yute@maicoin.com', 1, 'btc', {notes: 'Show me the coin'})
puts trans
puts client.cancel_request_btc(trans['transaction']['id'])
puts client.send_transaction('yute@maicoin.com', 0.001, 'btc', pin)
puts client.send_transaction('1FTv5Ymfq1uT9N9ZrmYRgpKw69U6grnm64', 0.0011, 'btc', pin)

