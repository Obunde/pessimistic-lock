class Order < ApplicationRecord
  belongs_to :user
  has_many :ordered_lists
  has_many :items, through: :ordered_lists
  accepts_nested_attributes_for :ordered_lists

  def update_total_quantity
    self.ordered_lists.each do |line_item|
      Item.transaction do
        item = Item.lock.find(line_item.item_id)
        item.increment!(:total_quantity, line_item.quantity)
      end
    end
  end
end
