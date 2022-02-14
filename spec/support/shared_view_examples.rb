# frozen_string_literal: true

# REQUIRES/ASSUMES:
# - parsed_node...: the Nokogiri::HTML::DocumentFragment object from the rendered view
shared_examples_for 'AbstractMeeting rendered /index view' do
  it 'includes the link to go back to the dashboard' do
    expect(parsed_node.at_css('#back-to-dashboard a')).to be_present
    expect(parsed_node.at_css('#back-to-dashboard a').attributes['href'].value).to eq(home_dashboard_path)
  end

  it 'includes the datagrid section with the filtering form' do
    expect(parsed_node.at_css('section#data-grid form')).to be_present
  end

  it 'includes the datagrid filtering show button' do
    expect(parsed_node.at_css('section#data-grid #filter-show-btn button')).to be_present
  end

  it 'includes the pagination at the top' do
    expect(parsed_node.at_css('section#data-grid #pagination-top')).to be_present
  end

  it 'includes the datagrid table' do
    expect(parsed_node.at_css('section#data-grid table')).to be_present
  end

  it 'includes the pagination at the bottom' do
    expect(parsed_node.at_css('section#data-grid #pagination-bottom')).to be_present
  end
end
#-- ---------------------------------------------------------------------------
#++

# REQUIRES/ASSUMES:
# - parsed_node....: the Nokogiri::HTML::DocumentFragment object from the rendered view
# - current_user...: the current_user instance variable
shared_examples_for '/home/dashboard rendered view' do
  it 'includes the dashboard buttons section' do
    expect(parsed_node.at_css('section#dashboard-btns')).to be_present
  end

  it "includes the 'my past meetings' link" do
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-past-meetings')).to be_present
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-past-meetings').attributes['href'].value).to eq(meetings_path)
  end

  xit "includes the 'my future meetings' link" do
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-future-meetings')).to be_present
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-future-meetings').attributes['href'].value).to eq('')
  end

  it "includes the 'my workshops' link" do
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-workshops')).to be_present
    expect(parsed_node.at_css('#dashboard-btns a#btn-my-workshops').attributes['href'].value).to eq(user_workshops_path)
  end
end
#-- ---------------------------------------------------------------------------
#++
