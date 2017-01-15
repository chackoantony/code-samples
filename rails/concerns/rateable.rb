# This module is intended to add rating functionality to an ActiveRecord model
module Rateable
  extend ActiveSupport::Concern
  
  included do
    has_many :ratings, as: :rateable, dependent: :destroy
  end

  class_methods do
    
    # Method to get all rateable type which is rated by a particular rater
    def rated_by(user)
      joins(:ratings).where('ratings.user_id = ?', user.id)
    end

    # Method to get the highest rated rateable type
    def highest_rated
      joins(:ratings).group('rateable_id').order('avg(ratings.value) desc').first
    end

    # Method to get the lowest rated rateable type
    def lowest_rated
      joins(:ratings).group('rateable_id').order('avg(ratings.value)').first
    end
  end
  
  # Method to add or update rating for a rateable type by a rater (User in this case)
  def add_rating(value, user)
    current_rating = Rating.find_by(rateable: self, user: user)
    if current_rating
      current_rating.update(value: value)
    else
      ratings.create(value: value, user: user)
    end
  end

  # Method to get the average_rating for a rateable type
  def average_rating
    ratings.average(:value).to_f
  end

  # Method to get the current rating for a rateable type by a rater
  def current_rating(user)
    rating = ratings.find_by(user_id: user.id)
    rating ? rating.value : 0
  end

  # Method to check wheather a rateable type is already reated by a particular rater
  def rated_by?(user)
    ratings.where(user_id: user.id).exist?
  end
   
  # Method to get the rating count by rate value or as whole
  def rating_count(value = nil)
    value ? ratings.where(value: value).size : ratings.size
  end

  # Method to get the users those who have rated a particular rateable type
  def rated_users
    User.where(user_id: ratings.pluck(:user_id))
  end
end
