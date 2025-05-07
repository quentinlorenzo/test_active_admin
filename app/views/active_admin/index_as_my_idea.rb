# module ActiveAdmin
#   module Views
#     class IndexAsMyIdea < ActiveAdmin::Component
#       def build(page_presenter, collection)
#         puts "Nombre d'utilisateurs : #{collection.count}"  # Vérifie en console
#         collection.each do |user|
#           div do
#             h2 user.email  # Affiche le titre de l'image
#             # Ajoute d'autres éléments si nécessaire
#           end
#         end
#       end

#       def self.index_name
#         "my_idea"
#       end
#     end
#   end
# end
