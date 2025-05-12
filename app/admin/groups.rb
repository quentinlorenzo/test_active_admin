ActiveAdmin.register Group do
  # Permitted parameters
  permit_params :name, user_ids: []
  config.sort_order = "id_asc"
  menu parent: "Gestion", priority: 2

  config.per_page = [ 10, 50, 100 ]  # Pagination options
  actions :all, except: [ :destroy ]  # Disable deletion

  # Index page
  index do
    selectable_column
    id_column
    column "Nom" do |group|
      link_to group.name, admin_group_path(group)
    end
    column "Nombre Utilisateurs" do |group|
      group.users.count  # Affiche les emails des utilisateurs
    end
    column "Date de création" do |group|
      group.created_at
    end
    column "Date de mise à jour" do |group|
      group.updated_at
    end
    actions
    # render partial: "admin/groups/stats_graph", locals: { chart_type: "bar" }
  end

  # Form configuration
  form do |f|
    f.inputs do
      f.input :name
      f.input :users,  # Sélection multiple des utilisateurs
        as: :check_boxes,
        collection: User.all.map { |u| [ u.email, u.id ] },
        label: "Utilisateurs"
    end
    f.actions
  end

  # Show page
  show do
    attributes_table do
      row :name
    end
    panel "Utilisateurs" do
      table_for group.users do
        column :id do |user|  # Child ID with link
          link_to user.id, admin_user_path(user)
        end
        column :email do |user|  # Child email with link
          link_to user.email, admin_user_path(user)
        end
        column :parent  # Child's parent
        column "Groupes" do |user|
          user.groups.map do |group|
            link_to group.name, admin_group_path(group)  # Lien vers chaque groupe
          end.join(", ").html_safe
        end
        column :created_at  # Child creation date
        column do |user|  # Action links for child
          links = []
          links << link_to("View", admin_user_path(user), class: "member_link")
          links << link_to("Edit", edit_admin_user_path(user), class: "member_link")
          links.join(" ").html_safe
        end
      end
    end
  end
end
