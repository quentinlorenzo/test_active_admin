ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :parent_id
  menu priority: 1
  config.per_page = [ 10, 50, 100 ]
  actions :all, except: [ :destroy ]

  config.sort_order = "id_asc"

  index do
    selectable_column
    id_column
    column :email do |user|
      link_to user.email, admin_user_path(user)
    end
    column :parent
    column :created_at
    actions
  end

  filter :email
  filter :created_at
  filter :parent_id_null, as: :boolean, label: "Sans parent"
  filter :parent,
         as: :select,
         collection: -> { User.pluck(:email, :id) },
         label: "Parent spécifique"

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :parent,
        as: :select,
        collection: [ [ "Aucun parent", nil ] ] + User.where.not(id: f.object.id).pluck(:email, :id),
        prompt: "Choisir un parent",
        include_blank: false
    end
    f.actions
  end

  show do
    attributes_table do
      row :email
      row :parent
      row :created_at
    end
    panel "Enfants" do
      table_for user.children do
        column :id do |child|
          link_to child.id, admin_user_path(child)
        end
        column :email do |child|
          link_to child.email, admin_user_path(child)
        end
        column :parent
        column :created_at
        column do |child|
          links = []
          links << link_to("View", admin_user_path(child), class: "member_link")
          links << link_to("Edit", edit_admin_user_path(child), class: "member_link")
          links.join(" ").html_safe
        end
      end
    end
  end
end
