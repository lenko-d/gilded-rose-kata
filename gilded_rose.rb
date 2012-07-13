class InventoryItem
  attr_reader :item

  def initialize(item)
    @item = item
  end

  def expired?
    item.sell_in < days(0)
  end

  def days(n)
    n
  end

  def quality_too_bad?
    item.quality < quality_lower_bound
  end

  def quality_too_good?
    item.quality > quality_upper_bound
  end

  def quality_upper_bound
    50
  end

  def quality_lower_bound
    0
  end

  def update
    item.sell_in -= days(1)
    item.quality += quality_shift
    item.quality = quality_lower_bound if quality_too_bad?
    item.quality = quality_upper_bound if quality_too_good?
  end

  def quality_shift
    0
  end

  def self.for(item)
    inventory_item = case item.name
              when 'Aged Brie'                  then AgedBrie
              when /Backstage/                  then Backstage
              when 'NORMAL ITEM'                then Normal
              when /Sulfuras/                   then Sulfuras
              when /Conjured/                   then Conjured
              end
    inventory_item.new(item)
  end

  class AgedBrie < InventoryItem
    def quality_shift
      expired? ? 2 : 1
    end
  end

  class Backstage < InventoryItem
    def quality_shift
      return -quality_upper_bound if expired?
      return 3 if item.sell_in < days(5)
      return 2 if item.sell_in < days(10)
      1
    end
  end

  class Normal < InventoryItem
    def quality_shift
      if expired? then -2 else -1 end
    end
  end

  class Sulfuras < InventoryItem
    def update
    end
  end

  class Conjured < InventoryItem
    def quality_shift
      if expired? then -4 else -2 end
    end
  end
end

def update_quality(items)
  items.each { |item| InventoryItem.for(item).update }
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

