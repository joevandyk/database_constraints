module SimplifiedConstraints

  ##
  # It can be cleaner, I know!

  def add_email_check(table, column)
    constraint_name = "valid_#{column}"
    case $adapter
    when 'postgresql'
      execute "ALTER TABLE #{table} ADD CONSTRAINT #{constraint_name} CHECK (((#{column})::text ~ E'^([-a-z0-9]+)@([-a-z0-9]+[.]+[a-z]{2,4})$'::text));"
    else
      puts "   [NOTE] add_email_check constraint is not available on this adapter."
    end
  end

  def remove_email_check(table, column)
    constraint_name = "valid_#{column}"
    case $adapter
    when 'postgresql'
      execute "ALTER TABLE #{table} DROP CONSTRAINT #{constraint_name};"
    else
      puts "   [NOTE] remove_email_check constraint is not available on this adapter."
    end
  end

  def add_login_check(table, column)
    constraint_name = "valid_#{column}"
    case $adapter
    when 'postgresql'
      execute "ALTER TABLE #{table} ADD CONSTRAINT #{constraint_name} CHECK (((#{column})::text ~* '^[a-z0-9]+$'::text));"
    else
      puts "   [NOTE] add_email_check constraint is not available on this adapter."
    end
  end

  def remove_login_check(table, column)
    constraint_name = "valid_#{column}"
    case $adapter
    when 'postgresql'
      execute "ALTER TABLE #{table} DROP CONSTRAINT #{constraint_name};"
    else
      puts "   [NOTE] remove_login_check constraint is not available on this adapter."
    end
  end

  def add_positive_check(table, column)
    constraint_name = "valid_#{column}"
    case $adapter
    when 'postgresql'
      execute "ALTER TABLE #{table} ADD CONSTRAINT #{constraint_name} CHECK (#{column} > 0);"
    else
      puts "   [NOTE] add_positive_check constraint is not available on this adapter."
    end
  end

  def remove_positive_check(table, column)
    constraint_name = "valid_#{column}"
    case $adapter
    when 'postgresql'
      execute "ALTER TABLE #{table} DROP CONSTRAINT #{constraint_name};"
    else
      puts "   [NOTE] remove_positive_check constraint is not available on this adapter."
    end
  end

end

$adapter = ActiveRecord::Base.configurations[RAILS_ENV || 'development']['adapter']

case $adapter
  when 'mysql':      ActiveRecord::ConnectionAdapters::MysqlAdapter.send(:include, SimplifiedConstraints)
  when 'postgresql': ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send(:include, SimplifiedConstraints)
  when 'sqlite3':    ActiveRecord::ConnectionAdapters::SQLite3Adapter.send(:include, SimplifiedConstraints)
end