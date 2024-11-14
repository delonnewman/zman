require_relative '../../lib/zman'

RSpec.describe Zman::Date do
  context 'value calculation' do
    example '1/1 = 1' do
      expect(described_class.new(1, 1).value).to be(1)
    end

    example '-500/3 = -1500' do
      expect(described_class.new(-500, 3).value).to be(-1500)
    end
  end

  context 'validation' do
    example 'zero is an invalid year' do
      expect { described_class.new(0, 1) }.to raise_error(described_class::Error)
    end

    example 'zero is an invalid month' do
      expect { described_class.new(1, 0) }.to raise_error(described_class::Error)
    end

    example 'values over 12 are invalid months' do
      expect { described_class.new(1, 13) }.to raise_error(described_class::Error)
    end
  end

  context 'precision' do
    it "reports the date's precision" do
      expect(described_class.new(1, 2, precision: :circa).precision).to be(:circa)
    end

    it 'has :exact precision by default' do
      expect(described_class.new(1, 1)).to be_exact
    end

    it 'can be initialized with :after precision' do
      expect(described_class.new(1, 1, precision: :after)).to be_after
    end

    it 'can be initialized with :before precision' do
      expect(described_class.new(1, 1, precision: :before)).to be_before
    end

    it 'can be initialized with :circa precision' do
      expect(described_class.new(1, 1, precision: :circa)).to be_circa
    end

    it 'can be initialized with :about precision' do
      expect(described_class.new(1, 1, precision: :about)).to be_about
    end

    it "is :about precision when it's :circa precision" do
      expect(described_class.new(1, 1, precision: :circa)).to be_about
    end

    it 'can specify precision by number value also' do
      expect(described_class.new(1, 1, precision: 0)).to be_exact
      expect(described_class.new(1, 1, precision: 1)).to be_after
      expect(described_class.new(1, 1, precision: 2)).to be_before
      expect(described_class.new(1, 1, precision: 3)).to be_circa
      expect(described_class.new(1, 1, precision: 3)).to be_about
    end
  end
end
