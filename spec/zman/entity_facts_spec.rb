RSpec.describe Zman::EntityChanges do
  subject(:changes) { described_class.new(entity, entity_id) }

  let(:entity) { Zman::Event.new(title: "Jesus' Birth", date: Zman::Date.new(2, 9, era: :bce, precision: :circa)) }
  let(:entity_id) { 1 }

  it 'collects facts about entities' do
    expect(changes.facts).to include(Zman::Database::Fact.new(entity_id, 'Zman::Event#title', "Jesus' Birth"))
  end

  it 'generates a new entity from the collected facts' do
    expect(changes.new_entity).not_to be(entity)
  end

  example 'the entity facts are the same other than timestamps' do
    old_facts = changes.facts.reject { _1.attribute == 'db#updated_at' }
    new_facts = described_class.new(changes.new_entity).facts.reject { _1.attribute == 'db#updated_at' }

    expect(new_facts).to eq(old_facts)
  end
end
