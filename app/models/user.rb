class User < ApplicationRecord
  mail_REGEX =/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: mail_REGEX
                    }
  
  has_secure_password
end
