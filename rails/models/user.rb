class User < ApplicationRecord
  include Followable

  enum level: [:starter, :mid_level, :senior, :ameture]
  
  has_many :activities, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :photo_uploads, dependent: :destroy
  has_many :photos, through: :photo_uploads
  before_create :generate_authentication_token!, :generate_handle

  validates :auth_token, :email, uniqueness: true
   
  def self.facebook_oauth
    @facebook_oauth ||= Koala::Facebook::OAuth.new(ENV['FACEBOOK_APP_ID'], ENV['FACEBOOK_APP_SECRET'])
  end

  protected

  def generate_authentication_token!
    loop do
      self.auth_token = Devise.friendly_token
      break unless self.class.where(auth_token: auth_token).exists?
    end
  end

  def generate_handle
    return unless email.present?
    self.handle = email.split('@').first
  end

end
