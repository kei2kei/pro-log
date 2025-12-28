class Admin::ProductsController < ApplicationController
  def index
    @products = Product.order(created_at: :desc)
  end

  def new
    @product = Product.new
  end

  def create
  end
end
