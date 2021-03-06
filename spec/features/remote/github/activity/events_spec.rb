require 'spec_helper'
require_relative '../github_helper'

# http://developer.github.com/v3/activity/events/
resource :event do
  has_attribute :id, type: :string
  has_attribute :type, type: :string
  has_attribute :actor, type: :object do
    # has_attribute :id, type: {number: :integer}  # Sometimes it's missing!!
    # has_attribute :login, type: :string  # Sometimes it's missing!!
    # has_attribute :gravatar_id, type: [:null, :string]  # Sometimes it's missing!!
    has_attribute :url, type: {string: :url}
    has_attribute :avatar_url, type: [:null, string: :url]
  end
  has_attribute :repo, type: :object do
    # has_attribute :id, type: {number: :integer}  # Sometimes it's missing!!
    has_attribute :name, type: :string
    has_attribute :url, type: {string: :url}
  end
  has_attribute :payload, type: :object # See http://git.io/Uln6EQ for types
  has_attribute :public, type: :boolean
  has_attribute :created_at, type: {string: :timestamp}
  # has_attribute :org, type: :object do  # Sometimes it's missing!!
  #   has_attribute :id, type: {number: :integer}
  #   has_attribute :login, type: :string
  #   has_attribute :gravatar_id, type: [:null, :string]
  #   has_attribute :url, type: {string: :url}
  #   has_attribute :avatar_url, type: [:null, string: :url]
  # end

  accepts page: :page

  get '/events', collection: true do
    respond_with :ok
  end

  get '/repos/:owner/:repo/events', collection: true do
    respond_with :ok, owner: existing(:user), repo: existing(:repo)
  end

  get '/networks/:owner/:repo/events', collection: true do
    respond_with :ok, owner: existing(:user), repo: existing(:repo)
  end

  get '/orgs/:org/events', collection: true do
    respond_with :ok, org: existing(:org)
  end

  get '/users/:user/received_events', collection: true do
    respond_with :ok, user: existing(:user)
  end

  get '/users/:user/received_events/public', collection: true do
    respond_with :ok, user: existing(:user)
  end

  get '/users/:user/events', collection: true do
    respond_with :ok, user: existing(:user)
  end

  get '/users/:user/events/public', collection: true do
    respond_with :ok, user: existing(:user)
  end

  get '/users/:user/events/orgs/:org', collection: true do
    respond_with :ok, user: existing(:user), org: existing(:org)
  end
end