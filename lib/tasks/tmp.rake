namespace :tmp do
  task filter_usda_foods: :environment do
    foods = UsdaFood.selected
    number_of_foods = foods.count
    puts "Number of foods: #{number_of_foods}"
    puts
    puts "Random foods:"
    foods.order('random()').limit(50).each do |food|
      puts " - #{food.long_description} (#{food.id})"
    end
  end
end
