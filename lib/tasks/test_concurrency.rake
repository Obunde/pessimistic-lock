namespace :test do
  desc "Test concurrent order creation"
  task concurrency: :environment do
    # Clean up and prepare test data
    OrderedList.destroy_all
    Order.destroy_all
    Item.destroy_all
    User.destroy_all

    # Create test item and users
    item = Item.create!(name: "Concurrent Test Item", total_quantity: 0)
    user1 = User.create!(name: "User1", email: "user1@test.com", password: "password")
    user2 = User.create!(name: "User2", email: "user2@test.com", password: "password")

    puts "Initial item quantity: #{item.total_quantity}"
    puts "\nStarting concurrent orders..."

    # Create two threads that order simultaneously
    threads = []
    
    threads << Thread.new do
      order = user1.orders.create!
      OrderedList.create!(order: order, item: item, quantity: 5)
      order.update_total_quantity
    end

    threads << Thread.new do
      order = user2.orders.create!
      OrderedList.create!(order: order, item: item, quantity: 5)
      order.update_total_quantity
    end

    # Wait for both threads to complete
    threads.each(&:join)

    # Check final result
    item.reload
    puts "\nFinal item quantity: #{item.total_quantity}"
    puts "Expected: 10"
    
    if item.total_quantity == 10
      puts "✓ SUCCESS: Race condition prevented!"
    else
      puts "✗ FAILED: Race condition occurred (quantity should be 10)"
    end
  end
end
