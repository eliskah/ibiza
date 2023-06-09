# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

["alice", "bob", "cindy", "daniel"].each_with_index do |name, i|
  role = i.odd? ? :admin : :user
  User.create(email: "#{name}@example.com", role: role, password: "iamsecure")
end

30.times do |i|
  Entry.create(title: "This is entry ##{i+1}")
end
