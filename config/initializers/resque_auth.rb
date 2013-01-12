Resque::Server.use(Rack::Auth::Basic) do |user, password|
  user == "sushengloong@gmail.com" && password == "hello90world"
end
