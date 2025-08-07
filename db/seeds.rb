puts "Seeding categories..."

# The list of style tags from the original React component
style_categories = [
  "Industrial rave", "Heavy bass", "Orchestral", "Electronic beats",
  "Funky guitar", "Soulful vocals", "Ambient pads"
]

style_categories.each do |category_name|
  # `find_or_create_by!` is idempotent, so you can run this script multiple times
  # without creating duplicate categories.
  Category.find_or_create_by!(name: category_name)
end

puts "Finished seeding #{Category.count} categories."