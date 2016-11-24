require 'query'
module RedmineOrFilter
  module QueryPatch
    unloadable

    def self.included(base)
      base.extend(ClassMethods) 
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :available_filters, :or_filters
        alias_method_chain :statement, :or_filters
      end
    end
    
    module ClassMethods
    end
    
    module  InstanceMethods     
      def available_filters_with_or_filters
        return @available_filters if @available_filters
        available_filters_without_or_filters
        @available_filters["and_any"] = {
            :name => "Any follow (AND)",
            :type => :list,
            :values => ["Yes"],
            :order =>  @available_filters.size + 1
        }
        
        @available_filters["or_any"] = {
            :name => "Any follow (OR)",
            :type => :list,
            :values => ["Yes"],
            :order =>  @available_filters.size + 1
        }
        @available_filters["or_all"] = {
            :name => "All follow (OR)",
            :type => :list,
            :values => ["Yes"],
            :order =>  @available_filters.size + 1
        }
        @available_filters

      end
          
      def statement_with_or_filters           
        filters_clauses=[]
        and_clauses=[]
        and_any_clauses=[]
        or_any_clauses=[]
        or_all_clauses=[]
        and_any_op = ""
        or_any_op = ""
        or_all_op = ""
        
        #the AND filter start first
        filters_clauses = and_clauses    
            
        filters.each_key do |field|
          next if field == "subproject_id"        
          if field == "and_any"
             #start the and any part, point filters_clause to and_any_clauses		 
             filters_clauses = and_any_clauses
             and_any_op = operator_for(field) == "=" ? " AND " : " AND NOT "
             next
          elsif field == "or_any"
             #start the or any part, point filters_clause to or_any_clauses		 
             filters_clauses = or_any_clauses
             or_any_op = operator_for(field) == "=" ? " OR " : " OR NOT "
             next
          elsif  field == "or_all"  
             #start the or any part, point filters_clause to or_any_clauses		 
             filters_clauses = or_all_clauses
             or_all_op = operator_for(field) == "=" ? " OR " : " OR NOT "
             next
          end

          v = values_for(field).clone
          next unless v and !v.empty?
          operator = operator_for(field)

          # "me" value substitution
          if %w(assigned_to_id author_id user_id watcher_id).include?(field)
            if v.delete("me")
              if User.current.logged?
                v.push(User.current.id.to_s)
                v += User.current.group_ids.map(&:to_s) if field == 'assigned_to_id'
              else
                v.push("0")
              end
            end
          end

          if field == 'project_id'
            if v.delete('mine')
              v += User.current.memberships.map(&:project_id).map(&:to_s)
            end
          end
         
          if field =~ /cf_(\d+)$/
            # custom field
             filters_clauses << sql_for_custom_field(field, operator, v, $1)
          elsif respond_to?("sql_for_#{field}_field")
            # specific statement
             filters_clauses << send("sql_for_#{field}_field", field, operator, v)
          else
            # regular field
             filters_clauses << '(' + sql_for_field(field, operator, v, queried_table_name, field) + ')'
          end
        end if filters and valid?
        
        if (c = group_by_column) && c.is_a?(QueryCustomFieldColumn)
          # Excludes results for which the grouped custom field is not visible
          filters_clauses << c.custom_field.visibility_by_project_condition
        end

        
        #now start build the full statement, project filter is allways AND
        and_clauses.reject!(&:blank?)
        and_statement = and_clauses.any? ? and_clauses.join(" AND ") : nil
                   
        all_and_statement = ["#{project_statement}", "#{and_statement}"].reject(&:blank?)     
        all_and_statement = all_and_statement.any? ? all_and_statement.join(" AND ") : nil  
        
           
        # finish the traditional part. Now extended part
        # add the and_any first
        and_any_clauses.reject!(&:blank?)       
        and_any_statement = and_any_clauses.any? ? "("+ and_any_clauses.join(" OR ") +")" : nil
              
        full_statement_ext_1 = ["#{all_and_statement}", "#{and_any_statement}"].reject(&:blank?)     
        full_statement_ext_1 = full_statement_ext_1.any? ? full_statement_ext_1.join(and_any_op) : nil

        # then add the or_all
        or_all_clauses.reject!(&:blank?)
        or_all_statement = or_all_clauses.any? ? "("+ or_all_clauses.join(" AND ") +")" : nil
        
        full_statement_ext_2 = ["#{full_statement_ext_1}", "#{or_all_statement}"].reject(&:blank?)
        full_statement_ext_2 = full_statement_ext_2.any? ? full_statement_ext_2.join(or_all_op) : nil
         
        # then add the or_any
        or_any_clauses.reject!(&:blank?)
        or_any_statement = or_any_clauses.any? ? "("+ or_any_clauses.join(" OR ") +")" : nil
        
        full_statement = ["#{full_statement_ext_2}", "#{or_any_statement}"].reject(&:blank?)
        full_statement = full_statement.any? ? full_statement.join(or_any_op) : nil
        
        Rails.logger.info "STATEMENT #{full_statement}"
        
        return full_statement

      end #def statement
    end # InstanceMethods
  end
end


unless Query.included_modules.include? RedmineOrFilter::QueryPatch
    Query.send(:include, RedmineOrFilter::QueryPatch)
end
