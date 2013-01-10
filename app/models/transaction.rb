require 'csv'

class Transaction < ActiveRecord::Base
  attr_accessible :amount, :category_id, :note, :repeat, :trans_date

  belongs_to :user
  belongs_to :category
  
  default_scope ->{ order('trans_date desc, amount desc') }

  # repeat
  REPEAT_WEEKLY   = 'W'
  REPEAT_BIWEEKLY = 'B'
  REPEAT_MONTHLY  = 'M'
  REPEAT_NEVER    = 'N'

  @repeat_values = [
    ['Never Repeat', REPEAT_NEVER],
    ['Repeat Weekly', REPEAT_WEEKLY],
    ['Repeat Biweekly', REPEAT_BIWEEKLY],
    ['Repeat Monthly', REPEAT_MONTHLY]
  ]
  def self.repeat_values; @repeat_values end

  validates :amount, presence: true, numericality: true
  validates :category, presence: true
  validates :trans_date, presence: true
  validates :user, presence: true

  def trans_type
    self.category.blank? ? nil : self.category.category_type
  end

  def self.initialize_from_csv_row(row)
    self.new do |t|
      is_income = row[2].blank? && row[3].present?

      # TODO implement some categorization algorithms
      cat = Category.find_or_initialize_by_name is_income ? "Income" : "Expense"
      if cat.new_record?
        cat.category_type = is_income ? Category::TYPE_INCOME : Category::TYPE_EXPENSE
        cat.save!
      end

      t.trans_date = Time.strptime(row[0], '%d %b %Y')
      t.category = cat
      t.amount = ( is_income ? row[3] : row[2] ).to_f
      t.note = row[4..6].select{|r| r.present? }.join('. ').gsub(/\.\./, '.')
      t.repeat = REPEAT_NEVER
    end
  rescue Exception => e
    logger.info "Not a valid transaction row: #{e.message}"
    nil
  end

  def self.parse_csv(file)
    file = File.new(file, 'r') if file.is_a?(String) || file.is_a?(Pathname)
    arr = []
    CSV.foreach(file.path) do |row|
      row.map! { |r| r.nil? ? r : r.chomp.strip.gsub(/\s+/, ' ') }
      trans = self.initialize_from_csv_row(row)
      arr << trans if trans
    end
    arr
  end

  def self.breakdown_chart_data(trans_a)
    trans_a = trans_a.group_by(&:category).sort
    trans_a = trans_a.map do |category, trans|
      sum = trans.map(&:amount).select{|a| a.present?}.inject(&:+)
      "['#{category.name}', #{sum}]"
    end
    "[#{trans_a.join(',')}]".html_safe
  end
end
