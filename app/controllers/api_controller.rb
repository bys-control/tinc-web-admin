class ApiController < ApplicationController

	def dump
    request.format = :json
    command = params[:element].try(:to_sym)

    respond_to do |format|
      format.json do
        render json: helpers.dump(command).as_json
      end
    end

	end

  def info
    request.format = :json
    element = params[:element]

    respond_to do |format|
      format.json do
        if element.present?
          render json: helpers.info(element).as_json
        else
          render json: {
            error: "Expecting 'element' parameter in the URL"
          }
        end
      end
    end
  end

end
