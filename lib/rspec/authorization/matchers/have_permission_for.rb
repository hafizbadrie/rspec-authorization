module RSpec::Authorization
  module Matchers
    # Include this module to enable the +have_permission_for+ matcher inside RSpec.
    # The following module is to be included only inside controller spec, this will
    # add the capability to do a matcher against decalrative_authorization rules as
    # follows:
    #
    #   it { is_expected.to have_permission_for(:user).to(:index) }
    #
    # For your convenience, the following configuration has been enabled inside
    # RSpec configuration.
    #
    #   RSpec.configure do |config|
    #     config.include RSpec::Authorization::Matchers::HavePermissionFor, type: :controller
    #   end
    module HavePermissionFor
      # Matcher to check permission of a role for a given controller in a spec. The
      # following statement shows you how to use this matcher:
      #
      #   describe ArticlesController do
      #     it { is_expected.to have_permission_for(:user).to(:index) }
      #   end
      #
      # Currently this matcher only support restful action check, to check the
      # controller against +config/authorization_rules.rb+. Skipping the +#to+
      # method will result in default action assigned as +:index+.
      #
      # Therefore, the following statement is exactly the same as above:
      #
      #   it { is_expected.to have_permission_for(:user) }
      #
      # === RESTful helper methods
      #
      # For your convenience, there are restful helper methods available to be
      # chained from the matcher, consider the following example:
      #
      #   it { is_expected.to have_permission_for(:user).to_read }
      #   it { is_expected.to have_permission_for(:user).to_create }
      #   it { is_expected.not_to have_permission_for(:user).to_update }
      #   it { is_expected.not_to have_permission_for(:user).to_delete }
      #   it { is_expected.not_to have_permission_for(:user).to_manage }
      #
      # Matcher for restful helper methods is slightly different than that of
      # a single method, following is an example of how restful helper methods
      # request results evaluated:
      #
      #   all_requests (of #to_read)       matches?     does_not_match?
      #   -------------------------------------------------------------------
      #   {index: true, show: true}        true         false
      #   {index: true, show: false}       false        false
      #   {index: false, show: false}      false        true
      #
      # === Focused RESTful helper methods
      #
      # There are cases where you need to focused your matching only for a given
      # criteria, let's say only match for read actions, or match except delete
      # action, consider the following example:
      #
      #   it { is_expected.to have_permission_for(:user).only_to_read }
      #   it { is_expected.to have_permission_for(:writer).except_to_delete }
      #
      # The above statements have their negated counterparts, consider the
      # following example:
      #
      #   it { is_expected.not_to have_permission_for(:user).only_to_read }
      #   it { is_expected.not_to have_permission_for(:writer).only_to_delete }
      #
      # If you see the above negated matcher, they actually have a relationship
      # to the other's negated counterpart instead of theirs, consider the following
      # example:
      #
      #   it { is_expected.to have_permission_for(:user).only_to_read }
      #   it { is_expected.not_to have_permission_for(:user).except_to_read }
      #
      # The above examples are doing exactly the same thing, so does the following
      # example, these examples below also doing exactly the same thing and can
      # be used in either case:
      #
      #   it { is_expected.to have_permission_for(:writer).except_to_delete }
      #   it { is_expected.not_to have_permission_for(:writer).only_to_read }
      #
      # That means, the following example, is actually negating each other and
      # can be used to negate your statements instead of using the negated version
      # of the matcher:
      #
      #   it { is_expected.to have_permission_for(:user).only_to_read }
      #   it { is_expected.to have_permission_for(:user).except_to_read }
      #
      # Even if you can have a negated matcher using a focused restful helper
      # methods, it is better to stick with the possitive matcher, negated matcher
      # can easily confuse you, and it only serves the purpose of completeness.
      #
      # @param role [Symbol] role name to matched against
      # @see RestfulHelperMethod
      def have_permission_for(role)
        HavePermissionFor.new(role)
      end

      class HavePermissionFor # :nodoc: all
        include Adapters

        attr_reader :role, :prefix, :action
        attr_reader :resource, :restful_helper_method, :privilege
        attr_reader :actions, :negated_actions

        def initialize(role)
          @role = role

          @actions = [:index]
          @negated_actions = []
        end

        def to(action)
          @prefix  = :to
          @action  = action
          @actions = [action]

          self
        end

        def method_missing(method_name, *args, &block)
          @restful_helper_method = RestfulHelperMethod.new(method_name)

          @actions = restful_helper_method.actions
          @negated_actions = restful_helper_method.negated_actions

          self
        end

        def matches?(controller)
          build_resource(controller)

          resource.run_all
          resource.permitted?
        end

        def does_not_match?(controller)
          build_resource(controller)

          resource.run_all
          resource.forbidden?
        end

        def failure_message
          "Expected #{common_failure_message}"
        end

        def failure_message_when_negated
          "Did not expect #{common_failure_message}"
        end

        def description
          "have permission for #{role} #{humanized_behavior}"
        end

        private

        def build_resource(controller)
          @privilege = Privilege.new(
            actions: actions,
            negated_actions: negated_actions,
            controller_class: controller.class,
            role: role
          )

          @resource = Resource.new(privilege)
        end

        def humanized_behavior
          restful_helper_method.try(:humanize) || "#{@prefix} #{action}"
        end

        def common_failure_message
          "#{resource.controller_class} to #{description}. #{debug_results}"
        end

        def debug_results
          "results: #{resource.results}, negated_results: #{resource.negated_results}"
        end
      end
    end
  end
end

