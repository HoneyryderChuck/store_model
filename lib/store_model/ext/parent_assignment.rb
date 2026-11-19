# frozen_string_literal: true

module StoreModel
  # Helper methods for ActiveModel and ActiveRecord parent tracking support
  module ParentAssignment
    private

    # Runs on every attribute read and write, so collections are checked one level deep only:
    # walking nested plain JSON on each read costs time proportional to the whole value.
    def assign_parent_to_store_model_relation(attribute)
      case attribute
      when StoreModel::Model
        assign_parent_to_store_model(attribute)
      when Array
        attribute.each { |item| assign_parent_to_store_model(item) } if attribute.first.is_a?(StoreModel::Model)
      when Hash
        attribute.each_value { |item| assign_parent_to_store_model(item) if item.is_a?(StoreModel::Model) }
      end
    end

    def assign_parent_to_store_model(model)
      return if model.frozen? || declares_parent_attribute?(model)

      model.parent = self
    end

    # A declared `parent` attribute replaces the accessor, so assigning the owner would overwrite its value.
    def declares_parent_attribute?(model)
      model.class.attribute_types.key?("parent")
    end
  end
end
