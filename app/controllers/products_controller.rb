class ProductsController < ApplicationController
  def index
    raw_query = params.dig(:q, :name_or_brand_or_flavor_or_tags_name_cont)
    q_params = params.fetch(:q, {}).to_unsafe_h
    if raw_query.present?
      terms = raw_query.to_s.split(/[,、]+/).reject(&:blank?)
      q_params.delete("name_or_brand_or_flavor_or_tags_name_cont")
    end

    @q = Product.left_joins(:product_stat).ransack(q_params)
    scoped = @q.result(distinct: true)

    if raw_query.present? && terms.present?
      products = Product.arel_table
      tags = Tag.arel_table
      conditions = terms.map do |term|
        pattern = "%#{term}%"
        products[:name].matches(pattern)
          .or(products[:brand].matches(pattern))
          .or(products[:flavor].matches(pattern))
          .or(tags[:name].matches(pattern))
      end
      combined = conditions.reduce { |memo, node| memo.and(node) }
      scoped = scoped.left_joins(:tags).where(combined)
    end

    @products = scoped.order(created_at: :desc).page(params[:page])
    @bookmarks_by_product_id = user_signed_in? ? current_user.product_bookmarks.index_by(&:product_id) : {}
  end

  def show
    @product = Product.find(params[:id])
    @reviews = @product.reviews.includes(user: { avatar_attachment: :blob }).order(created_at: :desc).page(params[:page]).per(3)
    @bookmarks_by_product_id = user_signed_in? ? current_user.product_bookmarks.index_by(&:product_id) : {}
  end
end
