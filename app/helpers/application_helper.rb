module ApplicationHelper
  # find a corresponding field_type from its name
  def filter(field_name)
    if Filter.where(field_name: field_name).exists?
      Filter.find_by(field_name: field_name)
    else
      nil
    end
  end
end
