require_relative '../../lib/zman'

RSpec.describe Zman::Event do
  it 'composes date objects' do
    date = Zman::Date.new(-1513, 1, precision: :circa)
    exodus = described_class.new(title: 'Exodus', date:)

    expect(exodus.date_value).to eq(date.value)
    expect(exodus.date_precision_value).to eq(date.precision_value)
    expect(exodus.date).to eq(date)
  end
end
