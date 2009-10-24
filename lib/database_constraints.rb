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
          execute "ALTER TABLE #{table} ADD CONSTRAINT valid_#{column} CHECK ((#{column})::text ~ E'^([-a-z0-9+]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])$'::text);"
        rescue Exception => error
          message(error)
        end

        def remove_email_check(table, column)
          drop_constraint(table, column)
        rescue Exception => error
          message(error)
        end

        ##
        # Login should always contain A-Z, a-z and 0-9 values.
        #
        def add_login_check(table, column)
          execute "ALTER TABLE #{table} ADD CONSTRAINT valid_#{column} CHECK ((#{column})::text ~* '^[-a-z0-9]+$'::text);"
        rescue Exception => error
          message(error)
        end

        def remove_login_check(table, column)
          drop_constraint(table, column)
        rescue Exception => error
          message(error)
        end

        ##
        # Value is positive
        #
        def add_positive_check(table, column)
          execute "ALTER TABLE #{table} ADD CONSTRAINT valid_#{column} CHECK (#{column} > 0);"
        rescue Exception => error
          message(error)
        end

        def remove_positive_check(table, column)
          drop_constraint(table, column)
        rescue Exception => error
          message(error)
        end

        ##
        #  Not fully implemented.
        #
        #  - :maximum => 30
        #  - :minimum => 10
        #  - :within => 6..20
        #  - :is => 4
        #  - :in => 7..32, :allow_nil => true
        #
        def add_length_check(table, column, options = { :is => 5 })
          execute "ALTER TABLE #{table} ADD CONSTRAINT valid_#{column} CHECK (char_length(#{column}) = #{options[:is]});"
        rescue Exception => error
          message(error)
        end

        def remove_length_check(table, column)
          drop_constraint(table, column)
        rescue Exception => error
          message(error)
        end

        ##
        #  Not implemented.
        #
        # - :in => 0..99
        # - :in => %w( jpg gif png )
        #
        def add_inclusion_check(table, column, inclusion)
          execute ""
        rescue Exception => error
          message(error)
        end

        def remove_inclusion_check(table, column)
          drop_constraint(table, column)
        rescue Exception => error
          message(error)
        end

        ##
        # Uniqueness of row
        #
        def add_uniqueness_check(table, column)
          execute "ALTER TABLE #{table} ADD CONSTRAINT unique_#{column} UNIQUE (#{column});"
        end

        def remove_uniqueness_check(table, column)
          drop_constraint(table, column, 'unique_')
        rescue Exception => error
          message(error)
        end

      private

        def drop_constraint(table, column, prefix = 'valid_')
          execute "ALTER TABLE #{table} DROP CONSTRAINT #{prefix}#{column};"
        end

        def message(error)
          puts error.message
        end

      end

    end

  end

end

$adapter = (ENV['RAILS_ENV'] == 'test') ? 'postgresql' : ActiveRecord::Base.configurations[RAILS_ENV]['adapter']

ActiveRecord::Migration.send(:include, DatabaseConstraints::ActiveRecord::Migration)
