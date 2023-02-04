namespace :setup do
  desc "GeoIPのデータベースをダウンロードして、/vendor/GeoLiteCity.datに配置する"
  task :geoip do
    filepath = Application.root.join('vendor', 'GeoLiteCity.dat').to_s
#download_url = "http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz"
    download_url = "https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz"
    File.unlink(filepath) if File.exist?(filepath)
    open("#{filepath}.gz", 'wb') do |writefile|
      open(download_url, 'rb') do |readfile|
        writefile.write(readfile.read)
      end
    end
    `gunzip #{filepath}.gz`
  end
end
