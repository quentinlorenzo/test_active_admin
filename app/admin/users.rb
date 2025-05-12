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
        column :parent  # Child's parent
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
      render partial: "admin/users/stats_graph"
    end
  end
end
