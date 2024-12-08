import {
  ArrayOf,
  EnumOf,
  HasShape,
  Optional,
  Number,
  Map,
  MapOf,
  String,
  validate,
} from './types.mjs';

export const Precision = EnumOf({
  exact: 0,
  after: 1,
  before: 2,
  circa: 3,
});

export const DateMethods = {
  compare(other) {
    if (!Date(other)) return;

    return compare_number(this.value, other.value);
  },

  precision_name() {
    return Precision[this.precision];
  },

  has_precision(precision) {
    return this.precision === precision;
  },

  toString() {
    return this.label;
  },
}

function compare_number(a, b) {
  if (a === b) return 0;
  if (a > b) return 1;

  return -1
}

export const Date = HasShape({
  value: Number,
  precision: Precision,
  label: String,
});

Date.decode = function(value) {
  validate(value, this);
  return Object.assign(HasShape.decode.call(this, value), DateMethods);
};

export const Attribute = HasShape({
  name: String,
  namespace: String,
  entity_class_name: String,
  options: Map,
});

export const Schema = MapOf(String, ArrayOf(Attribute));

export const EntityClass = HasShape({
  attributes: ArrayOf(Attribute),
});

export const Entity = HasShape({
  attributes: Map,
  class: EntityClass,
});

export const EntityMethods = {
  has(attribute) {
    return this.attributes.has(attribute);
  },

  get(attribute) {
    return this.attributes.get(attribute);
  },

  isPersisted() {
    return this.has('id');
  },

  isNew() {
    return !this.isPersisted();
  },
};
