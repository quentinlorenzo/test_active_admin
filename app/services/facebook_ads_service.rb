class FacebookAdsService
  include HTTParty
  base_uri "https://graph.facebook.com/v19.0"  # Using latest stable version

  def initialize
    token = ENV["FACEBOOK_ACCESS_TOKEN"]

    @options = {
      query: {
        access_token: token
      }
    }
  end

  # Fetch global campaign insights
  def fetch_global_insights(campaign_id)
    @options[:query].merge!(
      fields: "impressions,spend,clicks,reach,actions,account_name,campaign_name,date_start,date_stop"
    )
    url = "/#{campaign_id}/insights"

    begin
      response = self.class.get(url, @options)
      data = response["data"]&.first || {}

      # Extraction des actions spécifiques
      actions = data["actions"] || []
      likes = actions.find { |a| a["action_type"] == "like" }&.dig("value").to_i
      comments = actions.find { |a| a["action_type"] == "comment" }&.dig("value").to_i
      reposts = actions.find { |a| a["action_type"] == "post" }&.dig("value").to_i
      video_views = actions.find { |a| a["action_type"] == "video_view" }&.dig("value").to_i

      {
        impressions: data["impressions"].to_i,
        spend: data["spend"].to_f,
        clicks: data["clicks"].to_i,
        reach: data["reach"].to_i,
        likes: likes,
        comments: comments,
        reposts: reposts,
        video_views: video_views,
        campaign_name: data["campaign_name"],
        account_name: data["account_name"],
        date_start: data["date_start"],
        date_stop: data["date_stop"]
      }
    rescue => e
      Rails.logger.error("Facebook API Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      {}
    end
  end

  # Fetch gender breakdown insights
  def fetch_gender_breakdown(campaign_id)
    @options[:query].merge!(
      fields: "impressions,clicks,reach",
      breakdowns: "gender"
    )
    url = "/#{campaign_id}/insights"

    begin
      response = self.class.get(url, @options)
      data = response["data"] || []

      gender_data = data.each_with_object({}) do |item, hash|
        hash[item["gender"]] = {
          impressions: item["impressions"].to_i,
          clicks: item["clicks"].to_i,
          reach: item["reach"].to_i
        }
      end

      { gender_breakdown: gender_data }
    rescue => e
      Rails.logger.error("Facebook API Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      {}
    end
  end

  # Fetch age breakdown insights
  def fetch_age_breakdown(campaign_id)
    @options[:query].merge!(
      fields: "impressions,clicks,reach",
      breakdowns: "age"
    )
    url = "/#{campaign_id}/insights"

    begin
      response = self.class.get(url, @options)
      data = response["data"] || []

      age_data = data.each_with_object({}) do |item, hash|
        hash[item["age"]] = {
          impressions: item["impressions"].to_i,
          clicks: item["clicks"].to_i,
          reach: item["reach"].to_i
        }
      end

      { age_breakdown: age_data }
    rescue => e
      Rails.logger.error("Facebook API Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      {}
    end
  end

  # Fetch location breakdown insights
  def fetch_location_breakdown(campaign_id)
    @options[:query].merge!(
      fields: "impressions,clicks,reach",
      breakdowns: "region"
    )
    url = "/#{campaign_id}/insights"

    begin
      response = self.class.get(url, @options)
      data = response["data"] || []

      location_data = data.each_with_object({}) do |item, hash|
        hash[item["region"]] = {
          impressions: item["impressions"].to_i,
          clicks: item["clicks"].to_i,
          reach: item["reach"].to_i
        }
      end

      { location_breakdown: location_data }
    rescue => e
      Rails.logger.error("Facebook API Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      {}
    end
  end

  # Fetch device breakdown insights
  def fetch_device_breakdown(campaign_id)
    @options[:query].merge!(
      fields: "impressions,clicks,reach",
      breakdowns: "device_platform"
    )
    url = "/#{campaign_id}/insights"

    begin
      response = self.class.get(url, @options)
      data = response["data"] || []

      device_data = data.each_with_object({}) do |item, hash|
        hash[item["device_platform"]] = {
          impressions: item["impressions"].to_i,
          clicks: item["clicks"].to_i,
          reach: item["reach"].to_i
        }
      end

      { device_breakdown: device_data }
    rescue => e
      Rails.logger.error("Facebook API Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      {}
    end
  end
end
