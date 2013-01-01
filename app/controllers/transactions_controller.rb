class TransactionsController < ApplicationController
  def index
    @transaction = Transaction.new
    @transactions = Transaction.all
  end

  def create
    @transaction = Transaction.new params[:transaction]
    if @transaction.save
      redirect_to(:back, flash: { notice: "Transaction added successfully" }) and return
    else
      @transactions = Transaction.all
      flash[:error] = "Failed to add transaction. #{@transaction.errors.full_messages.join('. ')}"
      render :index
    end
  end

  def import
    redirect_to(:back, flash: { error: "No file uploaded" }) and return if params[:csv_file].blank?
    num = Transaction.import_csv(params[:csv_file])
    redirect_to(:back, flash: { notice: "#{num} transaction(s) have been imported successfully" }) and return
  end
end
