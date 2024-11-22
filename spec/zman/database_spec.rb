RSpec.describe Zman::Database do
  let(:db) { described_class.new(eav_index:) }
  let(:eav_index) { Zman::Database::EAVIndex.new }

  it 'can collect facts' do
    db.add_fact(described_class::Fact.new(1, :plus, 2))
    db.add_fact(described_class::Fact.new(1, :plus, 3))

    expect(db.dig(1, :plus)).to eq([2, 3])
  end

  it "can remove facts that it's collected" do
    db.add_fact(described_class::Fact.new(1, :plus, 2))
    db.add_fact(described_class::Fact.new(1, :plus, 3))
    db.remove_fact(described_class::Fact.new(1, :plus, 3))

    expect(db.dig(1, :plus)).to eq([2])
  end

  it 'can collect facts about entities' do
    babylon = Zman::Event.new(title: 'Here comes Babylon', date: Zman::Date.new(607, 10, era: :bce))
    db.add_entity(babylon)

    expect(db.dig(1, 'Zman::Event#title')).to eq(['Here comes Babylon'])
  end

  it "doesn't collect facts about composite attributes" do
    babylon = Zman::Event.new(title: 'Here comes Babylon', date: Zman::Date.new(607, 10, era: :bce))
    db.add_entity(babylon)

    expect(db.dig(1, 'Zman::Event#date')).to be_nil
  end

  it 'collects facts about attributes that compose composite attributes' do
    date = Zman::Date.new(607, 10, era: :bce)
    babylon = Zman::Event.new(title: 'Here comes Babylon', date:)
    db.add_entity(babylon)

    expect(db.dig(1, 'Zman::Event#date_value')).to eq([date.value])
    expect(db.dig(1, 'Zman::Event#date_precision_value')).to eq([date.precision_value])
  end

  it 'creates unique ids for each entity' do
    babylon = Zman::Event.new(title: 'Here comes Babylon', date: Zman::Date.new(607, 10, era: :bce))
    id1 = db.add_entity(babylon).id

    note = Zman::Note.new(event_id: id1, content: 'This is a test')
    id2 = db.add_entity(note).id

    expect(id1).not_to eq(id2)
  end
end
