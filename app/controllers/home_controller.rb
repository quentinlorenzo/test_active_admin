class HomeController < ApplicationController
  def index
    campaign_id = ENV["FACEBOOK_CAMPAIGN_ID"]

    if campaign_id.blank?
      flash.now[:alert] = "L'ID de campagne Facebook n'est pas configuré."
      @campaign_data = {}
      return
    end

    @campaign_data = FacebookAdsService.new.fetch_campaign_insights(campaign_id)

    if @campaign_data.blank?
      flash.now[:alert] = "Impossible de récupérer les données de la campagne Facebook."
    end
  end
end
