class Goal < ActiveRecord::Base
  attr_accessible :amount, :due_date, :name

  validates :amount, numericality: true
  validates_date :due_date, format: 'dd-mm-yyyy'
  validates :name, length: 3..120

end
