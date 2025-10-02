# frozen_string_literal: true

require "bcrypt"

module Terminus
  module Aspects
    module Users
      # Validates and creates a new user complete with account and membership.
      class Creator
        include Deps[
          contract: "contracts.users.create",
          repository: "repositories.user",
          password_relation: "relations.user_password_hash",
          account_repository: "repositories.account",
          membership_relation: "relations.membership"
        ]
        include Dry::Monads[:result]

        DEFAULTS = {name: "default", label: "Default"}.freeze

        def initialize(encryptor: BCrypt::Password, defaults: DEFAULTS, **)
          @encryptor = encryptor
          @defaults = defaults
          super(**)
        end

        def call(**attributes)
          result = contract.call(attributes).to_monad

          return result if result.failure?

          Success create_user(attributes[:user], attributes.fetch(:account, {}))
        end

        private

        attr_reader :encryptor, :defaults

        def create_user user_attributes, account_attributes
          account_attributes = defaults.merge account_attributes
          password = user_attributes.delete :password

          repository.create(**user_attributes).tap do |user|
            password_relation.insert id: user.id, password_hash: encryptor.create(password)
            create_membership user, account_attributes
          end
        end

        def create_membership user, account_attributes
          account_repository.find_or_create(**account_attributes).then do |account|
            membership_relation.insert account_id: account.id, user_id: user.id
          end
        end
      end
    end
  end
end
