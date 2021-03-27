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
# - subject...........: any call that renders HTML text
shared_examples_for 'any subject that renders nothing' do
  it 'doesn\'t raise errors' do
    expect { subject }.not_to raise_error
  end
  it 'renders nothing' do
    expect(subject).to be_empty
  end
end

# REQUIRES/ASSUMES:
# - subject...........: any call that renders HTML text
shared_examples_for 'any subject that renders the \'cancelled\' stamp' do
  it 'shows the cancelled text stamp' do
    node = Nokogiri::HTML.fragment(subject).css('.cancelled')
    expect(node).to be_present
    expect(node.text).to eq(I18n.t('activerecord.attributes.goggles_db/meeting.cancelled'))
  end
end
#-- ---------------------------------------------------------------------------
#++

# == Meeting components / dashboard view ==
# REQUIRES/ASSUMES:
# - subject.......: any call that renders HTML text
# - fixture_row...: a Meeting instance
shared_examples_for 'a Meeting detail page rendering the meeting description text' do
  it 'shows the description with its edition label' do
    node = Nokogiri::HTML.fragment(subject)
    expect(node).to be_present
    expect(node.text).to include(fixture_row.description).and include(fixture_row.edition_label)
  end
end

# REQUIRES/ASSUMES:
# - subject.......: any call that renders HTML text
# - fixture_row...: a Meeting instance
shared_examples_for 'a Meeting detail page rendering the collapsed \'more\' details' do
  it 'includes the meeting details boolean flags' do
    expect(Nokogiri::HTML.fragment(subject).at_css('td#warm-up-pool')).to be_present
    expect(Nokogiri::HTML.fragment(subject).at_css('td#allows-under25')).to be_present
    expect(Nokogiri::HTML.fragment(subject).at_css('td#confirmed')).to be_present
  end
  it 'includes various contact information' do
    expect(Nokogiri::HTML.fragment(subject).at_css('td#contact-name')).to be_present
  end
end

# REQUIRES/ASSUMES:
# - subject.......: any call that renders HTML text
# - fixture_row...: a Meeting instance
shared_examples_for 'a Meeting detail page rendering main \'header\' details' do
  it 'shows the swimming pool name, when set' do
    return true unless fixture_row.swimming_pools.count.positive?

    node = Nokogiri::HTML.fragment(subject).at_css('td#swimming-pool')
    expect(node).to be_present
    expect(node.text).to include(
      ERB::Util.html_escape(fixture_row.swimming_pools.first.name)
    )
  end

  it 'shows the entry deadline' do
    node = Nokogiri::HTML.fragment(subject).at_css('td#entry-deadline')
    expect(node).to be_present
    expect(node.text).to include(fixture_row.entry_deadline.to_s)
  end
  it 'shows the meeting date' do
    node = Nokogiri::HTML.fragment(subject).at_css('td#header-date')
    expect(node).to be_present
  end
  it 'includes the rotating toggle switch to show the collapsed details sub-page' do
    node = Nokogiri::HTML.fragment(subject).at_css('.rotating-toggle')
    expect(node).to be_present
  end
end
#-- ---------------------------------------------------------------------------
#++
