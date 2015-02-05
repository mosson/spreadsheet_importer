require 'spec_helper'

describe SpreadsheetImporter::Spreadsheet do
  describe 'メソッド' do
    describe '#initialize(key, title)' do
      it '@key, @titleをアサインする' do
        sheet = described_class.new('hoge', 'fuga')
        expect(sheet.instance_variable_get(:@key)).to eq 'hoge'
        expect(sheet.instance_variable_get(:@title)).to eq 'fuga'
      end
    end

    describe '#to_a' do
      it 'row_range, col_rangeの組み合わせをworksheetの[]メソッドに送る' do
        sheet = described_class.new('hoge', 'fuga')
        allow(sheet).to receive(:row_range).and_return(1..2)
        allow(sheet).to receive(:col_range).and_return(1..2)
        worksheet = Struct.new(:hoge) do
          def [](*args); end
        end.new

        allow(sheet).to receive(:worksheet).and_return(worksheet)

        expect(worksheet).to receive(:[]).with(1,1).exactly(1).times
        expect(worksheet).to receive(:[]).with(1,2).exactly(1).times
        expect(worksheet).to receive(:[]).with(2,1).exactly(1).times
        expect(worksheet).to receive(:[]).with(2,2).exactly(1).times
        sheet.to_a
      end
    end


    describe '#row_range' do
      it '1からworksheet.num_rowsまでのrangeを返す' do
        sheet = described_class.new('hoge', 'fuga')
        worksheet = Struct.new(:num_rows).new(4)
        allow(sheet).to receive(:worksheet).and_return(worksheet)
        expect(sheet.row_range).to eq (1..4)
      end
    end

    describe '#col_range' do
      it '1からworksheet.num_colsまでのrangeを返す' do
        sheet = described_class.new('hoge', 'fuga')
        worksheet = Struct.new(:num_cols).new(7)
        allow(sheet).to receive(:worksheet).and_return(worksheet)
        expect(sheet.col_range).to eq (1..7)
      end
    end

    describe '#worksheet' do
      it 'spreadsheet.worksheetsから自身のtitleと等しいものを返す' do
        worksheet_klass = Struct.new(:title)
        spreadsheet = Struct.new(:worksheets).new(
          [
            worksheet_klass.new('hoge'),
            worksheet_klass.new('fuga'),
            worksheet_klass.new('piyo')
          ]
        )

        sheet = described_class.new('hoge', 'fuga')
        allow(sheet).to receive(:spreadsheet).and_return(spreadsheet)
        expect(sheet.worksheet.title).to eq 'fuga'
      end
    end

    describe '#spreadsheet' do
      it 'session.spreadsheet_by_keyに自身のkeyを送る' do
        session_klass = Struct.new(:hoge) do
          def spreadsheet_by_key(*args); end
        end
        session = session_klass.new

        sheet = described_class.new('hoge', 'fuga')
        allow(sheet).to receive(:session).and_return(session)
        expect(session).to receive(:spreadsheet_by_key).with('hoge')
        sheet.spreadsheet
      end
    end

    describe '#session' do
      it 'GoogleDriveモジュールのlogin_with_oauthメソッドにauth.access_tokenを送る' do
        auth = Struct.new(:access_token).new('acccccccc')
        sheet = described_class.new('hoge', 'fuga')
        allow(sheet).to receive(:auth).and_return(auth)
        expect(GoogleDrive).to receive(:login_with_oauth).with('acccccccc')
        sheet.session
      end
    end

    describe '#auth' do
      it 'GoogleSessionモジュールのauthの戻り値にrefresh_token=とfetch_access_token!を呼ぶ' do
        mock_class = Struct.new(:refresh_token) do
          def fetch_access_token!; end
        end
        mock = mock_class.new

        sheet = described_class.new('hoge', 'fuga')

        allow(SpreadsheetImporter::Session).to receive(:auth).and_return(mock)
        expect(ENV['GOOGLE_REFRESH_TOKEN']).not_to be_blank
        expect(mock).to receive(:refresh_token=).with(ENV['GOOGLE_REFRESH_TOKEN'])
        expect(mock).to receive(:fetch_access_token!)
        sheet.auth
      end
    end
  end

end