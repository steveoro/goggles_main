# frozen_string_literal: true

# REQUIRES/ASSUMES:
# - ranking_num.......: storing the subject's ranking position to be rendered
# - rendered_result...: storing the rendered text to be checked
shared_examples_for 'RankingPosComponent rendering a ranking position' do |ranking_num|
  it 'renders a UNICODE medal for rank 1..3 or just the ranking number for any other value' do
    case ranking_num
    when 1
      expect(rendered_result).to include('🥇') if ranking_num == 1
    when 2
      expect(rendered_result).to include('🥈') if ranking_num == 2
    when 3
      expect(rendered_result).to include('🥉') if ranking_num == 3
    else
      expect(rendered_result).to include(ranking_num.to_s) unless [1, 2, 3].member?(ranking_num)
    end
  end
end
#-- ---------------------------------------------------------------------------
#++

# == Generic ==
# REQUIRES/ASSUMES:
# - subject...........: any call that returns rendered HTML text (as in render or Nokogiri::HTML.fragment.to_html)
shared_examples_for 'any subject that renders nothing' do
  it 'doesn\'t raise errors' do
    expect { subject }.not_to raise_error
  end
  it 'renders nothing' do
    expect(subject).to be_empty
  end
end

# REQUIRES/ASSUMES:
# - subject.......: result from #render_inline (renders a Nokogiri::HTML.fragment)
shared_examples_for 'any subject that renders the \'cancelled\' stamp' do
  it 'shows the cancelled text stamp' do
    expect(subject.css('.cancelled')).to be_present
    expect(subject.css('.cancelled').text).to eq(I18n.t('activerecord.attributes.goggles_db/meeting.cancelled'))
  end
end
#-- ---------------------------------------------------------------------------
#++

# == Meeting components / dashboard view ==
# SUPPORTS: both views & components
#
# REQUIRES/ASSUMES:
# - subject.......: either, the result from #render_inline (renders a Nokogiri::HTML.fragment),
#                   or the rendered HTML (from calling render on a view)
# - fixture_row...: a Meeting instance
shared_examples_for 'an AbstractMeeting detail page rendering the meeting description text' do
  let(:parsed_node) { Nokogiri::HTML.fragment(subject) }

  it 'shows the description with its edition label' do
    expect(parsed_node).to be_present
    expect(parsed_node.text).to include(fixture_row.description).and include(fixture_row.edition_label)
  end
end

# REQUIRES/ASSUMES:
# - subject.......: either, the result from #render_inline (renders a Nokogiri::HTML.fragment),
#                   or the rendered HTML (from calling render on a view)
# - fixture_row...: a Meeting instance
shared_examples_for 'an AbstractMeeting detail page rendering the collapsed \'more\' details' do
  let(:parsed_node) { Nokogiri::HTML.fragment(subject) }

  it 'includes the meeting details boolean flags' do
    if fixture_row.instance_of?(GogglesDb::Meeting)
      expect(parsed_node.at_css('td#warm-up-pool')).to be_present
      expect(parsed_node.at_css('td#allows-under25')).to be_present
    end
    expect(parsed_node.at_css('td#confirmed')).to be_present
  end
  it 'includes various contact information (for meetings only, when set)' do
    if fixture_row.instance_of?(GogglesDb::Meeting)
      expect(
        parsed_node.at_css('td#contact-name')
      ).to be_present
    end
  end
  it 'includes the home/organizing team info (when set)' do
    if (fixture_row.respond_to?(:home_team) && fixture_row.home_team) ||
       (fixture_row.respond_to?(:team) && fixture_row.team)
      expect(parsed_node.at_css('td#home-team')).to be_present
    end
  end
end

# REQUIRES/ASSUMES:
# - subject.......: result from #render_inline (renders a Nokogiri::HTML.fragment)
# - fixture_row...: an AbstractMeeting instance
shared_examples_for 'an AbstractMeeting detail page rendering main \'header\' details' do
  let(:parsed_node) { Nokogiri::HTML.fragment(subject) }

  it 'shows the swimming pool name, when set' do
    if (fixture_row.respond_to?(:swimming_pools) && fixture_row.swimming_pools.count.positive?) ||
       (fixture_row.respond_to?(:swimming_pool) && fixture_row.swimming_pool.present?)
      expect(parsed_node.at_css('td#swimming-pool')).to be_present
      expect(parsed_node.at_css('td#swimming-pool').text).to include(
        ERB::Util.html_escape(fixture_row.swimming_pools.first.name)
      )
    end
  end

  it 'shows the entry deadline' do
    if fixture_row.respond_to?(:entry_deadline)
      expect(parsed_node.at_css('td#entry-deadline')).to be_present
      expect(parsed_node.at_css('td#entry-deadline').text).to include(fixture_row.entry_deadline.to_s)
    end
  end
  it 'shows the meeting date' do
    expect(parsed_node.at_css('td#header-date')).to be_present
  end
  it 'includes the rotating toggle switch to show the collapsed details sub-page' do
    expect(parsed_node.at_css('.rotating-toggle')).to be_present
  end
end
#-- ---------------------------------------------------------------------------
#++

# REQUIRES/ASSUMES:
# - subject............: result from #render_inline (renders a Nokogiri::HTML.fragment)
# - wrapper_class......: CSS class name for the wrapper DIV of the component
# - free_text_option...: 'true' to enable the free-text input
# - base_name..........: API/widget base name
# - label_text.........: display label for the widget
# - required_option....: 'true' to enable the required HTML attribute for the select input tag
shared_examples_for 'ComboBox::DbLookupComponent common rendered result' do
  describe 'the wrapper DIV' do
    it 'has the customizable wrapper class' do
      expect(subject.css("div.#{wrapper_class}")).to be_present
    end
    it 'includes the reference to the StimulusJS LookupController' do
      expect(subject.css("div.#{wrapper_class}").attr('data-controller')).to be_present
      expect(subject.css("div.#{wrapper_class}").attr('data-controller').value).to eq('lookup')
    end
    it "sets the 'free-text' controller option accordingly (when set)" do
      if free_text_option
        expect(subject.css("div.#{wrapper_class}").attr('data-lookup-free-text-value'))
          .to be_present
        expect(subject.css("div.#{wrapper_class}").attr('data-lookup-free-text-value').value)
          .to eq(free_text_option)
      end
    end
    it "sets the 'base name' controller option" do
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-field-base-name-value'))
        .to be_present
      expect(subject.css("div.#{wrapper_class}").attr('data-lookup-field-base-name-value').value)
        .to eq(base_name)
    end
  end

  it 'renders the hidden ID input field' do
    expect(subject.css("div.#{wrapper_class} input##{base_name}_id")).to be_present
    expect(subject.css("div.#{wrapper_class} input##{base_name}_id").attr('type').value)
      .to eq('hidden')
  end
  it 'renders the hidden label input field (the text value of the currently chosen option)' do
    expect(subject.css("div.#{wrapper_class} input##{base_name}_label")).to be_present
    expect(subject.css("div.#{wrapper_class} input##{base_name}_label").attr('type').value)
      .to eq('hidden')
  end
  it 'renders the display label text' do
    expect(subject.css("div.#{wrapper_class} label[for=\"#{base_name}\"]")).to be_present
    expect(subject.css("div.#{wrapper_class} label[for=\"#{base_name}\"]").text).to eq(label_text)
  end

  it "renders the 'input presence' flag (which is red by default)" do
    expect(subject.css("div.#{wrapper_class} b##{base_name}-presence")).to be_present
    expect(subject.css("div.#{wrapper_class} b##{base_name}-presence").text).to eq('*')
    expect(subject.css("div.#{wrapper_class} b##{base_name}-presence").attr('class').value).to eq('text-danger')
  end

  it 'renders the Select input tag with the proper parameters for the LookupController' do
    expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select")).to be_present
    expect(subject.css("div.#{wrapper_class} select.select2##{base_name}_select").attr('data-lookup-target').value)
      .to eq('field')
  end

  it "sets the 'required' HTML field flag accordingly (when set)" do
    if required_option
      expect(subject.css("##{base_name}_select").attr('required')).to be_present
      expect(subject.css("##{base_name}_select").attr('required').value).to eq(required_option)
    end
  end
end

# REQUIRES/ASSUMES:
# - subject............: result from #render_inline (renders a Nokogiri::HTML.fragment)
# - api_url............: base API URL option ('use_2_api: true' assumed also as set)
# - wrapper_class......: CSS class name for the wrapper DIV of the component
# - free_text_option...: 'true' to enable the free-text input
# - base_name..........: API/widget base name
# - label_text.........: display label for the widget
# - required_option....: 'true' to enable the required HTML attribute for the select input tag
shared_examples_for 'ComboBox::DbLookupComponent with double-API call enabled' do
  it_behaves_like('ComboBox::DbLookupComponent common rendered result')

  it 'includes the associated API URL value' do
    expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url-value')).to be_present
    # The actual API URL used will feature the full protocol/port URI, so we test for inclusion only:
    expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url-value').value).to include(api_url)
  end
  it 'includes the associated API-2 URL value' do
    expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url2-value')).to be_present
    expect(subject.css("div.#{wrapper_class}").attr('data-lookup-api-url2-value').value)
      .to end_with('/api/v3') # The API URL2 must be "rooted"
  end
end
#-- ---------------------------------------------------------------------------
#++
