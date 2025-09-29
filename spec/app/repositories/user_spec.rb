# frozen_string_literal: true

require "hanami_helper"

RSpec.describe Terminus::Repositories::User, :db do
  subject(:repository) { described_class.new }

  let(:user) { Factory[:user] }

  before { Hanami::CLI::Commands::App::DB::Seed.new.call }

  describe "#all" do
    it "answers all records by created date/time" do
      user
      two = Factory[:user, name: "two"]
      records = repository.all.map(&:to_h).each { it.delete :current_item }

      expect(records).to eq([user.to_h, two.to_h])
    end

    it "answers empty array when records don't exist" do
      expect(repository.all).to eq([])
    end
  end

  describe "#find" do
    it "answers record by ID" do
      expect(repository.find(user.id)).to have_attributes(user.to_h)
    end

    it "answers nil for unknown ID" do
      expect(repository.find(666)).to be(nil)
    end

    it "answers nil for nil ID" do
      expect(repository.find(nil)).to be(nil)
    end
  end

  describe "#find_by" do
    it "answers record when found by single attribute" do
      expect(repository.find_by(name: user.name)).to have_attributes(user.to_h)
    end

    it "answers record when found by multiple attributes" do
      expect(repository.find_by(name: user.name, email: user.email)).to have_attributes(user.to_h)
    end

    it "answers nil when not found" do
      expect(repository.find_by(name: "bogus")).to be(nil)
    end

    it "answers nil for nil" do
      expect(repository.find_by(name: nil)).to be(nil)
    end
  end

  describe "#search" do
    let(:user) { Factory[:user, name: "Test"] }

    before { user }

    it "answers records for case insensitive value" do
      expect(repository.search(:name, "test")).to contain_exactly(have_attributes(name: "Test"))
    end

    it "answers records for partial value" do
      expect(repository.search(:name, "te")).to contain_exactly(have_attributes(name: "Test"))
    end

    it "answers empty array for invalid value" do
      expect(repository.search(:name, "bogus")).to eq([])
    end
  end

  describe "#where" do
    it "answers record for single attribute" do
      expect(repository.where(name: user.name)).to contain_exactly(user)
    end

    it "answers record for multiple attributes" do
      expect(repository.where(name: user.name, email: user.email)).to contain_exactly(user)
    end

    it "answers empty array for unknown value" do
      expect(repository.where(name: "bogus")).to eq([])
    end

    it "answers empty array for nil" do
      expect(repository.where(name: nil)).to eq([])
    end
  end
end
