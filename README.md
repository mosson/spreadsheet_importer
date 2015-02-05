# SpreadsheetImporter

Google Spreadsheet上にあるデータからActiveRecordを作成するためのライブラリ

運用のためのデータ（初期データや環境用データ）をGoogleSpreadsheetで管理しているとき、

非エンジニアでも編集できる環境とその反映を楽にする目的

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spreadsheet_importer', github: 'mosson/spreadsheet_importer'
```

And then execute:

    $ bundle

## Usage

0. Google Console上でアクセストークンを取得して環境変数にセットすること

### 必要な環境変数

```ruby
ENV['SEED_KEY'] # スプレッドシートのkey
ENV['GOOGLE_CLIENT_ID']
ENV["GOOGLE_CLIENT_SECRET"]
ENV['APPLICATION_NAME'] # Google APIに送るアプリケーション名
ENV['APPLICATION_VERSION'] # Google APIに送るアプリケーションのバージョン

ENV['GOOGLE_REFRESH_TOKEN'] # CreativeSurvey::Seed::GoogleSession.refresh_token を呼ぶと取得手順開始
```

```ruby
SpreadsheetImporter::Importer.new(Entry, :title).imports
```

第一引数にインポート対象のクラス(ワークシート名はクラス名をunderscoreしたものと一致したものを用意すること)
第二引数はfind_or_initialize_byの対象となるユニークなキーをシンボルで渡す

Rakeにすると以下のような感じ

```ruby
namespace :seed do
  desc 'Categoryモデルのデータをスプレッドシートから取得して代入する'
  task category: :environment do
    SpreadsheetImporter::Importer.new(Category, :name).imports
  end

  desc 'Entryモデルのデータをスプレッドシートから取得して代入する'
  task entry: :environment do
    SpreadsheetImporter::Importer.new(Entry, :permalink).imports
  end

  desc 'PublishedUrlモデルのデータをスプレッドシートから取得して代入する'
  task published_url: :environment do
    SpreadsheetImporter::Importer.new(PublishedUrl, :url).imports
  end
end

namespace :google do
  desc 'スプレッドシート取得のためのGoogle OAuthのリフレッシュトークンを取得する'
  task refresh_token: :environment do
    CreativeSurvey::Seed::GoogleSession.refresh_token
  end
end

```

## Contributing

1. Fork it ( https://github.com/mosson/spreadsheet_importer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
