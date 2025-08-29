# frozen_string_literal: true

require "dry/monads"
require "initable"

module Terminus
  module Aspects
    module Screens
      # Creates error with problem details for device.
      # :reek:DataClump
      class Gaffer
        include Deps[
          "aspects.screens.creator",
          "aspects.screens.creators.temp_path",
          repository: "repositories.screen",
          model_repository: "repositories.model",
          view: "views.screens.gaffe.new"
        ]
        include Initable[mold: Mold]
        include Dry::Monads[:result]

        def call device, message
          repository.find_by(name: device.system_name("error"))
                    .then do |screen|
                      screen ? update(screen, device, message) : create(device, message)
                    end
        end

        def create device, message
          creator.call content: String.new(view.call(message:)),
                       **device.system_screen_attributes("error")
        end

        def update screen, device, message
          temp_path.call build_mold(device, message) do |path|
            replace screen.name, path, {"filename" => "#{device.system_name :error}.png"}
          end
        end

        def replace name, path, metadata
          path.open { |io| repository.update_image name, io, metadata: }
        end

        # :reek:FeatureEnvy
        def build_mold device, message
          mold.for model_repository.find(device.model_id),
                   label: device.system_label("Error"),
                   name: device.system_name("error"),
                   content: String.new(view.call(message:))
        end
      end
    end
  end
end
