module SpreadsheetImporter
  class Spreadsheet
    attr_accessor :key, :title
    def initialize(key, title)
      self.key = key
      self.title = title
    end

    def to_a
      row_range.map do |row|
        col_range.map do |col|
          worksheet[row, col]
        end
      end
    end

    def row_range
      (1..worksheet.num_rows)
    end

    def col_range
      (1..worksheet.num_cols)
    end

    def worksheet
      @worksheet ||= spreadsheet.worksheets.find { |ws| ws.title == title }
    end

    def spreadsheet
      @spreadsheet ||= session.spreadsheet_by_key(key)
    end

    def session
      @session ||= ::GoogleDrive.login_with_oauth(auth.access_token)
    end

    def auth
      SpreadsheetImporter::Session.auth.tap do |a|
        a.refresh_token = ENV['GOOGLE_REFRESH_TOKEN']
        a.fetch_access_token!
      end
    end
  end
end
