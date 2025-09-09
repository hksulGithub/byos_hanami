# frozen_string_literal: true

require "petail"

module Terminus
  module Actions
    module API
      # The base action.
      class Base < Hanami::Action
        format :json

        def initialize(problem: Petail, **)
          @problem = problem
          super(**)
        end

        protected

        attr_reader :problem

        def verify_csrf_token?(*) = false
      end
    end
  end
end
