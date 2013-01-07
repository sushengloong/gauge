class User < ActiveRecord::Base
  has_secure_password

  has_many :transactions

  attr_accessible :email, :password, :password_confirmation

  validates :email, uniqueness: true

  def import_csv(csv_file)
    transactions = Transaction.parse_csv(csv_file)
    transactions.each do |t|
      t.user = self
    end
    transactions.each(&:save!)
    transactions
  end
end
