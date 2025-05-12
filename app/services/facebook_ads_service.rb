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

  # Fetch campaign insights
  def fetch_campaign_insights(campaign_id)
    @options[:query].merge!(
      fields: "impressions,spend,clicks,reach,account_name,campaign_name,date_start,date_stop",
      breakdowns: "gender"
    )
    url = "/#{campaign_id}/insights"

    begin
      response = self.class.get(url, @options)
      data = response["data"] || []

      # Calcul des totaux globaux
      totals = {
        impressions: data.sum { |d| d["impressions"].to_i },
        spend: data.sum { |d| d["spend"].to_f },
        clicks: data.sum { |d| d["clicks"].to_i },
        reach: data.sum { |d| d["reach"].to_i }
      }

      # Organisation des données par genre
      gender_data = data.each_with_object({}) do |item, hash|
        hash[item["gender"]] = {
          impressions: item["impressions"].to_i,
          clicks: item["clicks"].to_i,
          spend: item["spend"].to_f,
          reach: item["reach"].to_i
        }
      end

      {
        totals: totals,
        campaign_name: data.first&.dig("campaign_name"),
        account_name: data.first&.dig("account_name"),
        date_start: data.first&.dig("date_start"),
        date_stop: data.first&.dig("date_stop"),
        gender_breakdown: gender_data
      }
    rescue => e
      Rails.logger.error("Facebook API Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      {}
    end
  end
end
