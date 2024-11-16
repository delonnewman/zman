RSpec.describe Zman::EntityFacts do
  it 'collects facts about entities' do
    birth = Zman::Event.new(title: "Jesus' Birth", date: Zman::Date.new(2, 9, era: :bce, precision: :circa))
    facts = described_class.new(birth, 1)

    expect(facts.collect).to include(Zman::Database::Fact.new(1, 'Zman::Event#title', "Jesus' Birth"))
  end
end
