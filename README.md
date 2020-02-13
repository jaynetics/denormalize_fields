# DenormalizeFields

[![Gem Version](https://badge.fury.io/rb/denormalize_fields.svg)](http://badge.fury.io/rb/denormalize_fields)
[![Build Status](https://travis-ci.org/jaynetics/denormalize_fields.svg?branch=master)](https://travis-ci.org/jaynetics/denormalize_fields)

This gem adds a `denormalize` option to ActiveRecord relation definitions, so that updates on one record are forwarded to its dependent records.

Tested on Rails 6, but should work down to Rails 4.1.

## Installation

Add, install or require `denormalize_fields`.

## Usage

Either:

```ruby
class User < ApplicationRecord
  has_many :posts, denormalize: { fields: %i[first_name last_name] }
end
```

Or:

```ruby
DenormalizeFields.denormalize(
  fields: %i[first_name last_name],
  from:   User,
  onto:   :posts,
)
```

Resulting behavior:

```ruby
User.first.posts.pluck(:first_name) # => ['Igor', 'Igor']
User.first.update!(first_name: 'Wanja')
User.first.posts.pluck(:first_name) # => ['Wanja', 'Wanja']
```

Any validation errors of dependent records are bubbled up to the source record.

There is also a `prefix` option:

```ruby
# assuming there is Rapper#name and Car#owner_name
class Rapper < ApplicationRecord
  has_many :cars, denormalize: { fields: :name, prefix: :owner_ } }
end
```

Alternatively `fields` also accepts a `Hash` to map to other fields on the related record:

```ruby
# assuming there is Rapper#name and Car#owner
class Rapper < ApplicationRecord
  has_many :cars, denormalize: { fields: { name: :owner } }
end
```

## Caveats

- only works with fields that are in the database, no virtual attributes etc.
- does not work with `has_and_belongs_to_many` associations
- is based on `ActiveRecord` callbacks, so does not work for `#update_column` etc.
- does no denormalization when related records are first created / connected

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jaynetics/denormalize_fields.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Comparison with similar projects

Most of these have not been updated in years. Let me know if there is any cool new stuff.

- https://github.com/ursm/activerecord-denormalize
  - similar goal
  - runs custom SQL, so does not work with all DBs
  - skips validations of related records
  - only supports `has_many` relations, not `has_one` or `belongs_to`
- https://github.com/bebanjo/persistize
  - for denormalization onto the *same* record or owner record only
- https://github.com/ignu/denormalize-field
  - for denormalization onto the *same* record or owner record only
  - postgres only
- https://github.com/logandk/mongoid_denormalize
  - similar goal
  - mongoid only
