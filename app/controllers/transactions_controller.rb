class TransactionsController < ApplicationController
  before_filter :authorize

  def index
    @transaction = Transaction.new
    @transactions = current_user.transactions.includes(:category)
  end

  def create
    @transaction = Transaction.new params[:transaction]
    @transaction.user = current_user
    if @transaction.save
      redirect_to(:back, flash: { notice: "Transaction added successfully" }) and return
    else
      @transactions = current_user.transactions.includes(:category)
      flash.now.alert = "Failed to add transaction. #{@transaction.errors.full_messages.join('. ')}"
      render :index
    end
  end

  def import
    redirect_to(:back, flash: { error: "No file uploaded" }) and return if params[:csv_file].blank?
    transactions = current_user.import_csv(params[:csv_file])
    num = transactions.length
    redirect_to(:back, flash: { notice: "#{num} transaction(s) have been imported successfully" }) and return
  rescue => e
    redirect_to(:back, flash: { error: "CSV import failed: #{e}" }) and return
  end
end
