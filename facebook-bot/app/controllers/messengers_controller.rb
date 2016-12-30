class MessengersController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    render :json => params["hub.challenge"]
  end

  def create
    messaging_events = params[:entry][0][:messaging]
    messaging_events.each do |event|
      sender = event[:sender][:id]
      if event[:message]
        text ||= event[:message][:text]
        if event[:message][:attachments]
          event[:message][:attachments].each do |attach|
            if attach[:type] == "image"
              description = describe_image attach[:payload][:url]
              text = text.to_s+description["text"].to_s+"\n"
            end
          end
        end
        send_text_message sender, text
      end
    end
    render :json => "ok"
  end

  private
    def send_text_message sender, text
      #config
      token = "EAAI0VJBnQ18BAME4YXKCAuGGZAbtDWYm2iKcNALMgqkHGMayb7AWanYV7oHby3vaStsmloFZB41Wvp5JZAGhgPobZC8pvW0VYN5WWmT6MxnAgzrTZAYlAvyDXI2ScSiNTVdtERj7WSmGn3ZCrWF9R6ZBRvljqDYzJzdWNsDKPzFDAZDZD"
      message_data =  { text: text }
      recipient_data = { id: sender }
      uri = URI.parse("https://graph.facebook.com/v2.6/me/messages?access_token=" + token)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      params = { recipient: recipient_data, message: message_data }
      header = {"Content-Type" =>"application/json"}
      resp = http.post(uri.request_uri, params.to_json, header)
      resp
    end

    def describe_image url
      uri = URI('https://api.projectoxford.ai/vision/v1.0/describe')
      uri.query = URI.encode_www_form({
          # Request parameters
          'maxCandidates' => '1'
      })
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      request['Ocp-Apim-Subscription-Key'] = 'cbbf9a1e82c04f5c9969c080a49c4187'
      request.body = "{url: \"#{url}\"}"
      response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
      end
      json = ActiveSupport::JSON.decode response.body
      json["description"]["captions"][0]
    end
end
