module AudienceLog
  class Data
    @@GEO_IP_CACHE= {}
    REFERRER_DOMAIN_CONVERT_LIST = {
      "t.co" => "twitter.com",
      "search.yahoo.co.jp" => "yahoo",
    }
    CONVERT_TO_MEDIUM_FROM_SOURCE = {
      "tpc.googlesyndication.com" => "display",
      "googleads.g.doubleclick.net" => "display",
      "dp.g.doubleclick.net" => "display",
      "ad.doubleclick.net" => "display",
      "www.googleadservices.com" => "display",
      "google" => "organic",
      "yahoo" => "organic",
      "search.azby.fmworld.net" => "organic",
      "search.daum.net" => "organic",
      "search.dolphin-browser.jp" => "organic",
      "search.goo.ne.jp" => "organic",
      "search.jword.jp" => "organic",
      "search.myjcom.jp" => "organic",
      "search.naver.com" => "organic",
      "search.nifty.com" => "organic",
      "search.smt.docomo.ne.jp" => "organic",
      "search.yahoo.co.jp" => "organic",
      "search.zum.com" => "organic",
      "cgi.search.biglobe.ne.jp" => "organic",
      "hk.search.yahoo.com" => "organic",
      "int.search.tb.ask.com" => "organic",
      "jp.hao123.com" => "organic",
      "m.search.naver.com" => "organic",
      "nortonsafe.search.ask.com" => "organic",
      "r.search.yahoo.com" => "organic",
      "sp-web.search.auone.jp" => "organic",
      "websearch.rakuten.co.jp" => "organic",
      "www.mysearch.com" => "organic",
      "m.facebook.com" => "social",
      "l.facebook.com" => "social",
      "lm.facebook.com" => "social",
    }
    def initialize(row)
      @row = JSON.parse(row)
    end

    def domain
      self.url.split('/')[2]
    end

    def referer_domain
      self.referer.split('/')[2] or ""
    end

    def source
      if self.url.include?('utm_source')
        self.url_query["utm_source"]
      elsif self.referer_domain == self.domain or self.referer == 'direct'
        'direct'
      elsif self.referer_domain.include?('www.google.')
        'google'
      elsif self.referer_domain =~ /(l|m|lm|www).facebook.com/
        'facebook'
      else
        self.referer_domain
      end
    end

    def medium
      if self.source == 'direct'
        'none'
      elsif self.url.include?('utm_medium')
        self.url_query["utm_medium"]
      elsif self.url.include?('gclid')
        if self.referer_domain.include?('www.google.')
          "cpc"
        else
          "display"
        end
      elsif self.referer_domain.include?('www.google.')
        "organic"
      elsif CONVERT_TO_MEDIUM_FROM_SOURCE.include?(self.source)
        CONVERT_TO_MEDIUM_FROM_SOURCE[self.source]
      else
        'referer'
      end
    end

    def url_query
      Hash[URI::decode_www_form(Addressable::URI.parse(self.url).query)]
    end

    def to_array
      AudienceLog::Data.to_array_header.collect do |header|
        val = self.send(header)
        if val.nil?
          nil
        else
          val.to_s.gsub("\t", "")
        end
      end
    end

    def geo_ip
      begin
        return @@GEO_IP_CACHE[self.remote_addr] if @@GEO_IP_CACHE.include?(self.remote_addr)
        @geo_ip = GeoIP.new('./vendor/GeoLiteCity.dat').city(self.remote_addr)
      rescue
        @geo_ip = OpenStruct.new({:country_name => "unknown", :real_region_name => "unknown", :city_name => "unknown" })
      end
      @@GEO_IP_CACHE[self.remote_addr] = @geo_ip
      return @geo_ip
    end

    def country; self.geo_ip.country_name; end
    def region; self.geo_ip.real_region_name; end
    def city; self.geo_ip.city_name; end

    def browser; UserAgent.parse(self.user_agent).browser; end
    def browser_version; UserAgent.parse(self.user_agent).version; end
    def platform; UserAgent.parse(self.user_agent).platform; end
    def device_category
      "mobile" if UserAgent.parse(self.user_agent).mobile? 
      "desktop" unless UserAgent.parse(self.user_agent).mobile? 
    end

    def self.to_array_header
      [
        :audience_id,
        :timestamp,
        :url,
        :domain,
        :referer_domain,
        :referer,
        :source,
        :medium,
        :display_size,
        :window_size,
        :language,
        :remote_addr,
        :title,
        :user_agent,
        :browser,
        :browser_version,
        :platform,
        :device_category,
        :country,
        :region,
        :city,
      ]
    end

    def audience_id; @row["AudienceId"]; end
    def display_size; @row["DisplaySize"]; end
    def window_size; @row["WindowSize"]; end
    def language; @row["Lang"]; end
    def referer; @row["Referer"]; end
    def remote_addr; @row["RemoteAddr"]; end
    def timestamp; @row["Timestamp"]; end
    def title; @row["Title"]; end
    def url; @row["Url"]; end
    def user_agent; @row["UserAgent"]; end
  end
end

