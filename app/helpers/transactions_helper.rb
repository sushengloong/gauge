module TransactionsHelper
  def display_amount(trans)
    return "" unless trans.is_a? Transaction
    color = 'red'
    sign = '-'
    if trans.trans_type == Category::TYPE_INCOME
      color = 'green'
      sign = '+'
    end
    "<span style='color:#{color};font-weight:bold'>#{sign}#{number_to_currency(trans.amount)}</span>".html_safe
  end
end
