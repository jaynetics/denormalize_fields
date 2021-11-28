RSpec.describe DenormalizeFields do
  it 'has a version number' do
    expect(DenormalizeFields::VERSION).to(match /\A\d+\.\d+\.\d+\z/)
  end

  it 'works with `has_many` associations' do
    blog = Blog.create!
    post1 = blog.posts.create!(body: 'foo')
    post2 = blog.posts.create!(body: 'bar')
    expect { blog.update!(topic: 'Pizza') }
      .to  change { post1.topic }.to('Pizza')
      .and change { post2.topic }.to('Pizza')
  end

  it 'works with `belongs_to` associations' do
    programmer = Programmer.create!(name: 'Igor')
    pizza = programmer.create_pizza!(owner_name: 'Igor')
    expect { pizza.update!(happiness: 10) }
      .to change { programmer.happiness }.to(10)
  end

  it 'works with `has_one` associations (and prefixes)' do
    programmer = Programmer.create!(name: 'Igor')
    pizza = programmer.create_pizza!(owner_name: 'Igor')
    expect { programmer.update!(name: 'Wanja') }
      .to change { pizza.owner_name }.to('Wanja')
  end

  it 'works with `has_many through` associations (and timestamps & mappings)' do
    renter = Renter.create!
    house = renter.houses.create!
    expect { renter.update!(updated_at: Time.now) }
      .to change { house.renter_changed_at }
  end

  it 'works recursively' do
    blog = Blog.create!
    post = blog.posts.create!(body: "It's yummy!")
    comment = post.comments.create!
    expect { blog.update!(topic: 'Pizza') }
      .to  change { post.topic }.to('Pizza')
      .and change { comment.topic }.to('Pizza')
  end

  it 'joins multiple source fields to a String using spaces' do
    king = King.create!(first_name: 'Friedrich', last_name: 'Barbarossa')
    pizza = king.pizzas.create!(owner_name: 'Friedrich Barbarossa')
    expect { king.update!(first_name: 'King', last_name: 'Awesome') }
      .to change { pizza.owner_name }.to('King Awesome')
    expect { king.update!(last_name: 'Nothing') }
      .to change { pizza.owner_name }.to('King Nothing')
  end

  it 'does not get stuck in a loop (and accepts single args)' do
    symbiont_a = Symbiont.create!
    symbiont_b = symbiont_a.create_symbiont!
    expect { symbiont_a.update!(happiness: 10) }
      .to change { symbiont_b.happiness }.to(10)
  end

  it 'cancels updates if related records cannot be updated' do
    programmer = Programmer.create!(name: 'Igor')
    pizza = programmer.create_pizza!(owner_name: 'Igor')
    # Note: there is no validation on Programmer#name.
    expect(programmer.update(name: '')).to be false
    expect { programmer.update!(name: '') }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'reveals errors from related records' do
    programmer = Programmer.create!(name: 'Igor')
    pizza = programmer.create_pizza!(owner_name: 'Igor')
    # Note: there is no validation on Programmer#name.
    expect { programmer.update(name: '') }
      .to change { programmer.errors[:name].present? }.to(true)
  end

  it 'does not update related records if owner validation fails' do
    post = Post.create!(body: "It's yummy!", topic: 'Pizza')
    comment = Comment.create!(body: "+1", topic: 'Pizza')
    expect { post.update(body: nil, topic: 'Platonic love') }
      .not_to change { comment.topic }
    expect do
      post.assign_attributes(body: nil, topic: 'Platonic love')
      post.save(validate: false)
    end.not_to change { comment.topic }
  end

  it 'does not fail if the related record is missing' do
    programmer = Programmer.create!(name: 'Igor') # has_one :pizza
    expect { programmer.update!(name: 'Wanja') }
      .to change { programmer.name }.to('Wanja')
  end

  it 'does not sync fields that have not been marked for denormalization' do
    post = Post.create!(body: 'foo')
    comment = post.comments.create!(body: 'bar')
    expect { post.update!(body: 'qux') }.not_to change { comment.body }
  end

  it 'can be toggled via if: option and with a method name argument' do
    symbiont_a = Symbiont.create!
    symbiont_b = symbiont_a.create_symbiont!
    expect { symbiont_a.update!(happiness: 9000) }
      .not_to change { symbiont_b.happiness }
  end

  it 'can be toggled via unless: option and with a proc argument' do
    blog = Blog.create!
    post = blog.posts.create!(body: 'foo')
    expect { blog.update!(topic: 'XXX') }.not_to change { post.topic }
  end

  it 'does not allow weird stuff as conditionals' do
    expect { Blog.has_many :posts, denormalize: { fields: :topic, if: 7 } }
      .to raise_error(ArgumentError, /if:/)
  end
end
