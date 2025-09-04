# frozen_string_literal: true

require "initable"

module Terminus
  module Actions
    module API
      module Models
        # The patch action.
        class Patch < Base
          include Deps[repository: "repositories.model"]
          include Initable[serializer: Serializers::Model]

          using Refines::Actions::Response

          params do
            required(:id).filled :integer

            required(:model).filled(:hash) do
              optional(:name).filled :string
              optional(:label).filled :string
              optional(:description).filled :string
              optional(:mime_type).filled :string
              optional(:colors).filled :integer
              optional(:bit_depth).filled :integer
              optional(:rotation).filled :integer
              optional(:offset_x).filled :integer
              optional(:offset_y).filled :integer
              optional(:width).filled :integer
              optional(:height).filled :integer
              optional(:published_at).filled :date_time
            end
          end

          def handle request, response
            parameters = request.params

            if parameters.valid?
              model = repository.update(*parameters.to_h.values_at(:id, :model))
              response.body = {data: serializer.new(model).to_h}.to_json
            else
              unprocessable_entity parameters, response
            end
          end

          private

          def unprocessable_entity parameters, response
            body = problem[
              type: "/problem_details#model_payload",
              status: :unprocessable_entity,
              detail: "Validation failed.",
              instance: "/api/models",
              extensions: {errors: parameters.errors.to_h}
            ]

            response.with body: body.to_json, format: :problem_details, status: 422
          end
        end
      end
    end
  end
end
