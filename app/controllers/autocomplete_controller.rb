class AutocompleteController < ApplicationController
  def tags
    query = params[:q].to_s.strip
    tags = if query.blank?
      Tag.order(:name).limit(30).pluck(:name)
    else
      Tag.where("name ILIKE ?", "%#{query}%").order(:name).limit(30).pluck(:name)
    end

    render json: tags
  end

  def search
    query = params[:q].to_s.strip
    return render json: [] if query.blank?

    names = Product.where("name ILIKE ?", "%#{query}%").limit(10).pluck(:name)
    brands = Product.where("brand ILIKE ?", "%#{query}%").limit(10).pluck(:brand)
    flavors = Product.where("flavor ILIKE ?", "%#{query}%").limit(10).pluck(:flavor)
    tags = Tag.where("name ILIKE ?", "%#{query}%").limit(10).pluck(:name)

    render json: (names + brands + flavors + tags).uniq.first(20)
  end
end
