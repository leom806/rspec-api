require 'spec_helper'
require 'rspec-api/dsl'
require_relative '../github_helper'

# http://developer.github.com/v3/activity/notifications/
resource :notification do
  authorize_with token: ENV['RSPEC_API_GITHUB_TOKEN']

  has_attribute :id, type: :string
  has_attribute :repository, type: :object do
    has_attribute :id, type: {number: :integer}
    has_attribute :owner, type: :object do
      has_attribute :login, type: :string
      has_attribute :id, type: {number: :integer}
      has_attribute :avatar_url, type: [:null, string: :url]
      has_attribute :gravatar_id, type: [:null, :string]
      has_attribute :url, type: {string: :url}
    end
    has_attribute :name, type: :string
    has_attribute :full_name, type: :string
    has_attribute :description, type: :string
    has_attribute :private, type: :boolean
    has_attribute :fork, type: :boolean
    has_attribute :url, type: {string: :url}
    has_attribute :html_url, type: {string: :url}
  end
  has_attribute :subject, type: :object do
    has_attribute :title, type: :string
    has_attribute :url, type: {string: :url}
    has_attribute :latest_comment_url, type: {string: :url}
    has_attribute :type, type: :string
  end
  has_attribute :reason, type: :string
  has_attribute :unread, type: [:null, :boolean] # NOTE: why null? is it an error?
  has_attribute :updated_at, type: {string: :timestamp}
  has_attribute :last_read_at, type: [:null, string: :timestamp]
  has_attribute :url, type: {string: :url}

  accepts_filter :since, by: :updated_at, comparing_with: -> since, updated_at {since <= updated_at} # TODO: JSON parse timestamps
  accepts_filter :all, by: :unread, comparing_with: -> all, unread { all == 'true' || unread == 'true' } # TODO: JSON parse booleans
  accepts_filter :participating, by: :reason, comparing_with: -> participating, reason { participating == 'false' || ['author', 'mention'].include?(reason) } # TODO: JSON parse booleans

  get '/notifications', array: true do #, wip: true do
    request 'List your notifications' do
      respond_with :ok do |response|
        # NOTE: How do we make *internal* expectations not to be executed when
        #       a filter is passed? That is, a default value!
        # TODO: add value_in
        # expect(response).to have_fields :reason, value_in: ['mention', 'author']
      end
    end
  end

  get '/repos/:owner/:repo/notifications', array: true do
    request 'List your notifications in a repository', owner: existing(:user), repo: existing(:repo) do
      respond_with :ok
    end
  end

  put '/notifications' do
    request 'Mark as read' do
      respond_with :reset_content do
        # TODO: there is an optional last_read_at parameter; if set, it does
        # not *read* all the notification, but we need a subsequent call to
        # to GET to test that it actually works, because here there's no body
      end
    end
  end

  put '/repos/:owner/:repo/notifications' do
    request 'Mark notifications as read in a repository', owner: existing(:user), repo: existing(:repo) do
      respond_with :reset_content do
        # TODO: there is an optional last_read_at parameter; if set, it does
        # not *read* all the notification, but we need a subsequent call to
        # to GET to test that it actually works, because here there's no body
      end
    end
  end

  get '/notifications/threads/:id' do
    request 'View a single thread', id: existing(:thread_id) do
      respond_with :ok
    end
  end

  patch '/notifications/threads/:id' do
    request 'Mark a thread as read', id: existing(:thread_id) do
      respond_with :reset_content
    end
  end
end

resource :thread_subscription do
  authorize_with token: ENV['RSPEC_API_GITHUB_TOKEN']

  has_attribute :subscribed, type: :boolean
  has_attribute :ignored, type: :boolean
  has_attribute :reason, type: [:null, :string]
  has_attribute :created_at, type: {string: :timestamp}
  has_attribute :url, type: {string: :url}
  has_attribute :thread_url, type: {string: :url}

  get '/notifications/threads/:id/subscription' do
    request 'Get a Thread Subscription', id: existing(:thread_id) do
      respond_with :ok
    end
  end

  put '/notifications/threads/:id/subscription' do
    request 'Set a Thread Subscription', id: existing(:thread_id), subscribed: true, ignored: false do
      respond_with :ok do |response|
        expect(response).to have_attributes subscribed: {value: true}, ignored: {value: false}
      end
    end
  end

  # NOTE: This is the only one missing, because I need to create one first!
  delete '/notifications/threads/:id/subscription', wip: true do
    request 'Delete a Thread Subscription', id: existing(:thread_id) do
      respond_with :no_content
    end
  end
end