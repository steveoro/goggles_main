# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Grid::TeamStarModalComponent, type: :component do
  let(:user) { GogglesDb::User.first(50).sample }
  let(:user_teams) { GogglesDb::Team.first(50).sample(2) }

  before do
    expect(user).to be_a(GogglesDb::User).and be_valid
    expect(user_teams).to be_an(Array).and be_present
  end

  context 'with a valid current user and user teams list,' do
    subject { render_inline(described_class.new(current_user: user, user_teams:)) }

    it 'renders the \'frm-team-star\' form inside the team star modal' do
      expect(subject.at('.modal#team-star-modal #frm-team-star')).to be_present
    end

    it 'includes hidden field \'meeting_id\'' do
      expect(subject.at('#frm-team-star #meeting_id')).to be_present
    end

    it 'renders the team star modal title' do
      expect(subject.at('h5#team-star-modal-title')).to be_present
      expect(subject.at('h5#team-star-modal-title').text).to include(I18n.t('calendars.tagging.team.title'))
    end

    it 'renders the team select field inside the modal body with options equal to the list of available user teams' do
      expect(subject.at('#team-star-modal-body select#team_id')).to be_present
      expect(user_teams.map(&:editable_name))
        .to(match_array(subject.css('#team-star-modal-body #team_id option').map(&:text)))
      expect(user_teams.map { |x| x.id.to_s })
        .to(match_array(subject.css('#team-star-modal-body #team_id option').map(&:values).flatten))
    end

    it 'renders the \'already tagged for\' label' do
      expect(subject.at('small #already-tagged-for')).to be_present
    end
  end

  context 'with a invalid current user,' do
    subject do
      render_inline(described_class.new(current_user: 'not-a-user', user_teams:))
        .to_html
    end

    it_behaves_like('any subject that renders nothing')
  end

  context 'with a nil current user,' do
    subject do
      render_inline(described_class.new(current_user: nil, user_teams:))
        .to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
  #-- -------------------------------------------------------------------------
  #++
end
