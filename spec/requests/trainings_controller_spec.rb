# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TrainingsController do
  describe 'GET /creative_trainings' do
    context 'with an unlogged user' do
      it 'is a redirect to the login path' do
        get(creative_trainings_path)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'with a logged-in user,' do
      let(:user) { FactoryBot.create(:user) }

      before { sign_in(user) }

      it 'is successful' do
        get(creative_trainings_path)
        expect(response).to have_http_status(:success)
      end

      it 'shows the localized gallery title' do
        get(creative_trainings_path)
        expect(response.body).to include(I18n.t('trainings.creative.title'))
      end

      context 'when rows with attached pictures exist,' do
        let!(:with_swimmer) do
          FactoryBot.create(:training_with_picture,
                            training_by: 'Coach One', created_by: 'Swimmer Author',
                            swimmer: FactoryBot.create(:swimmer), description: "4x100 FR\n2x200 IM")
        end

        before do
          FactoryBot.create(:training_with_picture,
                            training_by: 'Coach Two', created_by: 'Anonymous Author', swimmer: nil, description: nil)
          FactoryBot.create(:training, training_by: 'No Pic', created_by: 'Nobody')
          get(creative_trainings_path)
        end

        it 'renders thumbnails only for rows with an attached picture' do
          expect(response.body.scan('card-img-top').count).to eq(2)
          expect(response.body).not_to include('No Pic')
        end

        it 'shows the Training by & Created by captions' do
          expect(response.body).to include('Coach One')
          expect(response.body).to include('Swimmer Author')
          expect(response.body).to include('Coach Two')
          expect(response.body).to include('Anonymous Author')
        end

        it 'renders the created_by as a swimmer link only when a swimmer is associated' do
          expect(response.body).to include(swimmer_show_path(with_swimmer.swimmer_id))
        end

        it 'embeds the gallery items JSON for the modal controller' do
          expect(response.body).to include('gallery-items')
          expect(response.body).to include('full_url')
          expect(response.body).to include('4x100 FR')
        end

        it 'renders the modal gallery markup' do
          expect(response.body).to include('creative-gallery-modal')
          expect(response.body).to include('data-gallery-target="modal"')
        end
      end

      context 'when no rows have pictures,' do
        it 'shows the empty message' do
          get(creative_trainings_path)
          expect(response.body).to include(I18n.t('trainings.creative.empty'))
        end
      end
    end
  end
end
