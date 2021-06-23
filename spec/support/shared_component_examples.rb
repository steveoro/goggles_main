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
shared_examples_for 'a Meeting detail page rendering the meeting description text' do
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
shared_examples_for 'a Meeting detail page rendering the collapsed \'more\' details' do
  let(:parsed_node) { Nokogiri::HTML.fragment(subject) }

  it 'includes the meeting details boolean flags' do
    expect(parsed_node.at_css('td#warm-up-pool')).to be_present
    expect(parsed_node.at_css('td#allows-under25')).to be_present
    expect(parsed_node.at_css('td#confirmed')).to be_present
  end
  it 'includes various contact information' do
    expect(parsed_node.at_css('td#contact-name')).to be_present
  end
end

# REQUIRES/ASSUMES:
# - subject.......: result from #render_inline (renders a Nokogiri::HTML.fragment)
# - fixture_row...: a Meeting instance
shared_examples_for 'a Meeting detail page rendering main \'header\' details' do
  let(:parsed_node) { Nokogiri::HTML.fragment(subject) }

  it 'shows the swimming pool name, when set' do
    if fixture_row.swimming_pools.count.positive?
      expect(parsed_node.at_css('td#swimming-pool')).to be_present
      expect(parsed_node.at_css('td#swimming-pool').text).to include(
        ERB::Util.html_escape(fixture_row.swimming_pools.first.name)
      )
    end
  end

  it 'shows the entry deadline' do
    expect(parsed_node.at_css('td#entry-deadline')).to be_present
    expect(parsed_node.at_css('td#entry-deadline').text).to include(fixture_row.entry_deadline.to_s)
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
