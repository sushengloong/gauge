class Goal < ActiveRecord::Base
  attr_accessible :amount, :due_date, :name

  validates :amount, presence: true, numericality: true
  validates :due_date, presence: true
  validates :name, presence: true
end
