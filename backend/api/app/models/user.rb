# == Schema Information
#
# Table name: users
#
#  id            :integer          not null, primary key
#  email_address :string           not null
#  token         :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_users_on_email_address  (email_address) UNIQUE
#  index_users_on_token          (token) UNIQUE
#
require 'securerandom'

class User < ApplicationRecord
  before_create :generate_token

private

  def generate_token
    self.token = SecureRandom.hex(16)
  end
end
