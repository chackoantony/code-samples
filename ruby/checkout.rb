require 'yaml'

# Checkout class
class Checkout

  def initialize(promo_rules)
    @rules = promo_rules
    @items = []
    @price_list = YAML.load_file('price_list.yml')
  end

  def scan(item)
    @items << item
  end

  def total
    apply_product_rules
    compute_total
  rescue
    puts 'Error applying promotion rules. Check your configuration files'
  end

  def apply_product_rules
    return unless (product_rules = @rules['product_rules'])
    product_rules.each do |rule|
      product = rule['product']
      if @items.count(product) >= rule['count']
        @price_list[product] = rule['discount']
      end
    end
  end

  def compute_total
    actual_total = computed_total = @items.inject(0) { |sum, item| sum + @price_list[item] }
    return computed_total.round(2) unless (total_rules = @rules['total_amount_rules'])
    total_rules.each do |rule|
      if actual_total > rule['value']
        computed_total = actual_total * (100 - rule['discount'].to_f) / 100
      end
    end
    computed_total.round(2)
  end

end
