require 'net/http'

uri = URI('https://api.projectoxford.ai/vision/v1.0/describe')
uri.query = URI.encode_www_form({
    # Request parameters
    'maxCandidates' => '1'
})

request = Net::HTTP::Post.new(uri.request_uri)
# Request headers
request['Content-Type'] = 'application/json'
# Request headers
request['Ocp-Apim-Subscription-Key'] = 'cbbf9a1e82c04f5c9969c080a49c4187'
# Request body
request.body = "{url: \"https://scontent.xx.fbcdn.net/v/t35.0-12/15778198_713320535511669_1152555735_o.jpg?_nc_ad=z-m&oh=af32d01f4a2b2377432317cb611c866f&oe=5863C5ED\"}"

response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
    http.request(request)
end

puts response.body
