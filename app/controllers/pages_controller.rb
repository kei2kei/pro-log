class PagesController < ApplicationController
  def home
    @q = Product.ransack(params[:q])
  end
end
