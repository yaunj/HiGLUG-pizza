# Over engineered Ruby version, author: Rune Hammersland
class Pizza
  attr_reader :name, :weight, :price

  def initialize(name, weight, price)
    @name, @weight = name, weight
    @price = if Time.now.wday == 3 and not @name.match(/egenkomponert/i)
      119
    else
      price
    end
  end

  def to_s
    "%-60s (NOK %3d)" % [@name, @price]
  end
end

class Sauce
  def self.price
    20
  end
  def self.name
    "Luguber rømmedressing"
  end
end

class Menu
  def self.add(pizza)
    @@contents ||= []
    @@contents << pizza
  end
  def self.weighted_list
    @@contents.inject([]) do |arr,elem|
      arr << [elem] * elem.weight
      arr.flatten
    end.sort_by { rand }
  end
end

class Order
  class << self
    alias_method :for, :new
  end
  def initialize(n)
    @people = n
    @hunger = 0.4
    @max    = 1200
    @total  = 0
    @items  = []
    @sauce  = 0
    sauce_prob = 0.7

    possible = Menu.weighted_list
    (@people * @hunger).to_i.times do
      pizza = possible[rand(possible.length)]
      break if @total + pizza.price > @max
      @total += pizza.price
      @items << pizza
      if rand < sauce_prob and @total + Sauce.price < @max
        @sauce += 1
        @total += Sauce.price
      end
    end
  end

  def to_s
    orderlines = @items.map {|i| i.to_s}.join("\n")
    sauceline  = "%2d x %-55s (NOK %3d)" % [@sauce, Sauce.name, Sauce.price]
    orderlines + "\n" + sauceline + "\n\n" + "TOTAL: #{@total}"
  end
end

def Pizza(name, weight, price)
  Menu.add(Pizza.new(name, weight, price))
end

Pizza("Pappas spesial", 4, 159)
Pizza("Texas",          3, 149)
Pizza("Blue Hawai",     7, 149)
Pizza("Floriad",        4, 149)
Pizza("Buffalo",        4, 149)
Pizza("Chicken",        4, 149)
Pizza("New York",       0, 149)
Pizza("Las Vegas",      6, 149)
Pizza("Vegetarianer",   0, 149)
Pizza("FILADELFIA",     4, 149)
Pizza("Hot Chicago",    7, 149)
Pizza("Hot Express",    5, 149)
Pizza("Kebab pizza spesial", 3, 169)
Pizza("Egenkomponert Pepperoni Biff Bacon Skinke løk",       9, 159)
Pizza("Egenkomponert Biff Pepperoni Bacon Skinke Tacokjøtt", 9, 159)

peeps = if ARGV.first.nil?
          print "# peeps: "
          Integer(gets)
        else
          Integer(ARGV.shift)
        end

puts Order.for(peeps)
