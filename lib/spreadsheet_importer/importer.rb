# encoding: utf-8

module SpreadsheetImporter
  class Importer
    attr_accessor :target_class, :unique_key, :sheet_title

    def initialize(target_class, unique_key, sheet_title = nil)
      self.target_class = target_class
      self.unique_key = unique_key
      self.sheet_title = sheet_title
    end

    def imports
      records.map(&method(:import))
    end

    def import(record)
      target = assign(attribute_for(record))
      log(target)
      target.save!
      target
    rescue ::ActiveRecord::RecordInvalid => e
      STDOUT.puts target.errors.full_messages.join("\n")
      raise e
    end

    def log(target)
      STDOUT.puts "#{target_class}:#{target.send(unique_key)} is importing!"
    rescue
      nil
    end

    def assign(attribute)
      records = target_class
                .unscoped
      #  .find_or_initialize_by(predicate!(attribute))
      attributes = predicate!(attribute)
      record = records.where(attributes).first
      record = target_class.new(attributes, without_protection: true) if record.nil?
      record.tap do |r|
        suitable(attribute).each do |key, value|
          r.send("#{key}=", value)
        end
      end
    end

    def predicate!(attribute)
      { unique_key => attribute.delete(unique_key) }
    end

    def attribute_for(record)
      Hash[*key.zip(record).flatten]
    end

    def key
      source[0].map(&:to_sym)
    end

    def records
      source.drop(1)
    end

    def source
      @source ||= SpreadsheetImporter::Spreadsheet.new(
        ENV['SEED_KEY'],
        title.to_s
      ).to_a
    end

    def title
      sheet_title || target_class.name.underscore
    end

    def suitable(hash)
      hash.slice(*target_keys)
    end

    def target_keys
      key.select { |k| fake_instance.respond_to? "#{k}=".to_sym }
    end

    def fake_instance
      @fake_instance ||= target_class.new
    end
  end
end
