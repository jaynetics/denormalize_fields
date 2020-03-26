ActiveRecord::Schema.define(version: 20151110173325) do
  create_table 'blogs', force: :cascade do |t|
    t.string 'topic'
  end

  create_table 'posts', force: :cascade do |t|
    t.integer 'blog_id'
    t.string 'topic'
    t.string 'body'
  end

  create_table 'comments', force: :cascade do |t|
    t.integer 'post_id'
    t.string 'topic'
    t.string 'body'
  end

  ######

  create_table 'programmers', force: :cascade do |t|
    t.string 'name'
    t.integer 'happiness'
  end

  create_table 'kings', force: :cascade do |t|
    t.string 'first_name'
    t.string 'last_name'
  end

  create_table 'pizzas', force: :cascade do |t|
    t.integer 'programmer_id'
    t.integer 'king_id'
    t.string 'owner_name'
    t.integer 'happiness'
  end

  ######

  create_table 'renters', force: :cascade do |t|
    t.timestamps
  end

  create_table 'houses', force: :cascade do |t|
    t.datetime :renter_changed_at
  end

  create_table 'rental_agreements', force: :cascade do |t|
    t.integer 'renter_id'
    t.integer 'house_id'
  end

  ######

  create_table 'symbionts', force: :cascade do |t|
    t.integer 'symbiont_id'
    t.integer 'happiness'
  end
end
