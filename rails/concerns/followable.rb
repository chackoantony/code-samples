# Concern for user follow fucntionality
module Followable
  extend ActiveSupport::Concern

  included do
    has_many :active_relationships, class_name: 'Follow',
                                    foreign_key: 'follower_id',
                                    dependent: :destroy
    has_many :passive_relationships, class_name:  'Follow',
                                     foreign_key: 'followed_id',
                                     dependent:   :destroy
    has_many :following, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships, source: :follower
  end

  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

end
