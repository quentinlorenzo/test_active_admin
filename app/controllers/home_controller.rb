class HomeController < ApplicationController
  def index
    campaign_id = ENV["FACEBOOK_CAMPAIGN_ID"]

    if campaign_id.blank?
      flash.now[:alert] = "L'ID de campagne Facebook n'est pas configuré."
      @global_data = {}
      @gender_data = {}
      @age_data = {}
      @location_data = {}
      @device_data = {}
      @status_data = {}
      return
    end

    # Créer une seule instance du service
    facebook_service = FacebookAdsService.new

    # Récupérer les données de base
    @global_data = facebook_service.fetch_global_insights(campaign_id)
    @gender_data = facebook_service.fetch_gender_breakdown(campaign_id)
    @age_data = facebook_service.fetch_age_breakdown(campaign_id)
    @location_data = facebook_service.fetch_location_breakdown(campaign_id)
    @device_data = facebook_service.fetch_device_breakdown(campaign_id)
    @status_data = facebook_service.fetch_status_insights(campaign_id)

    # Préparer les dates pour la récupération des données temporelles
    start_date = nil
    end_date = nil

    begin
      if @status_data[:start_time].present?
        start_date = Date.parse(@status_data[:start_time]).strftime("%Y-%m-%d")
      end

      if @status_data[:stop_time].present?
        end_date = Date.parse(@status_data[:stop_time]).strftime("%Y-%m-%d")
      else
        end_date = Date.today.strftime("%Y-%m-%d")
      end
    rescue => e
      Rails.logger.error("Erreur lors du parsing des dates: #{e.message}")
    end

    # Récupérer toutes les données (quotidiennes et horaires) en une seule fois
    @time_stats = facebook_service.fetch_complete_insights(campaign_id, start_date, end_date)

    # Pour la rétrocompatibilité avec le code existant
    @daily_stats = { daily_breakdown: @time_stats[:daily_breakdown] }
    @hourly_stats = { hourly_breakdown: @time_stats[:hourly_breakdown] }

    # Logging pour débogage
    Rails.logger.debug "Global Data: #{@global_data.inspect}"
    Rails.logger.debug "Gender Data: #{@gender_data.inspect}"
    Rails.logger.debug "Age Data: #{@age_data.inspect}"
    Rails.logger.debug "Location Data: #{@location_data.inspect}"
    Rails.logger.debug "Device Data: #{@device_data.inspect}"
    Rails.logger.debug "Status Data: #{@status_data.inspect}"
    Rails.logger.debug "Time Stats: #{@time_stats.inspect}"
  end
end
