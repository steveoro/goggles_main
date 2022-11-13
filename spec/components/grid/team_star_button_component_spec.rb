# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grid::TeamStarButtonComponent, type: :component do
  let(:meeting) { GogglesDb::Meeting.last(50).sample }
  let(:calendar) do
    GogglesDb::Calendar.joins(:meeting).includes(:meeting)
                       .last(50).sample
  end
  let(:user) { GogglesDb::User.first(50).sample }
  let(:user_teams) { GogglesDb::Team.first(50).sample(2) }

  before do
    expect(calendar.meeting).to be_a(GogglesDb::Meeting).and be_valid
    expect(user_teams).to be_an(Array).and be_present
  end

  context 'with a Meeting row as asset plus other valid parameters values,' do
    context 'with a valid current user,' do
      subject { render_inline(described_class.new(asset_row: meeting, current_user: user, user_teams: user_teams)) }

      let(:starred) do
        user_teams.map(&:id)
                  .any? { |team_id| meeting.tags_by_team_list.include?("t#{team_id}") }
      end
      let(:expected_icon) { starred ? '.fa.fa-calendar' : '.fa.fa-calendar-o' }
      let(:expected_color) { starred ? '.text-success' : '.text-secondary' }

      it 'renders the link button to toggle the team star modal' do
        expect(subject.at("a#btn-team-star-#{meeting.id}")).to be_present
        expect(subject.at("a#btn-team-star-#{meeting.id}").attributes['href'].value).to eq('#team-star-modal')
      end

      it 'includes the JS script to setup the modal dialog' do
        expect(subject.at("a#btn-team-star-#{meeting.id}").attributes['onclick'].value)
          .to include("$('#frm-team-star input#meeting_id').val(#{meeting.id});")
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-team-star-#{meeting.id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-team-star-#{meeting.id} i#{expected_color}")).to be_present
      end
    end

    context 'with a invalid current user,' do
      subject do
        render_inline(described_class.new(asset_row: meeting, current_user: calendar, user_teams: user_teams))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end

    context 'with a nil current user,' do
      subject do
        render_inline(described_class.new(asset_row: meeting, current_user: nil, user_teams: user_teams))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a Calendar row as asset plus other valid parameters values,' do
    context 'with a valid current user,' do
      subject { render_inline(described_class.new(asset_row: calendar, current_user: user, user_teams: user_teams)) }

      let(:starred) do
        user_teams.map(&:id)
                  .any? { |team_id| calendar.meeting.tags_by_team_list.include?("t#{team_id}") }
      end
      let(:expected_icon) { starred ? '.fa.fa-calendar' : '.fa.fa-calendar-o' }
      let(:expected_color) { starred ? '.text-success' : '.text-secondary' }

      it 'renders the link button to toggle the team star modal' do
        expect(subject.at("a#btn-team-star-#{calendar.meeting_id}")).to be_present
        expect(subject.at("a#btn-team-star-#{calendar.meeting_id}").attributes['href'].value).to eq('#team-star-modal')
      end

      it 'renders the link button with the expected icon' do
        expect(subject.at("a#btn-team-star-#{calendar.meeting_id} i#{expected_icon}")).to be_present
      end

      it 'renders the link button with the expected color' do
        expect(subject.at("a#btn-team-star-#{calendar.meeting_id} i#{expected_color}")).to be_present
      end
    end

    context 'with a invalid current user,' do
      subject do
        render_inline(described_class.new(asset_row: calendar, current_user: calendar, user_teams: user_teams))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end

    context 'with a nil current user,' do
      subject do
        render_inline(described_class.new(asset_row: calendar, current_user: nil, user_teams: user_teams))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with an unsupported but present asset row plus other valid parameters values,' do
    context 'with a valid current user,' do
      subject { render_inline(described_class.new(asset_row: user, current_user: user, user_teams: user_teams)) }

      let(:expected_icon) { '.fa.fa-minus-circle' }
      let(:expected_color) { '.text-danger' }

      it 'renders the *disabled* link button' do
        expect(subject.at('a.disabled#btn-team-star-')).to be_present
        expect(subject.at('a.disabled#btn-team-star-').attributes['href'].value).to eq('#team-star-modal')
      end

      it 'renders the *disabled* link button with the expected icon' do
        expect(subject.at("a.disabled#btn-team-star- i#{expected_icon}")).to be_present
      end

      it 'renders the *disabled* link button with the expected color' do
        expect(subject.at("a.disabled#btn-team-star- i#{expected_color}")).to be_present
      end
    end

    context 'with a invalid current user,' do
      subject do
        render_inline(described_class.new(asset_row: user, current_user: calendar, user_teams: user_teams))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end

    context 'with a nil current user,' do
      subject do
        render_inline(described_class.new(asset_row: user, current_user: nil, user_teams: user_teams))
          .to_html
      end

      it_behaves_like('any subject that renders nothing')
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with a nil asset row plus other valid parameters values,' do
    subject do
      render_inline(described_class.new(asset_row: nil, current_user: user, user_teams: user_teams))
        .to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
