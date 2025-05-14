# ActiveAdmin configuration for User model
ActiveAdmin.register User do
  # Permitted parameters for create/update
  permit_params :email, :password, :password_confirmation, :parent_id, group_ids: []

  menu parent: "Gestion", priority: 1  # Affiche sous le menu "Gestion"
  config.per_page = [ 10, 50, 100 ]  # Pagination options
  actions :all, except: [ :destroy ]  # Disable deletion

  config.sort_order = "id_asc"  # Default sorting

  batch_action :remove_parent do |ids|
    User.where(id: ids).update_all(parent_id: nil)  # Set parent_id to nil for selected users
    redirect_to collection_path, notice: "Parent retiré pour les utilisateurs sélectionnés."
  end

  # Index page configuration
  index do
    selectable_column  # For batch actions
    id_column  # Show ID column
    column :email do |user|  # Email with link to show page
      link_to user.email, admin_user_path(user)
    end
    column :parent  # Parent relationship
    column :created_at  # Creation timestamp
    column "Groupes" do |user|
      user.groups.map do |group|
        link_to group.name, admin_group_path(group)  # Lien vers chaque groupe
      end.join(", ").html_safe
    end
    actions  # Default action links
  end

  # Filter configuration
  filter :email  # Filter by email
  filter :created_at  # Filter by creation date
  filter :parent_id_null, as: :boolean, label: "Sans parent"  # Filter users without parent
  filter :parent,  # Filter by specific parent
         as: :select,
         collection: -> { User.pluck(:email, :id) },
         label: "Parent spécifique"

  # Form configuration
  form do |f|
    f.inputs do
      f.input :email  # Email field
      # f.input :password  # Password field
      # f.input :password_confirmation  # Password confirmation
      f.input :parent,  # Parent selection dropdown
        as: :select,
        collection: [ [ "Aucun parent", nil ] ] + User.where.not(id: f.object.id).pluck(:email, :id),
        prompt: "Choisir un parent",
        include_blank: false

      # Remplacement par des checkboxes pour les groupes
      f.input :groups,
        as: :check_boxes,  # Utilise des checkboxes
        collection: Group.all.map { |g| [ g.name, g.id ] },  # Liste des groupes
        label: "Groupes"
    end
    f.actions  # Form submit buttons
  end

  # Show page configuration
  show do
    attributes_table do  # Basic user info
      row :email
      row :parent
      row :created_at
      row "Groupes" do |user|
        user.groups.map do |group|
          link_to group.name, admin_group_path(group)  # Lien vers chaque groupe
        end.join(", ").html_safe
      end
    end

    # Children section
    panel "Enfants" do
      table_for user.children do
        column :id do |child|  # Child ID with link
          link_to child.id, admin_user_path(child)
        end
        column :email do |child|  # Child email with link
          link_to child.email, admin_user_path(child)
        end
        column :created_at  # Child creation date
        column do |child|  # Action links for child
          links = []
          links << link_to("View", admin_user_path(child), class: "member_link")
          links << link_to("Edit", edit_admin_user_path(child), class: "member_link")
          links.join(" ").html_safe
        end
      end
    end

    panel "Statistiques" do
      campaign_id = ENV["FACEBOOK_CAMPAIGN_ID"]

      @global_data = FacebookAdsService.new.fetch_global_insights(campaign_id)
      @gender_data = FacebookAdsService.new.fetch_gender_breakdown(campaign_id)
      @age_data = FacebookAdsService.new.fetch_age_breakdown(campaign_id)
      @location_data = FacebookAdsService.new.fetch_location_breakdown(campaign_id)
      @device_data = FacebookAdsService.new.fetch_device_breakdown(campaign_id)
      @status_data = FacebookAdsService.new.fetch_status_insights(campaign_id)
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
      @time_stats = FacebookAdsService.new.fetch_complete_insights(campaign_id, start_date, end_date)

      # Pour la rétrocompatibilité avec le code existant
      @daily_stats = { daily_breakdown: @time_stats[:daily_breakdown] }
      @hourly_stats = { hourly_breakdown: @time_stats[:hourly_breakdown] }

      render partial: "shared/facebook_stats",
             locals: {
               global_data: @global_data,
               gender_data: @gender_data,
               age_data: @age_data,
               location_data: @location_data,
               device_data: @device_data,
               status_data: @status_data,
               time_stats: @time_stats,
               daily_stats: @daily_stats,
               hourly_stats: @hourly_stats
             }
    end
  end
end
