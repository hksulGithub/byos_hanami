# frozen_string_literal: true

module Terminus
  module Repositories
    # The account repository.
    class Account < DB::Repository[:account]
      commands :create, delete: :by_pk

      commands update: :by_pk,
               use: :timestamps,
               plugins_options: {timestamps: {timestamps: :updated_at}}

      def all
        account.order { created_at.asc }
               .to_a
      end

      def find(id) = (account.by_pk(id).one if id)

      def find_by(**) = account.where(**).one

      def search key, value
        account.where(Sequel.ilike(key, "%#{value}%"))
               .order { created_at.asc }
               .to_a
      end

      def where(**)
        account.where(**)
               .order { created_at.asc }
               .to_a
      end
    end
  end
end
