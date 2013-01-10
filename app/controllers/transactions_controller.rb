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
  rescue Exception => e
    redirect_to(:back, flash: { error: "CSV import failed: #{e}" }) and return
  end

  def sync
    uid = params[:uid]
    pin = params[:pin]
    otp = params[:otp]
    if [uid, pin, otp].any?(&:blank?)
      redirect_to(:back, flash: { error: "UID, PIN and OTP must not be blank" }) and return
    else
      script_path = Rails.root.join 'lib', 'sync_posb.coffee'
      filepath = Rails.root.join 'tmp', 'sync_posb', "#{uid}_#{Time.now.strftime('%Y%m%d_%H%I%S')}.csv"
      FileUtils.mkdir_p File.basename(filepath)
      `casperjs #{script_path} #{uid} #{pin} #{otp} #{filepath}`
      sleep 20
      transactions = current_user.import_csv(filepath)
      num = transactions.length
      redirect_to(:back, flash: { notice: "#{num} transaction(s) have been imported successfully" }) and return
    end
  rescue Exception => e
    redirect_to(:back, flash: { error: "Failed to sync: #{e}\n#{e.backtrace[0]}" }) and return
  end
end
