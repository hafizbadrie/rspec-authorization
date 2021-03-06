module RSpec::Authorization
  module Adapters
    # Create a new restful helper method using the available dictionaries. Method
    # that is not available raise a +NoMethodError+, consider the following
    # example:
    #
    #   RestfulHelperMethod.new(:to_read)
    #
    # This class can be inferred automatically as an array, for example on
    # multiple assignment, consider the following example:
    #
    #   behavior, actions = RestfulHelperMethod(:to_read)
    #   behavior # => :read
    #   actions  # => [:index, :show]
    #
    # === RESTful helper methods
    #
    # Currently available helper method are:
    #
    # - +to_read+
    # - +to_create+
    # - +to_update+
    # - +to_delete+
    # - +to_manage+
    #
    # The above method is not related to declarative_authorization privileges,
    # and serve simply as convinience method, below is a table of restful actions
    # returned from the restful helper method:
    #
    #   Method        RESTful actions
    #   ----------------------------------------------------------------------
    #   to_read       [:index, :show]
    #   to_create     [:new, :create]
    #   to_update     [:edit, :update]
    #   to_delete     [:destroy]
    #   to_manage     [:index, :show, :new, :create, :edit, :update, :destroy]
    #
    # === Focused RESTful helper methods
    #
    # Currently available focused helper methods are:
    #
    # - +only_to_read+
    # - +only_to_create+
    # - +only_to_update+
    # - +only_to_delete+
    #
    # And their negated counterparts are:
    #
    # - +except_to_read+
    # - +except_to_create+
    # - +except_to_update+
    # - +except_to_delete+
    #
    # The above helper methods have a different action table compared to the
    # regular helper methods, this is due to it's nature to focus only on certain
    # behavior, and it negates other actions:
    #
    #   Method         Focused actions   Negated actions
    #   -------------------------------------------------------------------------
    #   only_to_read   [:index, :show]   [:new, :create, :edit, :update, :delete]
    #   only_to_create [:new, :create]   [:index, :show, :edit, :update, :delete]
    #   only_to_update [:edit, :update]  [:index, :show, :new, :create, :delete]
    #   only_to_delete [:destroy]        [:index, :show, :new, :create, :edit, :update]
    #
    # The negated focused helper methods have exactly the opposite matching table,
    # following is actions table for negated focused helper methods:
    #
    #   Method           Focused actions                                Negated actions
    #   -------------------------------------------------------------------------------
    #   except_to_read   [:new, :create, :edit, :update, :delete]       [:index, :show]
    #   except_to_create [:index, :show, :edit, :update, :delete]       [:new, :create]
    #   except_to_update [:index, :show, :new, :create, :delete]        [:edit, :update]
    #   except_to_delete [:index, :show, :new, :create, :edit, :update] [:destroy]
    #
    class RestfulHelperMethod
      # @return [Symbol] Restful helper method prefix
      attr_reader :prefix
      # @return [Symbol] Restful helper method name
      attr_reader :name
      # @return [Symbol] The behavior of the restful helper method
      attr_reader :behavior
      # @return [Array<Symbol>] The list of actions for a given behavior
      attr_reader :actions
      # @return [Array<Symbol>] The list of negated actions for a given behavior
      attr_reader :negated_actions

      # Creates a restful helper method using the available dictionaries. Invalid
      # or a non-available helper method that passed in raise an error, consider
      # the following example:
      #
      #   RestfulHelperMethod.new(:to_explode) # this will explode
      #   => NoMethodError: undefined method `to_explode' for RestfulHelperMethod
      #
      # @param name [Symbol] restful method name to be retrieved
      def initialize(name)
        @name, @prefix, @behavior = find_method(name).to_a.map(&:to_sym)

        raise NoMethodError, error_message unless DICTIONARIES.key?(behavior)

        @actions         = DICTIONARIES[behavior]
        @negated_actions = prefix.eql?(:to) ? [] : (DICTIONARIES[:manage] - actions)

        swap_negated_actions if prefix.eql?(:except_to)
      end

      def humanize
        name.to_s.gsub("_", " ")
      end

      private

      def error_message
        "undefined method `#{name}' for #{self.class}"
      end

      def find_method(name)
        /^(to|only_to|except_to)_(.*)$/.match(name)
      end

      def swap_negated_actions
        @actions, @negated_actions = negated_actions, actions
      end

      def to_a
        [actions, negated_actions]
      end

      DICTIONARIES = {
        read:   %i(index show),
        create: %i(new create),
        update: %i(edit update),
        delete: %i(destroy),
        manage: %i(index show new create edit update destroy)
      }
    end
  end
end
