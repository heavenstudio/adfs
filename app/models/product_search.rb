class ProductSearch
  attr_accessor :search, :active_filters, :active_filters_options, :selected_filters

  def initialize(query, selected_filters, available_filters)
    # selected filter and options by user input
    @selected_filters = selected_filters || {}
    # available filters found in the database
    @available_filters = available_filters
    # Text query made by user input
    @query = query
    # SunspotSearch instance
    execute_search(@available_filters)
  end

  def execute_search(available_filters)
    # extracted filters that match selected user filters
    active_filters = {}
    # extracted filter options that match the selected user options
    active_filters_options = {}

    @search = Sunspot.search(Product) do
      # do a full text search on @query if present
      keywords @query if @query.present?
      dynamic :filters do
        # loop each selected filter, find selected options for each one and store
        # which filters and options were selected
        selected_filters.each do |field_name, selected_options|
          next if selected_options.blank? || selected_options == ['']
          cleansed_selected_options = selected_options.select(&:present?)
          # Filter results according to selected options
          active_filters[field_name] = with(field_name, cleansed_selected_options)
          active_filters_options[field_name] = cleansed_selected_options.select(&:present?)
        end

        # Ask sunspot to aggregate results according to facets
        # we also exclude the filtered facet query from its correspoding filter, so that it may
        # show other options besides the ones currently selected for any given filter
        # this allows the user to expand the search back for more results
        available_filters.each do |filter|
          facet filter.field_name, exclude: active_filters[filter.field_name]
        end
      end
    end
    @active_filters = active_filters
    @active_filters_options = active_filters_options
  end
end
