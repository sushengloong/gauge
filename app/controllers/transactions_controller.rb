class TransactionsController < ApplicationController
  before_filter :authorize

  def index
    @transaction = Transaction.new
    @transactions = current_user.transactions.includes(:category)
    flash.now.notice = "#{params[:sync_num]} transactions imported successfully" if params[:sync_num].present?
  end

  def create
    @transaction = current_user.build_transaction params[:transaction]
    if @transaction.save
      redirect_to(:back, flash: { notice: "Transaction added successfully" }) and return
    else
      @transactions = current_user.transactions.includes(:category)
      flash.now.alert = "Failed to add transaction. #{@transaction.errors.full_messages.join('. ')}"
      render :index
    end
  end

  def edit
    @transaction = current_user.transactions.find params[:id]
    render :layout => false
  end

  def update
    @transaction = current_user.transactions.find params[:id]
    if @transaction.update_attributes(params[:transaction])
      redirect_to transactions_url, flash: { notice: "Transaction updated successfully" }
    else
      redirect_to transactions_url, flash: { error: "Transaction update failed: #{@transaction.errors.full_messages.join('.')}" }
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
      render json: { message: 'UID, PIN and OTP must not be blank' }, status: :bad_request
    else
      Resque.enqueue(SyncPosbJob, current_user.id, uid, pin, otp)
      render json: { message: 'success' }, status: :ok
    end
  rescue Exception => e
    render json: { message: e.message }, status: :internal_server_error
  end

  def query
    posb = JSON.parse Resque.redis.get("users:#{current_user.id}:posb")
    if posb.blank?
      render json: { message: 'Cannot find sync job in backend' }, status: :bad_request
    else
      msg = posb['error'] || 'success'
      status = posb['status']
      num = posb['num'].present? ? posb['num'].to_i : nil
      render json: { message: msg, status: status, num: num }, status: :ok
    end
  rescue Exception => e
    render json: { message: e.message }, status: :internal_server_error
  end
end
