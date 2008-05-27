module SimplifiedConstraints

  ##
  # Format of email
  #
  def add_email_check(table, column)
    execute "ALTER TABLE #{table} ADD CONSTRAINT valid_#{column} CHECK (((#{column})::text ~ E'^([-a-z0-9]+)@([-a-z0-9]+[.]+[a-z]{2,4})$'::text));"
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
  #  validates_length_of :first_name, :maximum => 30
  #  validates_length_of :first_name, :minimum => 10
  #  validates_length_of :user_name, :within => 6..20
  #  validates_length_of :password, :is => 4
  #  validates_length_of :fax, :in => 7..32, :allow_nil => true
  #  validates_length_of :phone, :in => 7..32, :allow_blank => true
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
  # validates_inclusion_of :gender, :in => %w( m f )
  # validates_inclusion_of :age, :in => 0..99
  # validates_inclusion_of :format, :in => %w( jpg gif png )
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
  # Uniqueness ...
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

$adapter = ActiveRecord::Base.configurations[RAILS_ENV || 'development']['adapter']

case $adapter
  when 'mysql':      ActiveRecord::ConnectionAdapters::MysqlAdapter.send(:include, SimplifiedConstraints)
  when 'postgresql': ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.send(:include, SimplifiedConstraints)
  when 'sqlite3':    ActiveRecord::ConnectionAdapters::SQLite3Adapter.send(:include, SimplifiedConstraints)
end