# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FlashAlertComponent, type: :component do
  let(:text_body) { FFaker::CheesyLingo.sentence }
  let(:text_title) { [FFaker::Company.bs, nil].sample }

  # Force domain creation:
  before do
    expect(text_body).to be_present
    expect(text_title).to be_present.or be_nil
  end

  FlashAlertComponent::SUPPORTED_SYMS.each do |symbol|
    context "when using a supported symbol (#{symbol})," do
      subject { render_inline(described_class.new(symbol: symbol, body: text_body, title: text_title)) }

      it 'renders an alert box' do
        expect(subject.css('.alert')).to be_present
      end

      it 'includes a close button' do
        expect(subject.css('button.close')).to be_present
      end

      it 'includes the text body' do
        expect(subject.css('p.flash-body').text).to include(text_body)
      end

      it 'includes the text title, when set' do
        if text_title.to_s.present?
          expect(
            subject.css('h5.alert-heading').text
          ).to include(text_title)
        end
      end
    end
  end

  context 'when using an unsupported symbol,' do
    subject { render_inline(described_class.new(symbol: :not_in_list, body: text_body)).to_html }

    it_behaves_like('any subject that renders nothing')
  end

  context 'when using an empty body,' do
    subject do
      render_inline(
        described_class.new(symbol: FlashAlertComponent::SUPPORTED_SYMS.sample, body: '')
      ).to_html
    end

    it_behaves_like('any subject that renders nothing')
  end
end
