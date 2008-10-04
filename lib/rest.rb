require 'uri'

module REST
  def self.get(uri, headers={}, options={})
    REST::Request.perform(:get, URI.parse(uri), nil, headers, options)
  end
  
  def self.head(uri, headers={}, options={})
    REST::Request.perform(:head, URI.parse(uri), nil, headers, options)
  end
  
  def self.put(uri, body, headers={}, options={})
    REST::Request.perform(:put, URI.parse(uri), body, headers, options)
  end
  
  def self.post(uri, body, headers={}, options={})
    REST::Request.perform(:post, URI.parse(uri), body, headers, options)
  end
end

require File.expand_path('../rest/request', __FILE__)
require File.expand_path('../rest/response', __FILE__)