# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Title::BreadCrumbLinkComponent, type: :component do
  let(:title) { FFaker::CheesyLingo.title }
  let(:css_icon) { %w[bug calendar bed bath bell-o car cogs crosshairs].sample }
  let(:title_link) { FFaker::Internet.http_url }
  let(:parent_title) { FFaker::CheesyLingo.title }
  let(:parent_link) { FFaker::Internet.http_url }

  shared_examples_for('BreadCrumbLinkComponent common rendered properties') do
    it 'renders the \'back-to-parent\' link with the parent title in it' do
      expect(subject.at('a#back-to-parent')).to be_present
      expect(subject.at('a#back-to-parent').attributes['href'].value).to eq(parent_link)
      expect(subject.at('a#back-to-parent').text).to include(parent_title)
    end

    it 'renders the CSS icon' do
      expect(subject.at("h4 span i.fa.fa-#{css_icon}")).to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when all parameters are present,' do
    subject do
      render_inline(
        described_class.new(
          title:, css_icon:, title_link:, # (optional)
          parent_title:, parent_link:
        )
      )
    end

    it_behaves_like('BreadCrumbLinkComponent common rendered properties')

    it 'renders the title link with the title text in it' do
      expect(subject.at('a#title-link')).to be_present
      expect(subject.at('a#title-link').attributes['href'].value).to eq(title_link)
      expect(subject.at('a#title-link').text).to include(title)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'without the optional title_link parameter,' do
    subject do
      render_inline(
        described_class.new(
          title:, css_icon:,
          parent_title:, parent_link:
        )
      )
    end

    it_behaves_like('BreadCrumbLinkComponent common rendered properties')

    it 'renders just the title without the link' do
      expect(subject.at('span#curr-title')).to be_present
      expect(subject.at('span#curr-title').text).to include(title)
      expect(subject.at('a#title-link')).not_to be_present
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
