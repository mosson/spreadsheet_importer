require 'spec_helper'

require 'ostruct'

describe SpreadsheetImporter::Session do
  describe 'モジュールメソッド' do
    describe '#auth' do
      it 'ENV[\'GOOGLE_CLIENT_ID\']かENV[\'GOOGLE_CLIENT_SECRET\']がnilであればNotImplementedErrorをあげる' do
        allow(ENV).to receive(:[]).and_return(nil)
        expect { described_class.auth }.to raise_error NotImplementedError
      end

      it 'authorizationの戻り値にparamsの戻り値を適用したものを返す' do
        allow(described_class).to receive(:authorization).and_return(OpenStruct.new)
        allow(described_class).to receive(:params).and_return({hoge: 'fuga'})
        result = described_class.auth
        expect(result.hoge).to eq 'fuga'
      end
    end

    describe '#params' do
      it 'Google向けのOAuthに必要な情報をHashで返す' do
        expect(described_class.params).to be_a Hash
        expect(described_class.params[:client_id]).not_to eq nil
        expect(described_class.params[:client_secret]).not_to eq nil
        expect(described_class.params[:redirect_uri]).not_to eq nil
        expect(described_class.params[:scope]).not_to eq nil
      end
    end

    describe '#client' do
      it 'Google向けのOAuthのクライアントを返す' do
        expect(described_class.client).to be_a Google::APIClient
      end
    end
  end
end
