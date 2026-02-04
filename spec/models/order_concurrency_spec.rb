require 'rails_helper'

RSpec.describe "Pessimistic Locking", type: :model do
  # 🔑 REQUIRED for concurrency tests
   before(:all) do
    RSpec.configuration.use_transactional_fixtures = false
  end

  after(:all) do
    RSpec.configuration.use_transactional_fixtures = true
  end
  
  let!(:item)  { Item.create!(name: "Concurrent Item", total_quantity: 0) }
  let!(:user1) { User.create!(name: "User1", email: "u1@example.com", password: "password") }
  let!(:user2) { User.create!(name: "User2", email: "u2@example.com", password: "password") }

  after do
    OrderedList.delete_all
    Order.delete_all
    Item.delete_all
    User.delete_all
  end

  it "prevents lost updates when two orders update the same item concurrently" do
    threads = []

    threads << Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        Order.transaction do
          order1 = user1.orders.create!
          order1.ordered_lists.create!(item: item, quantity: 5)

          order1.update_total_quantity
          sleep 1 # force overlap while holding the lock
        end
      end
    end

    threads << Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        Order.transaction do
          order2 = user2.orders.create!
          order2.ordered_lists.create!(item: item, quantity: 5)

          order2.update_total_quantity
        end
      end
    end

    threads.each(&:join)

    expect(item.reload.total_quantity).to eq(10)
  end
end
