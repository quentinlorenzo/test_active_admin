class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :parent, class_name: "User", optional: true
  has_many :children, class_name: "User", foreign_key: :parent_id

  has_and_belongs_to_many :groups
end
