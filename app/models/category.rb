class Category < ActiveRecord::Base
  attr_accessible :category_type, :name

  validates :name, uniqueness: true

  has_many :transactions

  # category_type
  TYPE_INCOME  = 'I'
  TYPE_EXPENSE = 'E'

end
