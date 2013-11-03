require 'rspec-api/http/remote'

module GithubRoute
  extend ActiveSupport::Concern

  module ClassMethods

    def setup_fixtures
      # nothing to do for now...
    end

    def existing(field)
      case field
      when :org then 'rspec-api'
      when :user, :owner, :assignee then 'rspecapi'
      when :repo then 'guinea-pig' # has heads, tails, pull, notes
      when :gist_id then '7175672'
      when :gist_comment_id then '937901'

      when :blob_sha then 'f32932f7c927d86f57f56d703ac2ed100ceb0e47'
      when :commit_sha then 'c98a37ea3b2759d0c43fb8abfa9abd3146938790'
      when :tree_sha then 'ebca91692290192f50acc307af9fe26b2eab4274'
      when :ref then 'heads/master'
      when :starred_repo then 'rspec-expectations' # make it different from :repo
      when :unstarred_repo then 'rspec-core'  # make it different from :repo
      when :starred_gist_id then 'e202e2fb143c54e5139a'
      when :unstarred_gist_id then '8f2ef7e69ab79084d833'
      when :someone_elses_gist_id then '4685e0bebbf05370abd6'
      when :thread_id then '17915960'
      when :id then '921225'
      # NOTE: The following are confusing: they are used for filters, not value
      # For instance, it's not that we must have an object with the following
      # updated_at, we just use it for the since filter
      when :updated_at then '2013-10-31T09:53:00Z' # TODO use helpers
      # NOTE: Here's the confusion: :unread is used for the :all filter, but
      # it has the reverse meaning: ?all=false will only show unread='true'
      when :unread then 'false' # TODO use helpers
      # NOTE: Here's more confusion: :reason is a string, but this is used for
      # the boolean parameter participating:
      # ?participating=true (default), only show reason = 'mention' or 'author'
      # ?participating=false, show all reasons
      when :reason then 'true' # TODO use helpers
      end
    end

    def unknown(field)
      case field
      when :user, :assignee then 'not-a-valid-user'
      when :gist_id then 'not-a-valid-gist-id'
      when :id then 'not-a-valid-id'
      end
    end
  end
end

RSpec.configuration.include GithubRoute, rspec_api_dsl: :route