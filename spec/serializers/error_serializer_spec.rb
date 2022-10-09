# frozen_string_literal: true

RSpec.describe ErrorSerializer do
  subject(:error_serializer) { described_class }

  describe 'from_messages' do
    context 'with single error message' do
      let(:message) { 'Error message' }

      it 'returns errors representation' do
        expect(error_serializer.from_message(message)).to eq(
          errors: [
            { detail: message }
          ]
        )
      end
    end

    context 'with multiple error messages' do
      let(:messages) { ['Error message 1', 'Error message 2'] }

      it 'returns errors representation' do
        expect(error_serializer.from_messages(messages)).to eq(
          errors: [
            { detail: messages[0] },
            { detail: messages[1] }
          ]
        )
      end
    end

    context 'with extra source' do
      let(:message) { 'Error message' }
      let(:source) { { level: 'error' } }

      it 'returns errors representation' do
        expect(error_serializer.from_message(message, meta: source)).to eq(
          errors: [
            {
              detail: message,
              source: source
            }
          ]
        )
      end
    end
  end

  describe 'from_model' do
    let(:model) do
      instance_double(
        'model',
        errors: {
          blue: ['не может быть пустым'],
          green: ['не может быть пустым', 'имеет непредусмотренное значение']
        }
      )
    end
    let(:message) do
      {
        errors: [
          {
            detail: %(не может быть пустым),
            source: {
              pointer: '/data/attributes/blue'
            }
          },
          {
            detail: %(не может быть пустым),
            source: {
              pointer: '/data/attributes/green'
            }
          },
          {
            detail: %(имеет непредусмотренное значение),
            source: {
              pointer: '/data/attributes/green'
            }
          }
        ]
      }
    end

    it 'returns errors representation' do
      expect(error_serializer.from_model(model)).to eq(message)
    end
  end

  describe 'from_hash' do
    context 'with single key' do
      let(:source) { { 'key': 'error' } }
      let(:message) do
        {
          errors: [
            {
              detail: %(error),
              source: {
                pointer: '/data/attributes/key'
              }
            }
          ]
        }
      end

      it 'returns errors representation' do
        expect(error_serializer.from_hash(source)).to eq(message)
      end
    end

    context 'with multiple keys' do
      let(:source) { { 'key1': 'error1', 'key2': 'error2' } }
      let(:message) do
        {
          errors: [
            {
              detail: %(error1),
              source: {
                pointer: '/data/attributes/key1'
              }
            },
            {
              detail: %(error2),
              source: {
                pointer: '/data/attributes/key2'
              }
            }
          ]
        }
      end

      it 'returns errors representation' do
        expect(error_serializer.from_hash(source)).to eq(message)
      end
    end
  end
end
