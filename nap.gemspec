require File.expand_path('../lib/rest', __FILE__)

Gem::Specification.new do |spec|
  spec.name = 'nap'
  spec.version = REST::VERSION

  spec.author = "Manfred Stienstra"
  spec.email = "manfred@fngtps.com"
  spec.homepage = "https://github.com/Fingertips/nap"
  spec.licenses = ['MIT']

  spec.description = <<-EOF
    Nap is a really simple REST library. It allows you to perform HTTP requests
    with minimal amounts of code.
  EOF
  spec.summary = <<-EOF
    Nap is a really simple REST library.
  EOF

  spec.files = [
    'lib/rest.rb',
    'lib/rest/error.rb',
    'lib/rest/request.rb',
    'lib/rest/response.rb',
    'support/cacert.pem'
  ]

  spec.has_rdoc = true
  spec.extra_rdoc_files = ['README.md', 'LICENSE']
  spec.rdoc_options << "--charset=utf-8"

  spec.add_development_dependency('rake', '~> 12')
  spec.add_development_dependency('peck', '~> 0.5')
end
