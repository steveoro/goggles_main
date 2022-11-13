# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grid::RowStarComponent, type: :component do
  include Rails.application.routes.url_helpers

  let(:meeting) { GogglesDb::Meeting.last(50).sample }
  let(:calendar) do
    GogglesDb::Calendar.joins(:meeting).includes(:meeting)
                       .last(50).sample
  end
  let(:user) { GogglesDb::User.first(50).sample }

  before { expect(calendar.meeting).to be_a(GogglesDb::Meeting).and be_valid }

  context 'with a Meeting row as asset plus other valid parameters values,' do
    context 'with a valid current user,' do
      subject { render_inline(described_class.new(asset_row: meeting, current_user: user)) }

      let(:starred) { meeting.tags_by_user_list.include?("u#{user.id}") }
      let(:expected_icon) { starred ? '.fa.fa-star' : '.fa.fa-star-o' }
      let(:expected_color) { starred ? '.text-warning' : '.text-primary' }

      it 'renders the link button to toggle the team star modal' do
        expect(subject.at("a#btn-row-star-#{meeting.id}")).to be_present
        expect(subject.at("a#btn-row-star-#{meeting.id}").attributes['href'].value)
          .to eq(taggings_by_user_path(meeting_id: meeting.id))
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-row-star-#{meeting.id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-row-star-#{meeting.id} i#{expected_color}")).to be_present
      end
    end

    context 'with a invalid current user,' do
      subject do
        render_inline(described_class.new(asset_row: meeting, current_user: calendar))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end

    context 'with a nil current user,' do
      subject do
        render_inline(described_class.new(asset_row: meeting, current_user: nil))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a Calendar row as asset plus other valid parameters values,' do
    context 'with a valid current user,' do
      subject { render_inline(described_class.new(asset_row: calendar, current_user: user)) }

      let(:starred) { calendar.meeting.tags_by_user_list.include?("u#{user.id}") }
      let(:expected_icon) { starred ? '.fa.fa-star' : '.fa.fa-star-o' }
      let(:expected_color) { starred ? '.text-warning' : '.text-primary' }

      it 'renders the link button to toggle the team star modal' do
        expect(subject.at("a#btn-row-star-#{calendar.meeting_id}")).to be_present
        expect(subject.at("a#btn-row-star-#{calendar.meeting_id}").attributes['href'].value)
          .to eq(taggings_by_user_path(meeting_id: calendar.meeting_id))
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-row-star-#{calendar.meeting_id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-row-star-#{calendar.meeting_id} i#{expected_color}")).to be_present
      end
    end

    context 'with a invalid current user,' do
      subject do
        render_inline(described_class.new(asset_row: calendar, current_user: calendar))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end

    context 'with a nil current user,' do
      subject do
        render_inline(described_class.new(asset_row: calendar, current_user: nil))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with an unsupported but present asset row plus other valid parameters values,' do
    context 'with a valid current user,' do
      subject { render_inline(described_class.new(asset_row: user, current_user: user)) }

      let(:expected_icon) { '.fa.fa-minus-circle' }
      let(:expected_color) { '.text-danger' }

      it 'renders the disabled link button' do
        expect(subject.at('a#btn-row-star-')).to be_present
        expect(subject.at('a#btn-row-star-').attributes['href'].value).to eq('#')
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-row-star- i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-row-star- i#{expected_color}")).to be_present
      end
    end

    context 'with a invalid current user,' do
      subject do
        render_inline(described_class.new(asset_row: user, current_user: calendar))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end

    context 'with a nil current user,' do
      subject do
        render_inline(described_class.new(asset_row: user, current_user: nil))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a nil asset row plus other valid parameters values,' do
    subject do
      render_inline(described_class.new(asset_row: nil, current_user: user))
        .to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
