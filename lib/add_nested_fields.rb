module AddNestedFields
  module ViewHelper

    def add_nested_fields_for(form_builder, field, dom_id, *args)
      options = {
        :partial => field.to_s.singularize,
        :label => "Add #{field.to_s.singularize.titleize}",
        :object => field.to_s.classify.constantize.new
      }.merge(args.extract_options!)

      link_to_function("#{options[:label]}") do |page|
        form_builder.fields_for field, options[:object] , :child_index => 'NEW_RECORD' do |f|
          local_name = options[:local] || :f
          html = render(:partial => options[:partial], :locals => { local_name => f })
          page << "$('##{dom_id}').append('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, new Date().getTime()));"
        end
      end
    end

    def remove_nested_fields_for(form_builder, class_id, *args)
      options = {
        :label => 'remove'
      }.merge(args.extract_options!)
      confirm = "if (confirm('Are you sure you would like to delete this #{form_builder.object.class.to_s.underscore.humanize.downcase}?'))"
      if form_builder.object.new_record?
        link_to_function(options[:label]) do |page|
          page << "#{confirm} $(this).closest('.#{class_id}').remove()"
        end
      else
        form_builder.hidden_field( :_delete, :value => "0") + link_to_function(options[:label]) do |page|
          page << "#{confirm} $(this).closest('.#{class_id}').hide();$(this).prev().get(0).value = 1;"
        end
      end
    end

  end
end
ActionView::Base.send(:include, AddNestedFields::ViewHelper)
