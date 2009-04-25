class DatabaseConstraintsGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      m.migration_template 'suggested_foreign_keys.rb', 'db/migrate',
        :assigns => { :possible_fks => suggest_fks }
    end
  end

  def file_name
    'suggested_foreign_keys'
  end

  def suggest_fks
    returning(Array.new) do |possible_fks|
      get_model_names.each do |model|
        class_name = model.sub(/\.rb$/,'').camelize
        klass = class_name.split('::').inject(Object){ |klass,part| klass.const_get(part) }
        if klass < ActiveRecord::Base && !klass.abstract_class?
          klass.reflections.each do |assoc_name, a_type|
            assoc_type = a_type.macro
            possible_fks << [klass.table_name, "#{assoc_name}_id", assoc_name.to_s.pluralize] if assoc_type == :belongs_to
          end
        end
      end
    end
  end

  def get_model_names
    Dir.chdir(File.join("#{Rails.root}/app/models")) do
      models = Dir["**/*.rb"]
    end
  end

end