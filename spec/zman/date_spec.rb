require_relative '../../lib/zman'

RSpec.describe Zman::Date do
  context 'value calculation' do
    example '1/1 = 1' do
      expect(described_class.new(1, 1).value).to be(13)
    end

    example '-500/3 = -5997' do
      expect(described_class.new(-500, 3).value).to be(-5997)
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

  context 'equality' do
    it 'provides value equality' do
      date1 = described_class.new(1, 2)
      date2 = described_class.new(1, 2)

      expect(date1).to eq(date2)
    end
  end

  context 'era' do
    it 'ensures that the value is negative when :bce is given' do
      expect(described_class.new(200, 1, era: :bce).value).to be < 0
    end

    it 'ensures that the value is positive when :ce is given' do
      expect(described_class.new(-200, 1, era: :ce).value).to be > 0
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

    described_class::PRECISION_VALUES.each do |name, value|
      it "when given #{value} for precision it maps to #{name}" do
        expect(described_class.new(1, 1, precision: value).precision).to be(name)
      end
    end
  end
end
