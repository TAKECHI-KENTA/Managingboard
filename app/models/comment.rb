class Comment < ApplicationRecord
  #validates :user_id, presende: true   ログイン完成後
  validates :tention_id, presence: true
  
  belongs_to :user
  belongs_to :tention
end
