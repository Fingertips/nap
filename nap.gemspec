# frozen_string_literal: true

require File.expand_path('lib/rest', __dir__)

Gem::Specification.new do |spec|
  spec.name = 'nap'
  spec.version = REST::VERSION

  spec.author = 'Manfred Stienstra'
  spec.email = 'manfred@fngtps.com'
  spec.homepage = 'https://github.com/Fingertips/nap'
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
  ]

  spec.extra_rdoc_files = ['README.md', 'LICENSE']
  spec.rdoc_options << '--charset=utf-8'

  spec.add_development_dependency('minitest', '~> 6')
  spec.add_development_dependency('rake', '~> 13')

  spec.required_ruby_version = ">= 3.3"
  spec.metadata['rubygems_mfa_required'] = 'true'
end
