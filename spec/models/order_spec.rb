# spec/models/order_spec.rb
require 'rails_helper'

RSpec.describe Order, type: :model do
  describe "#update_total_quantity" do
    let!(:item) { Item.create!(name: "Test Item", total_quantity: 0) }
    let!(:user) { User.create!(name: "User", email: "user@example.com", password: "password") }

    it "increments the item's total_quantity when an order is saved" do
      order = user.orders.create!
      order.ordered_lists.create!(item: item, quantity: 5)

      order.update_total_quantity

      expect(item.reload.total_quantity).to eq(5)
    end
  end
end