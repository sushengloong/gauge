class User < ActiveRecord::Base
  has_secure_password

  has_many :transactions

  attr_accessible :email, :password, :password_confirmation

  validates :email, uniqueness: true

  before_create { generate_token(:auth_token) }

  def import_csv(csv_file)
    transactions = Transaction.parse_csv(csv_file)
    transactions.each do |t|
      t.user = self
    end
    transactions.each(&:save!)
    transactions
  end

  def past_transaction_trends(num = 6)
    today = Date.today
    start_date = today.beginning_of_month - num.months
    transactions = self.transactions.includes(:category).where(:trans_date => start_date.beginning_of_day..today.end_of_day)
    transactions = Hash[transactions.group_by{ |t| t.trans_date.beginning_of_month }.sort]
    data = { months: [], income:[], expenses:[], net_income:[] }
    transactions.each do |month, trans|
      income = trans.select{ |t| t.category.category_type == Category::TYPE_INCOME }.inject(0){ |sum, t| sum + t.amount }
      expenses = trans.select{ |t| t.category.category_type == Category::TYPE_EXPENSE }.inject(0){ |sum, t| sum - t.amount }
      data[:months] << month.strftime("%b")
      data[:income] << income
      data[:expenses] << expenses
      data[:net_income] << (income + expenses) # expenses value is negative
    end
    data
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
end
