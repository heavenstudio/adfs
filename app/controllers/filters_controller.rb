class FiltersController < ApplicationController
  before_action :set_filter, only: [:show, :edit, :update, :destroy, :option, :options]

  def index
    @filters = Filter.all
  end

  def show
  end

  def new
    @filter = Filter.new
  end

  def edit
  end

  def create
    @filter = Filter.new(filter_params)

    if @filter.save
      redirect_to @filter, notice: 'Filtro foi criado com sucesso.'
    else
      render :new
    end
  end

  def update
    if @filter.update(filter_params)
      redirect_to @filter, notice: 'Filtro foi atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @filter.destroy
    redirect_to filters_url, notice: 'Filtro foi apagado com sucesso.'
  end

  def option
    if params[:option].present?
      @filter.options += [params[:option]]
      @filter.save
      head :ok
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_filter
      @filter = Filter.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def filter_params
      params.require(:filter).permit(:name, :field_name, :field_type, :filterable, :required)
    end
end
