require 'spec_helper'

describe SpreadsheetImporter::Importer do
  let(:importer) { described_class.new('hoge', 'fuga') }

  describe 'シード' do
    it 'クラスとユニークなカラム名をセットで渡してimportsを呼ぶとモデルを作成or更新できる' do
      importer = described_class.new(Category, :name)
      source = [
        ['name', 'display_name'],
        ['hoge', 'ほげ'],
        ['fuga', 'ふが'],
        ['fuga', 'ふがを上書き']
      ]
      allow(importer).to receive(:source).and_return(source)

      expect {
        importer.imports
      }.to change(Category, :count).by(2)
    end

    it '作成or更新されたモデルはsourceの各行と対応している' do
      importer = described_class.new(Category, :name)
      source = [
        ['name', 'display_name'],
        ['hoge', 'ほげ'],
        ['fuga', 'ふが'],
        ['fuga', 'ふがを上書き']
      ]
      allow(importer).to receive(:source).and_return(source)

      importer.imports
      expect(Category.pluck(:name)).to eq ['hoge', 'fuga']
      expect(Category.pluck(:display_name)).to eq ['ほげ', 'ふがを上書き']
    end
  end

  describe 'メソッド' do
    describe '#initialize(target_class, unique_key)' do
      it 'target_classに第一引数を、unique_keyに第二引数をアサインする' do
        expect(importer.instance_variable_get(:@target_class)).to eq 'hoge'
        expect(importer.instance_variable_get(:@unique_key)).to eq 'fuga'
      end
    end

    describe '#imports' do
      it 'recordsの戻り値をそれぞれimportに渡す' do
        allow(importer).to receive(:records).and_return([1, 2, 3])
        expect(importer).to receive(:import).with(1).exactly(1).times
        expect(importer).to receive(:import).with(2).exactly(1).times
        expect(importer).to receive(:import).with(3).exactly(1).times
        importer.imports
      end
    end

    describe '#import(record)' do
      it 'attribute_forにrecordを渡して得たモデルの属性情報からレコードを作成かアップデートする' do
        assign_value = Struct.new(:hoge) do
          def save!;
          end
        end.new

        allow(importer).to receive(:attribute_for).and_return('hoge')
        allow(importer).to receive(:assign).and_return(assign_value)
        expect(assign_value).to receive(:save!)
        importer.import('fuga')
      end
    end

    describe '#assign(attribute)' do
      it 'predicate!の戻り値からレコードを探すか新規作成して引数のattributeをアサインして返す' do
        allow(importer).to receive(:target_class).and_return(Category)
        allow(importer).to receive(:predicate!).and_return(name: 'hoge')
        allow(importer).to receive(:target_keys).and_return([:name, :color, :display_name])

        attribute = { color: '#fefefe', display_name: 'ほげ', bababa: 'baban' }
        result = importer.assign attribute

        expect(result).to be_a Category
        expect(result.color).to eq '#fefefe'
        expect(result.display_name).to eq 'ほげ'
      end
    end

    describe '#predicate!(attribute)' do
      it 'unique_keyとその値を組にしたHashを返す' do
        arg = { id: 1, name: 'hoge', title: 'fuga'}
        allow(importer).to receive(:unique_key).and_return(:name)
        expect(importer.predicate!(arg)).to eq({name: 'hoge'})
      end

      it '引数に渡されたattributeの属性を破壊する' do
        arg = { id: 1, name: 'hoge', title: 'fuga'}
        allow(importer).to receive(:unique_key).and_return(:name)
        importer.predicate!(arg)
        expect(arg).to eq({ id: 1, title: 'fuga'})
      end
    end

    describe '#attribute_for(record)' do
      it 'keyの戻り値と引数のレコードを組にしたHashを返す' do
        allow(importer).to receive(:key).and_return([:id, :name, :title])
        expect(importer.attribute_for([1, 'hoge', 'fuga'])).to eq({ id: 1, name: 'hoge', title: 'fuga'})
      end
    end

    describe '#key' do
      it 'sourceの戻り値の[0]のそれぞれの要素にto_symをかけて返す' do
        allow(importer).to receive(:source).and_return([['hoge', 'fuga', 'piyo'], ['moga', 'moge']])
        expect(importer.key).to eq [:hoge, :fuga, :piyo]
      end
    end

    describe '#records' do
      it 'sourceの戻り値の先頭要素を抜いて返す' do
        source = [
          ['id', 'name', 'title'],
          [1, 'hoge', 'hoge-title'],
          [2, 'fuga', 'fuga-title']
        ]

        allow(importer).to receive(:source).and_return(source)

        expect(importer.records).to eq([[1, 'hoge', 'hoge-title'], [2, 'fuga', 'fuga-title']])
      end
    end

    describe '#source' do
      it 'CreativeSurvey::Seed::Spreadsheet.new(ENV[\'SEED_KEY\'], title.to_s).to_aを返す' do
        allow(SpreadsheetImporter::Spreadsheet).to receive(:new).and_return({id: 1, name: 'hoge'})
        allow(importer).to receive(:title).and_return(:hoge)

        expect(importer.source).to eq([[:id, 1,], [:name, 'hoge']])
      end
    end

    describe '#title' do
      it 'target_classの名前を小文字かして返す' do
        target_class = Struct.new(:name).new('HOGE')

        allow(importer).to receive(:target_class).and_return(target_class)
        expect(importer.title).to eq 'hoge'
      end
    end

    describe 'suitable(hash)' do
      it '引数のHashからtarget_keysに合う属性だけを抽出したHashを返す' do
        allow(importer).to receive(:target_keys).and_return([:name])
        expect(importer.suitable(name: 'hoge', bname: 'fuga', cname: 'piyo')).to eq(name: 'hoge')
      end
    end

    describe '#target_keys' do
      it 'keyからfake_instanceが応答できるものだけを抽出したものを返す' do
        responder = Struct.new(:name, :hoge, :fuga, :piyo).new

        allow(importer).to receive(:fake_instance).and_return(responder)
        allow(importer).to receive(:key).and_return([:name, :hoge, :gege, :fuge])
        expect(importer.target_keys).to eq [:name, :hoge]
      end
    end

    describe '#fake_instance' do
      it 'target_class.newしたインスタンスを返す' do
        importer = SpreadsheetImporter::Importer.new(Category, :name)
        expect(importer.fake_instance).to be_a Category
      end
    end
  end
end
