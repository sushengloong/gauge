# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

cat_seeds = [
  { name: 'Bonus', category_type: Category::TYPE_INCOME },
  { name: 'Interest', category_type: Category::TYPE_INCOME },
  { name: 'Dividend', category_type: Category::TYPE_INCOME },
  { name: 'Salary', category_type: Category::TYPE_INCOME },

  { name: 'Car', category_type: Category::TYPE_EXPENSE },
  { name: 'Clothing, Shoes & Accessories', category_type: Category::TYPE_EXPENSE },
  { name: 'Food & Beverage', category_type: Category::TYPE_EXPENSE },
  { name: 'Education', category_type: Category::TYPE_EXPENSE },
  { name: 'Entertainment', category_type: Category::TYPE_EXPENSE },
  { name: 'Transportation', category_type: Category::TYPE_EXPENSE },
  { name: 'Vacation', category_type: Category::TYPE_EXPENSE },
]

cat_seeds.each do |cat|
  Category.create!(cat)
end
