class HomeController < ApplicationController
  def index
    campaign_id = ENV["FACEBOOK_CAMPAIGN_ID"]

    if campaign_id.blank?
      flash.now[:alert] = "L'ID de campagne Facebook n'est pas configuré."
      @global_data = {}
      @gender_data = {}
      return
    end

    @global_data = FacebookAdsService.new.fetch_global_insights(campaign_id)
    @gender_data = FacebookAdsService.new.fetch_gender_breakdown(campaign_id)
    @age_data = FacebookAdsService.new.fetch_age_breakdown(campaign_id)
    Rails.logger.debug "Global Data: #{@global_data.inspect}"
    Rails.logger.debug "Gender Data: #{@gender_data.inspect}"
    Rails.logger.debug "Age Data: #{@age_data.inspect}"
  end
end
