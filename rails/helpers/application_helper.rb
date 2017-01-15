module ApplicationHelper

  def product_image_url product
    return 'product_images_production/product_missing' unless image = product.master_image 
    image_id = image.image_id.to_s.split('/').last
    "listing_images_production/#{image_id}"
  end

  def state_select name, options={}
    select_tag name, options_for_select(%w(Gujarat Kerala Karnataka Maharashtra TamilNadu), selected: options[:selected]), options
  end

  def user_avatar user
    if user.picture
      user.picture
    elsif user.image
      cloudinary_url(user.image.image_id)
    else
      asset_path('user.png')
    end
  end
  
  def rating_bar rating
    "<div class='progress-bar' style='width: #{rating * 20}%; background: #{get_color(rating)}'></div>".html_safe
  end
  
  def get_color(rating)
    %w(#e74c3c #e67e22 #f1c40f #3498db #30d284)[1]
  end
end
