class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :destroy]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @filters = Filter.all
    @product = DynamicProductForm.new(filters: @filters)
  end

  def edit
    saved_product = Product.find(params[:id])
    @filters = Filter.all
    @product = DynamicProductForm.new(filters: @filters, product: saved_product, attributes: saved_product.attributes)
  end

  def create
    @filters = Filter.all
    @product = DynamicProductForm.new(attributes: product_params, filters: @filters)

    if @product.save
      redirect_to @product.document, notice: 'Produto foi criado com sucesso.'
    else
      render :new
    end
  end

  def update
    @filters = Filter.all
    saved_product = Product.find(params[:id])
    @product = DynamicProductForm.new(attributes: product_params, filters: @filters, product: saved_product)

    if @product.save
      redirect_to @product.document, notice: 'Produto foi atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_url, notice: 'Produto foi deletado com sucesso.'
  end

  def search
    @filters = Filter.filterable
    @product_search = ProductSearch.new(params[:q], params[:filters], @filters)
    @search = @product_search.search
    @active_filters_options = @product_search.active_filters_options
    @products = @search.results
    @total = @search.total
  end

  private
    def product_params
      params[:product] || {}
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end
end
