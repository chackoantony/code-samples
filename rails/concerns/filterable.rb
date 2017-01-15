# Concern to filter model based on user params
module Filterable
  extend ActiveSupport::Concern

  included do
    scope :filter_category, ->(category) { where("'#{category}' = ANY (categories)") }
    scope :filter_open, ->(_time) { where('? between open_at AND close_at', Time.current) }
  end

  class_methods do
    def filter(params)
      sort_key = params[:sort]
      results = near_to(params[:location], sort_key)
      params.fetch(:filter, {}).each do |key, value|
        results = results.public_send("filter_#{key}", value) if value.present?
      end
      results = results.order("#{sort_key} desc") if %w(rating checkin_count).include? sort_key
      results.paginate(params[:page])
    end

    def paginate(page)
      return where(nil) unless page
      page(page[:number]).per(page.fetch(:size, 20))
    end
  end

end
