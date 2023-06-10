# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#

30.times do |i|
  Entry.create(title: "This is entry ##{i+1}")
end

pg = PermissionGateway.new

["alice", "bob", "cindy", "daniel"].each_with_index do |name, i|
  role = i.odd? ? :admin : :user
  user = User.create(email: "#{name}@example.com", role: role, password: "iamsecure")
  next if user.admin?

  Entry.all.each_with_index do |entry, j|
    next unless j % (i+1) == 0
    pg.permit_read!(user: user, entry: entry)
    pg.permit_write!(user: user, entry: entry) if j == i
  end
end
