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
require "faker"

FactoryBot.define do
  factory :user do
    email_address { Faker::Internet.unique.email }
  end
end
