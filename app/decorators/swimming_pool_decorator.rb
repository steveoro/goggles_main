# frozen_string_literal: true

# = SwimmingPoolDecorator
#
class SwimmingPoolDecorator < Draper::Decorator
  delegate_all

  # Add explicit delegation also for methods added to the AR::Relation by Kaminari
  delegate :current_page, :total_pages, :limit_value, :total_count, :offset_value, :last_page?

  # Returns the default text label describing this object.
  def text_label
    decorated.short_label
  end

  # Returns the link to #show using the name as link label.
  #
  def link_to_full_name
    h.link_to(decorated.short_label, h.swimming_pool_show_path(id: object.id))
  end

  # Returns either the styled button link to the Google Maps pool location together with
  # its name or just its plain text name if no location query fields are available.
  #
  # == Location query strategy:
  # - Default.......: use "Plus code" for coordinate
  # - Fallback #1...: use maps_uri
  # - Fallback #2...: use latitude & longitude (no plus_code or maps_uri available)
  # - Fallback #3...: make a search link based on swimming pool name, city name and/or address (no coordinates at all)
  # - Fallback #4...: plain text name (no link when no city or no coordinates or no address are given)
  #
  # @see https://maps.google.com/pluscodes/
  #
  def link_to_maps_or_name
    if plus_code.present?
      link_tag_for_maps(plus_code_uri)

    elsif maps_uri.present?
      link_tag_for_maps(maps_uri)

    elsif latitude.present? && longitude.present?
      link_tag_for_maps(lat_long_search_uri)

    elsif city.present? || address.present?
      link_tag_for_maps(address_search_uri)

    else
      decorated.short_label
    end
  end

  private

  # Returns the decorated base object instance, memoized.
  def decorated
    @decorated ||= object.decorate
  end

  # Returns the actual link tag to the specified URI using a maps icon with the pool name
  # == Params
  # - uri_text: the string URI for the link
  def link_tag_for_maps(uri_text)
    h.link_to(uri_text, { class: 'btn btn-sm btn-outline-secondary' }) do
      "#{h.content_tag(:i, '', class: 'fa fa-map-marker')}" \
      " #{h.content_tag(:span, "&nbsp;#{name}".html_safe)}".html_safe
    end
  end

  # Returns the URI for Google Maps using the "plus codes" syntax
  def plus_code_uri
    "https://plus.codes/#{plus_code}"
  end

  # Returns the URI for Google Maps using the "search by latitude & longitude" syntax
  def lat_long_search_uri
    # [Steve A.] Do not use latitude & longitude on cities because these are usually pretty
    # generic and pointing to the center of the city itself, not a specific pool or venue.
    "https://www.google.com/maps?q=#{latitude},#{longitude}"
  end

  # Returns the URI for Google Maps using the "search by place name" syntax
  def address_search_uri
    full_address = [
      I18n.t('swimming_pools.pool'), name, address, city&.name
    ].compact
    full_address.delete('')
    "https://www.google.com/maps?q=#{full_address.join('+').gsub(' ', '+')}"
  end
end
