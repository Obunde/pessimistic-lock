User.create(name: "admin", email: "admin@gmail.com", password: "password", password_confirmation: "password", admin: true)
User.create(name: "user", email: "user@gmail.com", password: "password", password_confirmation: "password")
items = ["Chicken","Beef","Pork","Potato","Carrot","Cabbage","Chinese Cabbage","Eggplant","Onion","Salt","Salad Oil"]
items.each do |item|
  Item.create!(name:item)
end
