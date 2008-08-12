require 'uri'

module REST
  def self.get(uri, headers={})
    REST::Request.perform(:get, URI.parse(uri), nil, headers)
  end
  
  def self.head(uri, headers={})
    REST::Request.perform(:head, URI.parse(uri), nil, headers)
  end
  
  def self.put(uri, body, headers={})
    REST::Request.perform(:put, URI.parse(uri), body, headers)
  end
  
  def self.post(uri, body, headers={})
    REST::Request.perform(:post, URI.parse(uri), body, headers)
  end
end

require File.expand_path('../rest/request', __FILE__)
require File.expand_path('../rest/response', __FILE__)