require 'spec_helper'
require 'rspec-api/dsl'
require_relative '../github_helper'

resource :owner do
  has_attribute :login, type: :string
  has_attribute :id, type: {number: :integer}
  has_attribute :avatar_url, type: [:null, string: :url]
  has_attribute :gravatar_id, type: [:null, :string]
  has_attribute :url, type: {string: :url}
end

def attributes_of(resource)
  RSpec.world.example_groups.find{|x| x.rspec_api[:resource_name] == resource}.rspec_api[:attributes]
end

# http://developer.github.com/v3/repos/
resource :repo do
  authorize_with token: ENV['RSPEC_API_GITHUB_TOKEN']

  has_attribute :id, type: {number: :integer}
  has_attribute :owner, type: {object: attributes_of(:owner)}
  has_attribute :name, type: :string
  has_attribute :full_name, type: :string
  has_attribute :description, type: [:null, :string]
  has_attribute :private, type: :boolean
  has_attribute :fork, type: :boolean
  has_attribute :url, type: {string: :url}
  has_attribute :html_url, type: {string: :url}
  has_attribute :clone_url, type: {string: :url}
  has_attribute :git_url, type: :string # should change URL to accept git://
  has_attribute :ssh_url, type: :string # should change URL to accept git@
  has_attribute :svn_url, type: {string: :url}
  has_attribute :mirror_url, type: [:null, :string] # should change URL to accept git://
  has_attribute :homepage, type: [:null, string: :url]
  has_attribute :language, type: [:null, :string]
  has_attribute :forks, type: {number: :integer}
  has_attribute :forks_count, type: {number: :integer}
  has_attribute :watchers, type: {number: :integer}
  has_attribute :watchers_count, type: {number: :integer}
  has_attribute :size, type: {number: :integer}
  has_attribute :master_branch, type: :string
  has_attribute :open_issues, type: {number: :integer}
  has_attribute :open_issues_count, type: {number: :integer}
  has_attribute :pushed_at, type: [:null, string: :timestamp]
  has_attribute :created_at, type: {string: :timestamp}
  has_attribute :updated_at, type: {string: :timestamp}

  get '/users/:user/repos', array: true do
    request 'List user repositories', user: existing(:user) do
      respond_with :ok
    end
  end
end