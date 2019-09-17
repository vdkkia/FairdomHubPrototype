module Seek
  module Filtering
    FilteredCollection = Struct.new(:collection, :active_filters)

    APPLICABLE_FILTERS = {
        Assay: %i[project programme contributor creator assay_class tag]
    }.freeze

    FILTERS = {
        project: {
            field: 'projects.id',
            title_field: 'projects.title',
            joins: [:projects],
            title_method: :title,
            value_method: :id
        },
        programme: {
            field: 'programmes.id',
            title_field: 'programmes.title',
            joins: [:programmes],
            title_method: :title,
            value_method: :id
        },
        contributor: {
            field: 'people.id',
            title_field: 'concat(people.first_name, " ", people.last_name)',
            includes: [:contributor],
            title_method: :title,
            value_method: :id
        },
        creator: {
            field: 'assets_creators.creator_id',
            title_field: 'concat(people.first_name, " ", people.last_name)',
            joins: [:creators],
            title_method: :title,
            value_method: :id
        },
        assay_class: {
            field: 'assay_classes.id',
            title_field: 'assay_classes.title',
            joins: [:assay_class],
            title_method: :title,
            value_method: :id
        },
        assay_type: {
            field: 'assay_type_uri',
            title_method: :to_s,
            value_method: :to_s
        },
        technology_type: {
            field: 'technology_type_uri',
            title_method: :to_s,
            value_method: :to_s
        },
        tag: {
            field: 'text_values.id',
            title_field: 'text_values.text',
            joins: [:tags_as_text],
            title_method: :text,
            value_method: :id
        }
    }.freeze

    def self.filter(collection, filters)
      filtered_collection = collection
      active_filters = {}

      filters.each do |key, value|
        filter = FILTERS[key.to_sym]
        if filter
          filtered_collection = apply_filter(filtered_collection, filter, value)
          active_filters[key.to_sym] = value
        end
      end

      FilteredCollection.new(filtered_collection, active_filters)
    end

    def self.available_filters(collection)
      return {} if collection.empty?

      available_filters = {}
      type = collection.first.class.name.to_sym
      (APPLICABLE_FILTERS[type] || {}).each do |name|
        filter = FILTERS[name]
        available_filters[name] = available_filter_values(collection, filter).map do |value, count, title|
          [title || 'Untitled', value.to_s, count]
        end
      end

      available_filters
    end

    def self.apply_filter(collection, filter, value)
      collection = collection.joins(filter[:joins]) if filter[:joins]
      collection = collection.includes(filter[:includes]) if filter[:includes]
      collection.where(filter[:field] => value)
    end

    def self.available_filter_values(collection, filter)
      select = [filter[:field], "COUNT(#{filter[:field]})", filter[:title_field]].compact.map { |f| Arel.sql(f) }
      collection = collection.select(*select)
      collection = collection.joins(filter[:joins]) if filter[:joins]
      collection = collection.includes(filter[:includes]) if filter[:includes]
      collection.group(filter[:field]).pluck(*select)
    end
  end
end