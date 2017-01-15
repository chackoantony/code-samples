# Products controller
class API::V1::ProductsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :resource_not_found

  def index
    render json: 'Invalid Request', status: 400 unless valid_request?
    product = Product.filter(filter_params)
    render json: product, each_serializer: ProductFilterSerializer
  end

  def show
    product = Product.find params[:id]
    render json: product, include: %w(activities ratings)
  end

  def create
    product = Product.new(product_params)
    product.user = current_user
    if product.save
      render json: product, status: 200
    else
      render json: product.errors, status: 400
    end
  end

  private

  def product_params
    params.require(:product).permit(:title, :category, :sku, :cost, :master_image, :brand_id)
  end

  def filter_params
    params.permit(:sort, page: [:size, :number], filter: [:category, :hot, :brand])
  end

  def valid_request?
    params.fetch(:location)
  end

  def resource_not_found(exception)
    render json: exception.message, status: 404
  end

end
