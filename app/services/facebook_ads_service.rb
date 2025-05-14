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
      fields: "impressions,spend,clicks,ctr,reach,actions,account_name,campaign_name"
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
        ctr: data["ctr"].to_f,
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

  # Fetch status insights
  def fetch_status_insights(campaign_id)
    @options[:query].merge!(
      fields: "status,start_time,stop_time"
    )
    url = "/#{campaign_id}"

    begin
      response = self.class.get(url, @options)
      stop_time = response["stop_time"]

      # Détermine si la campagne est terminée
      is_ended = if stop_time
                   Time.now > Time.parse(stop_time)
      else
                   false
      end

      {
        status: response["status"],
        start_time: response["start_time"],
        stop_time: stop_time,
        is_ended: is_ended
      }
    rescue => e
      Rails.logger.error("Facebook API Error: #{e.message}")
      {
        status: nil,
        start_time: nil,
        stop_time: nil,
        is_ended: nil
      }
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

  # Fetch daily insights for the entire campaign
  def fetch_daily_insights(campaign_id, start_time = nil, end_time = nil)
    # Si start_time et end_time ne sont pas fournis, utilisez date_preset
    if start_time.nil? || end_time.nil?
      @options[:query].merge!(
        fields: "impressions,clicks,reach,spend,ctr",
        time_increment: 1, # Données quotidiennes
        date_preset: "lifetime" # Récupère les données sur toute la durée de la campagne
      )
    else
      @options[:query].merge!(
        fields: "impressions,clicks,reach,spend,ctr",
        time_increment: 1, # Données quotidiennes
        time_range: { since: start_time, until: end_time }.to_json
      )
    end

    url = "/#{campaign_id}/insights"

    begin
      puts "Requête API daily: #{@options[:query]}"
      response = self.class.get(url, @options)

      # Pour débogage
      if response["data"].nil? || response["data"].empty?
        puts "Aucune donnée reçue. Réponse: #{response.body}"
      else
        puts "Nombre d'éléments reçus: #{response["data"].size}"
      end

      data = response["data"] || []

      # Organiser les données par jour
      daily_data = data.each_with_object({}) do |item, hash|
        date = item["date_start"]
        hash[date] = {
          impressions: item["impressions"].to_i,
          clicks: item["clicks"].to_i,
          reach: item["reach"].to_i,
          spend: item["spend"].to_f,
          ctr: item["ctr"].to_f
        }
      end

      { daily_breakdown: daily_data }
    rescue => e
      Rails.logger.error("Facebook API Error: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      {}
    end
  end

  # Fetch complete insights with daily and hourly data
  def fetch_complete_insights(campaign_id, start_time = nil, end_time = nil)
    # Récupérer d'abord les données quotidiennes
    daily_data = fetch_daily_insights(campaign_id, start_time, end_time)

    # Structure pour stocker les résultats complets
    complete_data = {
      daily_breakdown: daily_data[:daily_breakdown] || {},
      hourly_breakdown: {}
    }

    # Si aucune donnée quotidienne, retourner le résultat vide
    if daily_data[:daily_breakdown].empty?
      Rails.logger.warn("Aucune donnée quotidienne trouvée pour la campagne #{campaign_id}")
      return complete_data
    end

    # Pour chaque jour, récupérer les données horaires
    daily_data[:daily_breakdown].each do |date, _|
      Rails.logger.info("Récupération des données horaires pour #{date}")

      # Utiliser le jour comme début et fin pour obtenir les données de ce jour uniquement
      hourly_result = fetch_single_day_hourly_insights(campaign_id, date)

      # Ajouter les données horaires à la structure complète
      if hourly_result[:hourly_breakdown].any?
        complete_data[:hourly_breakdown][date] = hourly_result[:hourly_breakdown]
      end

      # Petite pause pour éviter de submerger l'API
      sleep(0.5)
    end

    complete_data
  end

  # Fetch hourly insights for a single day
  def fetch_single_day_hourly_insights(campaign_id, date)
    @options[:query].merge!(
      fields: "impressions,clicks,reach",
      breakdowns: "hourly_stats_aggregated_by_audience_time_zone",
      time_range: { since: date, until: date }.to_json,
      time_increment: "1", # Important pour avoir les données heure par heure
      level: "campaign" # S'assurer qu'on est au niveau de la campagne
    )

    url = "/#{campaign_id}/insights"

    begin
      Rails.logger.info("Requête API horaire pour #{date}: #{@options[:query]}")
      response = self.class.get(url, @options)
      data = response["data"] || []

      Rails.logger.info("Nombre de données horaires reçues pour #{date}: #{data.size}")

      # Organiser les données par heure pour ce jour
      hourly_data = {}

      data.each do |item|
        hour = item["hourly_stats_aggregated_by_audience_time_zone"]
        next unless hour # Ignorer les entrées sans heure

        # Formater l'heure sur 2 chiffres (ex: "01" au lieu de "1")
        formatted_hour = hour.to_i.to_s.rjust(2, "0")

        hourly_data[formatted_hour] = {
          impressions: item["impressions"].to_i,
          clicks: item["clicks"].to_i,
          reach: item["reach"].to_i
        }
      end

      { hourly_breakdown: hourly_data }
    rescue => e
      Rails.logger.error("Facebook API Error pour #{date}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      { hourly_breakdown: {} }
    end
  end
end
