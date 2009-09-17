module ForeignKeys

  module ActiveRecord

    module Migration

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        ##
        # Adding a foreign key only works for +mysql+ and +postgresql+.
        #
        # Options
        #
        #  :delete => :restrict
        #  :delete => :cascade
        #
        # ON DELETE CASCADE by default sets referenced values to NULL.
        #
        # http://www.postgresql.org/docs/8.1/static/ddl-constraints.html
        #
        #  product_no integer REFERENCES products ON DELETE RESTRICT,
        #  order_id integer REFERENCES orders ON DELETE CASCADE,
        #
        #
        def add_foreign_key(from_table, from_column, to_table, to_table_id = 'id')
          constraint_name = "fk_#{from_table}_#{from_column}"
          case $adapter
          when 'mysql', 'postgresql'
            execute "ALTER TABLE #{from_table} ADD CONSTRAINT #{constraint_name} FOREIGN KEY (#{from_column}) REFERENCES #{to_table} (#{to_table_id});"
          else
            puts "   [NOTE] add_foreign_key is not available on this adapter."
          end
        end

        ##
        # Remove foreign key
        #
        def remove_foreign_key(from_table, from_column)
          constraint_name = "fk_#{from_table}_#{from_column}"
          case $adapter
          when 'mysql'
            execute "ALTER TABLE #{from_table} DROP FOREIGN KEY #{constraint_name};"
          when 'postgresql'
            execute "ALTER TABLE #{from_table} DROP CONSTRAINT #{constraint_name};"
          else
            puts "   [NOTE] remove_foreign_key is not available on this adapter."
          end
        end

      end

    end

  end

end

$adapter = (ENV['RAILS_ENV'] == 'test') ? 'postgresql' : ActiveRecord::Base.configurations[RAILS_ENV]['adapter']

ActiveRecord::Migration.send(:include, ForeignKeys::ActiveRecord::Migration)
