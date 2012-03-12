Gem::Specification.new do |spec|
  spec.name = 'nap'
  spec.version = '0.5'

  spec.author = "Manfred Stienstra"
  spec.email = "manfred@fngtps.com"

  spec.description = <<-EOF
    Nap is a really simple REST library. It allows you to perform HTTP requests
    with minimal amounts of code.
  EOF
  spec.summary = <<-EOF
    Nap is a really simple REST library.
  EOF

  spec.files = ['lib/rest.rb', 'lib/rest/request.rb', 'lib/rest/response.rb', 'support/cacert.pem']

  spec.has_rdoc = true
  spec.extra_rdoc_files = ['README', 'LICENSE']
  spec.rdoc_options << "--charset=utf-8"

  spec.add_development_dependency('rake')
  spec.add_development_dependency('test-spec')
  spec.add_development_dependency('mocha')
end
