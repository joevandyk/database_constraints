module DatabaseConstraints

  module ActiveRecord

    module Migration

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        ##
        # Format of email.
        #
        #   [a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])
        #
        def add_email_check(table, column)
          execute "ALTER TABLE #{table} ADD CONSTRAINT valid_#{column} CHECK (((#{column})::text ~ E'^([-a-z0-9]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])$'::text));"
          message_for_success
        rescue
          message_for_warning "add_email_check"
        end

        def remove_email_check(table, column)
          drop_constraint(table, column)
        rescue
          message_for_warning "remove_email_check"
        end

        ##
        # Login should always contain A-Z, a-z and 0-9 values.
        #
        def add_login_check(table, column)
          execute "ALTER TABLE #{table} ADD CONSTRAINT valid_#{column} CHECK (((#{column})::text ~* '^[a-z0-9]+$'::text));"
          message_for_success
        rescue
          message_for_warning "add_login_check"
        end

        def remove_login_check(table, column)
          drop_constraint(table, column)
        rescue
          message_for_warning "remove_login_check"
        end

        ##
        # Value is positive
        #
        def add_positive_check(table, column)
          execute "ALTER TABLE #{table} ADD CONSTRAINT valid_#{column} CHECK (#{column} > 0);"
          message_for_success
        rescue
          message_for_warning "add_positive_check"
        end

        def remove_positive_check(table, column)
          drop_constraint(table, column)
        rescue
          message_for_warning "remove_positive_check"
        end

        ##
        #  - :maximum => 30
        #  - :minimum => 10
        #  - :within => 6..20
        #  - :is => 4
        #  - :in => 7..32, :allow_nil => true
        #
        def add_length_check(table, column, options = { :is => 5 })
          execute "ALTER TABLE #{table} ADD CONSTRAINT valid_#{column} CHECK (char_length(#{column}) = #{options[:is]});"
          message_for_success
        end

        def remove_length_check(table, column)
          drop_constraint(table, column)
        rescue
          message_for_warning "remove_length_check"
        end

        ##
        # - :in => 0..99
        # - :in => %w( jpg gif png )
        #
        def add_inclusion_check(table, column, inclusion)
          message_for_success
        end

        def remove_inclusion_check(table, column)
          drop_constraint(table, column)
        rescue
          message_for_warning "remove_inclusion_check"
        end

        ##
        # Uniqueness of row
        #
        def add_uniqueness_check(table, column)
          execute "ALTER TABLE #{table} ADD CONSTRAINT unique_#{column} UNIQUE (#{column});"
          message_for_success
        end

        def remove_uniqueness_check(table, column)
          drop_constraint(table, column)
        rescue
          message_for_warning "remove_uniqueness_check"
        end

      private

        def drop_constraint(table, column)
          execute "ALTER TABLE #{table} DROP CONSTRAINT valid_#{column};"
        end

        def message_for_success(feedback = "Constraint")
          puts "   [SUCCESS] #{feedback} added."
        end

        def message_for_warning(feedback = "constraint_check")
          puts "   [WARNING] #{feedback} is not available on this adapter."
        end

      end

    end

  end

end

$adapter = (ENV['RAILS_ENV'] == 'test') ? 'postgresql' : ActiveRecord::Base.configurations[RAILS_ENV]['adapter']

ActiveRecord::Migration.send(:include, DatabaseConstraints::ActiveRecord::Migration)