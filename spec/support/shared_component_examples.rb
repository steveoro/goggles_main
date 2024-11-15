# frozen_string_literal: true

# REQUIRES/ASSUMES:
# - ranking_num.......: storing the subject's ranking position to be rendered
# - rendered_result...: storing the rendered text to be checked
shared_examples_for 'RankingPosComponent rendering a ranking position' do |ranking_num|
  it 'renders a UNICODE medal for rank 0..3 or just the ranking number for any other value' do
    case ranking_num
    when 0..3
      expect(rendered_result).to include(%w[➖ 🥇 🥈 🥉][ranking_num])
    else
      expect(rendered_result).to include(ranking_num.to_s)
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
shared_examples_for 'an AbstractMeeting detail page rendering the meeting condensed_name text' do
  let(:parsed_node) { Nokogiri::HTML.fragment(subject) }

  it 'shows the description with its edition label' do
    expect(parsed_node).to be_present
    expect(parsed_node.text)
      .to include(fixture_row.decorate.display_label)
      .and include(fixture_row.edition_label)
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
# - subject.......: result from #render_inline pr #render (renders a Nokogiri::HTML.fragment)
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
# - required_option....: 'true' to enable the 'required' HTML attribute for the select input tag
# - disabled_option....: 'true' to enable the 'disabled' HTML attribute for the select input tag
shared_examples_for 'ComboBox::DbLookupComponent common rendered result' do
  describe 'the wrapper DIV' do
    it 'has the customizable wrapper class' do
      expect(subject.css(".#{wrapper_class}")).to be_present
    end

    it 'includes the reference to the StimulusJS LookupController' do
      expect(subject.css(".#{wrapper_class}").attr('data-controller')).to be_present
      expect(subject.css(".#{wrapper_class}").attr('data-controller').value).to eq('lookup')
    end

    it "sets the 'free-text' controller option accordingly (when set)" do
      if free_text_option
        expect(subject.css(".#{wrapper_class}").attr('data-lookup-free-text-value'))
          .to be_present
        expect(subject.css(".#{wrapper_class}").attr('data-lookup-free-text-value').value)
          .to eq(free_text_option)
      end
    end

    it "sets the 'base name' controller option" do
      expect(subject.css(".#{wrapper_class}").attr('data-lookup-field-base-name-value'))
        .to be_present
      expect(subject.css(".#{wrapper_class}").attr('data-lookup-field-base-name-value').value)
        .to eq(base_name)
    end
  end

  it 'renders the hidden ID input field' do
    expect(subject.css(".#{wrapper_class} input##{base_name}_id")).to be_present
    expect(subject.css(".#{wrapper_class} input##{base_name}_id").attr('type').value)
      .to eq('hidden')
  end

  it 'renders the hidden label input field (the text value of the currently chosen option)' do
    expect(subject.css(".#{wrapper_class} input##{base_name}_label")).to be_present
    expect(subject.css(".#{wrapper_class} input##{base_name}_label").attr('type').value)
      .to eq('hidden')
  end

  it 'renders the display label text' do
    expect(subject.css(".#{wrapper_class} label[for=\"#{base_name}\"]")).to be_present
    expect(subject.css(".#{wrapper_class} label[for=\"#{base_name}\"]").text).to eq(label_text)
  end

  it "renders the 'input presence' flag (which is red by default)" do
    expect(subject.css(".#{wrapper_class} b##{base_name}-presence")).to be_present
    expect(subject.css(".#{wrapper_class} b##{base_name}-presence").text).to eq('*')
    expect(subject.css(".#{wrapper_class} b##{base_name}-presence").attr('class').value).to eq('text-danger')
  end

  it "renders the 'new input' flag (which is hidden by default)" do
    expect(subject.css(".#{wrapper_class} ##{base_name}-new")).to be_present
    expect(subject.css(".#{wrapper_class} ##{base_name}-new").text).to be_present
    expect(subject.css(".#{wrapper_class} ##{base_name}-new").attr('class').value).to include('d-none')
  end

  it 'renders the Select input tag with the proper parameters for the LookupController' do
    expect(subject.css(".#{wrapper_class} select.select2##{base_name}_select")).to be_present
    expect(subject.css(".#{wrapper_class} select.select2##{base_name}_select").attr('data-lookup-target').value)
      .to eq('field')
  end

  it "sets the 'required' HTML field flag accordingly (when set)" do
    if required_option
      expect(subject.css("##{base_name}_select").attr('required')).to be_present
      expect(subject.css("##{base_name}_select").attr('required').value).to eq(required_option)
    end
  end

  it "sets the 'disabled' HTML field flag accordingly (when set)" do
    if disabled_option
      expect(subject.css("##{base_name}_select").attr('disabled')).to be_present
      expect(subject.css("##{base_name}_select").attr('disabled').value).to eq(disabled_option)
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
# - disabled_option....: 'true' to enable the 'disabled' HTML attribute for the select input tag
shared_examples_for 'ComboBox::DbLookupComponent with double-API call enabled' do
  it_behaves_like('ComboBox::DbLookupComponent common rendered result')

  it 'includes the associated API URL value' do
    expect(subject.css(".#{wrapper_class}").attr('data-lookup-api-url-value')).to be_present
    # The actual API URL used will feature the full protocol/port URI, so we test for inclusion only:
    expect(subject.css(".#{wrapper_class}").attr('data-lookup-api-url-value').value).to include(api_url)
  end

  it 'includes the associated API-2 URL value' do
    expect(subject.css(".#{wrapper_class}").attr('data-lookup-api-url2-value')).to be_present
    expect(subject.css(".#{wrapper_class}").attr('data-lookup-api-url2-value').value)
      .to end_with('/api/v3') # The API URL2 must be "rooted"
  end
end
#-- ---------------------------------------------------------------------------
#++

# REQUIRES/ASSUMES:
# - rendered_modal....: the rendered RL edit modal wrapping its edit form contents
shared_examples_for 'RelayLaps::EditModalContentsComponent rendered with some existing laps & sublaps' do
  it 'includes the modal title with the event & gender labels' do
    title_container = rendered_modal.at('h5#lap-edit-modal-title.modal-title')
    expect(title_container.text).to include(I18n.t('laps.modal.form.title')) &&
                                    include(relay_result.event_type.label) &&
                                    include(relay_result.gender_type.label) &&
                                    include(relay_result.category_type.short_name)
  end

  it 'includes the alert msg container' do
    expect(rendered_modal.at('small#lap-modal-alert-text')).to be_present
  end

  it 'renders the modal header row' do
    expect(rendered_modal.at('tr#lap-table-header')).to be_present
  end

  describe 'within the modal header row,' do
    let(:header_row) { rendered_modal.at('tr#lap-table-header') }

    it 'renders the team editable name' do
      expect(header_row.at('h6').text).to include(relay_result.team.editable_name)
    end

    it 'renders the form to add a new relay swimmer with its input controls' do
      expect(header_row.at('#frm-add-mrs-row')).to be_present
      expect(header_row.at('#frm-add-mrs-row input#result_id')).to be_present
      expect(header_row.at('#frm-add-mrs-row input#result_class')).to be_present
      expect(header_row.at('#frm-add-mrs-row select#badge_id')).to be_present
      expect(header_row.at('#frm-add-mrs-row select#length_in_meters')).to be_present
    end

    it 'renders the form submit button to add a new relay swimmer (may be disabled though)' do
      expect(header_row.at('#frm-add-mrs-row #btn-add-mrs-row')).to be_present
    end
  end

  it 'renders the body of the table' do
    expect(rendered_modal.at('tbody#laps-table-body')).to be_present
  end

  # --- MRS edit widgets ---
  describe 'within the modal MRS row table body,' do
    let(:table_body) { rendered_modal.at('tbody#laps-table-body') }

    it 'renders a relay swimmer edit row (with its required hidden fields) for each existing MRS' do
      max_sublaps = relay_result.event_type.phase_length_in_meters / 50
      relay_result.meeting_relay_swimmers.each_with_index do |_mrs, swimmer_index|
        overall_index = (swimmer_index + 1) * max_sublaps # Index relative to all sub-laps (RelayLaps)
        mrs_form_table = table_body.at("form#frm-lap-row-#{overall_index}")
        expect(mrs_form_table).to be_present
        # The form must map to a proper parent result for the edited lap:
        expect(mrs_form_table.at("input#result_id_#{overall_index}")).to be_present
        expect(mrs_form_table.at("input#result_id_#{overall_index}").attr('value')).to eq(relay_result.id.to_s)
        expect(mrs_form_table.at("input#result_class_#{overall_index}")).to be_present
        expect(mrs_form_table.at("input#result_class_#{overall_index}").attr('value')).to eq(relay_result.class.name.split('::').last)
      end
    end

    %w[length_in_meters minutes_from_start seconds_from_start hundredths_from_start].each do |field_name|
      it "allows editing the #{field_name} for each MRS row" do
        max_sublaps = relay_result.event_type.phase_length_in_meters / 50
        relay_result.meeting_relay_swimmers.each_with_index do |mrs, swimmer_index|
          overall_index = (swimmer_index + 1) * max_sublaps # Index relative to all sub-laps (RelayLaps)
          mrs_form_table = table_body.at("form#frm-lap-row-#{overall_index}")
          expect(mrs_form_table.at("input##{field_name}_#{overall_index}")).to be_present
          expect(mrs_form_table.at("input##{field_name}_#{overall_index}").attr('value')).to eq(mrs.send(field_name).to_s) if mrs.send(field_name).present?
        end
      end
    end

    it 'renders the dedicated save & delete buttons (if the MRS is serialized) for each MRS' do
      max_sublaps = relay_result.event_type.phase_length_in_meters / 50
      relay_result.meeting_relay_swimmers.each_with_index do |mrs, swimmer_index|
        overall_index = (swimmer_index + 1) * max_sublaps # Index relative to all sub-laps (RelayLaps)
        expect(table_body.at("#lap-save-row-#{overall_index}")).to be_present
        expect(table_body.at("#lap-delete-row-#{overall_index}")).to be_present if mrs.id.to_i.positive?
      end
    end

    it 'renders the delta timing for each MRS row' do
      max_sublaps = relay_result.event_type.phase_length_in_meters / 50
      relay_result.meeting_relay_swimmers.each_with_index do |mrs, swimmer_index|
        overall_index = (swimmer_index + 1) * max_sublaps # Index relative to all sub-laps (RelayLaps)
        mrs_form_table = table_body.at("form#frm-lap-row-#{overall_index}")
        expect(mrs_form_table.at("span#mrs-delta-#{overall_index}")).to be_present
        expect(mrs_form_table.at("span#mrs-delta-#{overall_index}").text).to include("Δt: #{mrs.to_timing}") if mrs.to_timing.present?
      end
    end
  end

  # --- RelayLaps edit widgets ---
  describe 'within each MRS row group,' do
    let(:table_body) { rendered_modal.at('tbody#laps-table-body') }

    it 'renders a RelayLap edit row (with its required hidden fields) for each existing RelayLap' do
      max_sublaps = relay_result.event_type.phase_length_in_meters / 50
      relay_result.meeting_relay_swimmers.each_with_index do |mrs, swimmer_index|
        mrs.relay_laps.each_with_index do |_relay_lap, sub_index|
          overall_index = (swimmer_index * max_sublaps) + sub_index + 1 # Index relative to all sub-laps (RelayLaps)
          sublap_form = table_body.at("form#frm-sublap-row-#{overall_index}")
          expect(sublap_form).to be_present
          # The form must map to a proper parent result for the edited lap:
          expect(sublap_form.at("input#result_id_#{overall_index}")).to be_present
          expect(sublap_form.at("input#result_id_#{overall_index}").attr('value')).to eq(mrs.id.to_s)
          expect(sublap_form.at("input#result_class_#{overall_index}")).to be_present
          expect(sublap_form.at("input#result_class_#{overall_index}").attr('value')).to eq(mrs.class.name.split('::').last)
        end
      end
    end

    %w[length_in_meters minutes_from_start seconds_from_start hundredths_from_start].each do |field_name|
      it "allows editing the #{field_name} for each RelayLap row" do
        max_sublaps = relay_result.event_type.phase_length_in_meters / 50
        # DEBUG
        # puts "\r\nTotal MRS: #{relay_result.meeting_relay_swimmers.count}"
        relay_result.meeting_relay_swimmers.each_with_index do |mrs, swimmer_index|
          # DEBUG
          # puts "Total RL (swimmer #{swimmer_index}): #{mrs.relay_laps.count}"
          mrs.relay_laps.each_with_index do |relay_lap, sub_index|
            overall_index = (swimmer_index * max_sublaps) + sub_index + 1 # Index relative to all sub-laps (RelayLaps)
            # DEBUG
            # puts "=> processing RL #{overall_index}"
            sublap_form = table_body.at("form#frm-sublap-row-#{overall_index}")
            expect(sublap_form.at("input##{field_name}_#{overall_index}")).to be_present
            if relay_lap.send(field_name).present?
              expect(sublap_form.at("input##{field_name}_#{overall_index}").attr('value')).to eq(relay_lap.send(field_name).to_s)
            end
          end
        end
      end
    end
  end
end
#-- ---------------------------------------------------------------------------
#++
