class DiseasesController < BaseController
  def index
    render json: Disease.all
  end

  def show
    if params[:id].to_i > 0
      @disease = Disease.find(params[:id])
    else
      @disease = Disease.where('name LIKE ?', "%#{params[:id]}%")
    end
    render json: @disease
  end

  def create
    @disease = Disease.create! disease_create_params
    render json: @disease
  end

  def destroy
    @disease = Disease.find params[:id]
    @disease.destroy!
    render json: @disease
  end

  private

  def disease_create_params
    {
      name: params.require(:name),
      gender: params.require(:gender)
    }
  end

  def required_permission
    'disease'
  end
end
