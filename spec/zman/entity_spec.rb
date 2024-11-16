RSpec.describe Zman::Entity do
  it "has a nil id when it's not given one" do
    entity = Zman::Event.new(title: 'Here comes Babylon', date: Zman::Date.new(-607, 10))

    expect(entity.id).to be_nil
  end

  it "is new when it's not given an id" do
    entity = Zman::Event.new(title: 'Here comes Babylon', date: Zman::Date.new(-607, 10))

    expect(entity).to be_new
  end

  it "is persisted when it is given an id" do
    entity = Zman::Event.new(id: 1, title: 'Here comes Babylon', date: Zman::Date.new(-607, 10))

    expect(entity).to be_persisted
  end
end
