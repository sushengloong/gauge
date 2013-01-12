class SyncPosbJob
  @queue = :sync_posb_queue

  STARTED = 'Started'
  DONE    = 'Done'
  ERROR   = 'Error'

  def self.start_status user_id
    res = { status: STARTED, num: nil, error: nil }
    Resque.redis.set "users:#{user_id}:posb", res.to_json
  end

  def self.end_status user_id, insert_count
    res = { status: DONE, num: insert_count, error: nil }
    Resque.redis.set "users:#{user_id}:posb", res.to_json
  end

  def self.error_status user_id, e
    res = { status: ERROR, num: nil, error: e.message }
    Resque.redis.set "users:#{user_id}:posb", res.to_json
  end

  def self.perform(user_id, uid, pin, otp)
    self.start_status user_id

    script_path = Rails.root.join 'lib', 'sync_posb.coffee'
    filepath = Rails.root.join 'tmp', 'sync_posb', "#{uid}_#{Time.now.strftime('%Y%m%d_%H%I%S')}.csv"
    FileUtils.mkdir_p File.basename(filepath)
    `casperjs #{script_path} #{uid} #{pin} #{otp} #{filepath}`
    sleep 30
    transactions = User.find(user_id).import_csv(filepath)

    self.end_status user_id, transactions.length
  rescue Exception => e
    self.error_status user_id, e
  end
end
