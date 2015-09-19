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
    active_filters = {}
    active_filters_options = {}
    filters = Filter.filterable

    @search = Sunspot.search(Product) do
      keywords params[:q] if params[:q].present?
      dynamic :filters do
        selected_filters = params[:filters] || {}

        # loop each selected filter, give their field name and select options and exclude empty values
        selected_filters.each do |field_name, selected_options|
          next if selected_options.blank? || selected_options == ['']
          cleansed_selected_options = selected_options.select(&:present?)
          active_filters[field_name] = with(field_name, cleansed_selected_options)
          active_filters_options[field_name] = cleansed_selected_options.select(&:present?)
        end

        filters.each do |filter|
          facet filter.field_name, exclude: active_filters[filter.field_name]
        end
      end
    end
    @products = @search.results
    @filters = filters || []
    @active_filters_options = active_filters_options || {}
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
