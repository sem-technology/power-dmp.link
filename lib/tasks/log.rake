namespace :log do
  desc "ログの前処理を実行する"
  task :preprocessing, :date do |task, arg|
    log_filepath = Application.root.join("log", "production", "audience-#{arg[:date]}.log.json")
    processed_log_filepath = Application.root.join("log", "production", "processed-audience-#{arg[:date]}.log.csv")
    File.open(log_filepath, 'r') do |log_file|
      CSV.open(processed_log_filepath, "a") do |csv|
        csv << AudienceLog::Data.to_array_header
        log_file.each_line do |line|
          log = AudienceLog::Data.new(line)
          csv << log.to_array
        end
      end
    end
  end

  desc "ログデータをダウンロードする"
  task :download, :date do |task, arg|
    log_filepath = Application.root.join("log", "production", "audience-#{arg[:date]}.log.json")
    command = "scp ryota.yamada@app01.sakura:/var/www/power-dmp.link/shared/log/backup/audience-#{arg[:date]}.log.json.tar.gz #{log_filepath}.tar.gz"
    `#{command}`
    `tar xzf #{log_filepath}.tar.gz`
    `mv audience-#{arg[:date]}.log.json #{log_filepath}`
  end
end
