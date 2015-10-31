class AnnotationsController < BaseController
  def index
    @annotations = Annotation.where(pedigree_id: params[:pedigree_id])
    render json: @annotations
  end

  def show
    @annotation = Annotation.find(params[:id])
    render json: @annotation
  end

  def create
    @annotation = Annotation.create! annotation_create_params
    render json: @annotation
  end

  def update
    @annotation = Annotation.find params[:id]
    @annotation.update! annotation_update_params
    render json: @annotation
  end

  def destroy
    @annotation = Annotation.find params[:id]
    @annotation.destroy!
    render json: @annotation
  end

  private

  def annotation_create_params
    {
      pedigree_id: params[:pedigree_id],
      text: params.require(:text)
    }
  end

  def annotation_update_params
    params.permit(:text)
  end

  def required_permission
    'annotation'
  end
end
