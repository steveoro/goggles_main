# frozen_string_literal: true

Given('maintenance mode is {string}') do |toggle_flag|
  GogglesDb::AppParameter.maintenance = toggle_flag == 'on'
end

Then('I can see the maintenance page') do
  container_node = find('.maintenance', visible: true)
  within(container_node) do
    expect(find('img')[:src]).to include('goggles_blue_128')
    expect(find('h1').text).to include('Goggles')
    expect(find('h2').text).to include(ERB::Util.html_escape(I18n.t('maintenance.title')))
    expect(find('p.centered-greet').text).to include(
      ERB::Util.html_escape(I18n.t('maintenance.see_u_soon'))
    )
  end
end
