require 'rubygems'

Gem::Specification.new do |spec|
  spec.name = 'nap'
  spec.version = '0.1'
  
  spec.author = "Manfred Stienstra"
  spec.email = "manfred@fngtps.com"

  spec.description = <<-EOF
    Nap is a really simple REST API.
  EOF
  spec.summary = <<-EOF
    Nap is a really simple REST API.
  EOF

  spec.files = Dir['lib/**/*.rb']

  spec.has_rdoc = true
  spec.extra_rdoc_files = ['README', 'LICENSE']
  spec.rdoc_options << "--charset=utf-8"
end