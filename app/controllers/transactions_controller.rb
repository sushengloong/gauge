class TransactionsController < ApplicationController
  def index
    @transactions = Transaction.all
  end

  def import
    redirect_to(:back, flash: { error: "No file uploaded" }) and return if params[:csv_file].blank?
    num = Transaction.import_csv(params[:csv_file])
    redirect_to(:back, flash: { notice: "#{num} transaction(s) have been imported successfully" }) and return
  end
end
