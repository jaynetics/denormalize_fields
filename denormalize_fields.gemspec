require_relative 'lib/denormalize_fields/version'

Gem::Specification.new do |s|
  s.name          = 'denormalize_fields'
  s.version       = DenormalizeFields::VERSION
  s.license       = 'MIT'

  s.summary       = 'Simplify denormalizing fields from one record to another.'
  s.description   = 'This gem adds a `denormalize` option to ActiveRecord '\
                    'relation definitions, e.g. `has_many :foos, '\
                    'denormalize: { fields: :updated_at }`.'
  s.homepage      = 'https://www.github.com/jaynetics/denormalize_fields'

  s.files         = ['lib/denormalize_fields.rb',
                     'lib/denormalize_fields/version.rb']

  s.authors       = ['Janosch Müller']
  s.email         = ['janosch84@gmail.com']

  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  s.add_dependency 'activerecord', '>= 4.1.14', '< 7.0.0'

  s.add_development_dependency 'rails', '>= 4.1.14', '< 7.0.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
end
