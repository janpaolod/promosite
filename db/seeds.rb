puts 'Creating Cities'
cities = [
  'Caloocan', 'Las Pinas', 'Makati', 'Mandaluyong', 'Marikina', 'Muntinlupa',
  'Pasay', 'Pasig', 'Paranaque', 'Quezon City', 'San Juan', 'Taguig'
]

cities.each do |city_name|
  City.create!( :name => city_name )
end

puts 'Creating business types: Leisure, Shopping, Dine Out'
['Leisure', 'Shopping', 'Dine out'].each do |classification|
  Classification.create!(:name => classification)
end

def create_merchant(name, iterator, business_types)
  @details = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam varius massa sed quam eleifend venenatis. Mauris feugiat nunc massa. Nullam et volutpat enim. Aliquam erat volutpat. Morbi consectetur tempus tellus, posuere diam mollis quis volutpat."
  
  m = Merchant.create!(:email => "merchant#{iterator}@twiggzy.com", :password => 'foobar', :name => name, :info => @details)
  m.set_classifications( business_types )
  m.branches.create!(:name => "#{m.name} in Libis", :address => '123 Somewhere in Libis', :city => City.where(:name => 'Quezon City').first, :contact_number => '123-4567')
  m
end

def create_promo(merchant, status, featured, classifications)
  p = merchant.promos.build(
    :name                   => "30% off on #{classifications.map{|c| c.name }.join(', ') }#{featured ? ' - featured' : nil} by #{merchant.name}",
    :details                => @details,
    :manual_code            => "12345678",
    :status                 => status,
    :featured               => featured,
    :coupon_validity_end    => 13.days.from_now,
    :price_actual           => 100,
    :price_discounted       => 70,
    :quota                  => 100,
    :branch                 => [merchant.branches.first.name])
  p.set_branches merchant.branches
  p.set_classifications classifications
  p
end

puts "Creating Admin: admin@twiggzy.com foobar"
Admin.create!(:email => 'admin@twiggzy.com', :password => 'foobar')

puts "Creating User: user@filsale.com foobar"
User.create!(:first_name => 'Ufirst', :last_name => 'Ulast', :email => 'user@twiggzy.com', :password => 'foobar', :agree => true)

puts "Creating Merchant: merchant@twiggzy.com foobar"
classifications = Classification.all
merchant = create_merchant('Default Merchant', nil, classifications)
puts "Creating promos for merchant"
create_promo(merchant, :active, true, classifications)
create_promo(merchant, :pending, false, classifications)

puts "Creating 2 more shopping merchants"
2.times do |n|
  name = info = "Shopping Merchant #{n}"
  classifications = Classification.where(:permalink => 'shopping')
  merchant = create_merchant(name, n, classifications)
  create_promo(merchant, :active, true, classifications)
  create_promo(merchant, :pending, false, classifications)
end

puts "Creating 2 more leisure merchants"
2.times do |n|
  name = info = "Leisure Merchant #{n}"
  classifications = Classification.where(:permalink => 'leisure')
  merchant = create_merchant(name, n+2, classifications)
  create_promo(merchant, :active, true, classifications)
  create_promo(merchant, :pending, false, classifications)
end

puts "Creating 2 more dine out merchants"
2.times do |n|
  name = info = "Dine out Merchant #{n}"
  classifications =  Classification.where(:permalink => 'dine-out')
  merchant = create_merchant(name, n+4, classifications)
  create_promo(merchant, :active, true, classifications)
  create_promo(merchant, :pending, false, classifications)
end
