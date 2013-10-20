require 'active_support/core_ext/object' # present?


module DSL
  module Route
    extend ActiveSupport::Concern

    def send_request(verb, route, body)
      # To be overriden by more specific modules
    end

    module ClassMethods
      def request(*args, &block)
        text, values = parse_request_arguments args
        sets_of_parameters.each do |params|
          request_with_params text, values.merge(params), &block
        end
      end

      def setup_fixtures
        # To be overriden by more specific modules
      end

      def existing(field)
        # To be overriden by more specific modules
      end

    private

      def request_with_params(text, values = {}, &block)
        context request_description(text, values), rspec_api_dsl: :request do
          # NOTE: Having setup_fixtures inside the context sets up different
          # fixtures for each `request` inside the same `get`. This might be
          # a little slower on the DB, but ensures that two `request`s do not
          # conflict. For instance, if you have two `request` inside a `delete`
          # and the first deletes an instance, the second `request` is no
          # affected.
          setup_fixtures
          setup_request rspec_api[:verb], rspec_api[:route], values
          instance_eval(&block) if block_given?
        end
      end

      def sets_of_parameters
        [].tap do |sets_of_params|
          sets_of_params.push no_params
          sets_of_params.push callback_params if rspec_api[:callback]
          if rspec_api[:array]
            sets_of_params.push sort_params(verse: :asc) if rspec_api[:sort]
            sets_of_params.push sort_params(verse: :desc) if rspec_api[:sort]
            sets_of_params.push page_params if rspec_api[:page]
            sets_of_params.push filter_params if rspec_api[:filter]
          end
        end
      end

      def no_params
        {} # always send the original request without extra parameters
      end

      def sort_params(options = {})
        ascending = options[:verse] == :asc
        sort = rspec_api[:sort][:name]
        {sort: ascending ? "#{sort}" : "-#{sort}"}
      end

      def page_params
        {}.tap do |params|
          params[rspec_api[:page][:name]] = rspec_api[:page][:value]
        end
      end

      def filter_params
        {}.tap do |params|
          params[rspec_api[:filter][:name]] = existing rspec_api[:filter][:on]
        end
      end

      def callback_params
        {}.tap do |params|
          params[rspec_api[:callback][:name]] = rspec_api[:callback][:value]
        end
      end

      def setup_request(verb, route, values)
        request = Proc.new {
          interpolated_route, body = route.dup, values.dup
          body.keys.each do |key|
            if interpolated_route[":#{key}"]
              value = body.delete(key)
              value = value.call if value.is_a?(Proc)
              interpolated_route[":#{key}"] = value.to_s
              (@request_params ||= {})[key] = value
            else
              body[key] = body[key].call if body[key].is_a?(Proc)
            end
          end
          [interpolated_route, body]
        }
        before(:all) { send_request verb, *instance_eval(&request) }
      end

      def request_description(text, values)
        if values.empty?
          'by default'
        else
          text = "with" unless text.present?
          "#{text} #{values.map{|k,v| "#{k}#{" #{v}" unless v.is_a?(Proc)}"}.to_sentence}"
        end
      end

      def parse_request_arguments(args)
        text = args.first.is_a?(String) ? args[0] : ''
        values = args.first.is_a?(String) ? args[1] : args[0]
        [text, values || {}] # NOTE: In Ruby 2.0 we could write values.to_h
      end
    end
  end
end