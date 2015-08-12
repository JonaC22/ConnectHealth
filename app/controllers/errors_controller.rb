class ErrorsController < BaseController
  def show
    error = request.env['action_dispatch.exception']
    logger.error "Request from #{request.remote_ip} produced: #{error.message}"
    return record_not_found error if error.is_a? ActiveRecord::RecordNotFound
    return parameter_missing error if error.is_a? ActionController::ParameterMissing
    return record_invalid error if error.is_a? ActiveRecord::RecordInvalid
    return record_duplicated error if error.is_a? ActiveRecord::RecordNotUnique
    exception error
  end

  private

  def record_not_found(error)
    render json: { error: { message: error.message.downcase, details: 'the specified record could not be found' } }, status: :not_found
  end

  def parameter_missing(error)
    render json: { error: { message: { error.param.downcase => error.message.downcase }, details: 'there was a parameter missing' } }, status: :bad_request
  end

  def record_invalid(error)
    render json: { error: { message: error.record.errors.messages.each_with_object({}) { |(k, v), h| h[k.downcase] = v.first.downcase }, details: 'the record was invalid' } }, status: :bad_request
  end

  def record_duplicated(_error)
    render json: { error: { message: 'relationship already exists', details: 'relationship already exists' } }
  end

  def exception(error)
    render json: { error: error.message.downcase }, status: 500
  end
end
