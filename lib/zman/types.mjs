const $ = globalThis;

export function validate(value, type) {
  if(!isValid(value)) {
    throw new TypeError(`${JSON.stringify(value)} is not a valid ${type}`);
  }
}

const BasicEncoding = {
  decode(value) { return value },
  encode(value) { return value }
}

// Basics
export const Undefined = mixin((it) => it === undefined, BasicEncoding);
export const Null = mixin((it) => it === null, BasicEncoding);
export const Boolean = mixin((it) => typeof it === 'boolean', BasicEncoding);
export const Number = mixin((it) => typeof it === 'string', BasicEncoding);
export const BigInt = mixin((it) => typeof it === 'bigint', BasicEncoding);
export const String = mixin((it) => typeof it === 'string', BasicEncoding);
export const Symbol = (it) => typeof it === 'symbol';
export const Function = (it) => typeof it === 'function';

// Some higher order combinators
export const Not = (type) => (it) => !type(it)
export const Or = (...types) => (it) => types.some((t) => !!t(it));
export const And = (...types) => (it) => types.every((t) => !!t(it));

// Some useful classifications
export const Primitive = mixin(Or(Undefined, Null, Boolean, Number, String, BigInt, Symbol), BasicEncoding);
export const Any = mixin((_) => true, BasicEncoding);
export const Literal = mixin((literal) => (it) => it === literal, BasicEncoding);

// Optionality of value
export const Nil = mixin(Or(Undefined, Null), BasicEncoding);
export const Nullish = Nil
export const Optional = (type) => Or(type, Nil);

// Objects, methods and properties
export const Object = mixin((it) => tag(it) === '[object Object]', BasicEncoding);

export const HasOwn = (...properties) => {
  const type = (it) => properties.every((p) => Object.hasOwn(it, p));
  type.properties = Object.freeze(properties);
  mixin(type, BasicEncoding);
  return type;
}

// Includes inherited properties
export const HasProperties = (...properties) => {
  const type = (it) => properties.every((p) => it[p] !== undefined);
  type.properties = Object.freeze(properties);
  mixin(type, BasicEncoding);
  return type;
}

export const RespondsTo = (...methods) => {
  const type = (it) => methods.every((m) => Function(it[m]));
  type.methods = Object.freeze(methods);
  return type;
}

export const Decodable = RespondsTo('decode');
export const Encodable = RespondsTo('encode');

const ShapeEncoding = {
  decode(value) {
    const newObj = {};
    for (const [name, value] of Object.entries(value)) {
      const valueType = this.schema[name];
      newObj[name] = Decodable(valueType) ? valueType.decode(value) : value;
    }
  },
  encode(value) {
    const newObj = {};
    for (const [name, value] of Object.entries(value)) {
      const valueType = this.schema[name];
      newObj[name] = Encodable(valueType) ? valueType.encode(value) : value;
    }
  }
}

export const HasShape = (schema) => {
  const type = (it) =>
        $.Object.entries(schema).every(([property, type]) => !!type(it[property]));

  type.schema = Object.freeze(schema);
  mixin(type, ShapeEncoding);

  return type;
}

const EnumEncoding = {
  decode(value) {
    return index[value] ?? throw new TypeError(`failed to decode "${value}" with ${type}`);
  },
  encode(value) {
    return this[value] ?? throw new TypeError(`failed to encode "${value} with ${type}`)
  }
}

export const EnumOf = (schema) => {
  const index = $.Object.entries(schema).reduce((index, [property, value]) => ({
    ...index, [property]: value, [value]: property
  }), {});

  const type = (it) => index[it] !== undefined;
  mixin(type, EnumEncoding);
  $.Object.entries(schema).forEach(([name, value]) => {
    type[name] = value;
  });

  return type;
}

// Higer-order type
export Type = HasShape({
  decode: Optional(Function),
  encode: Optional(Function),
  call: Function,
});

// Collections
export const Array = mixin((it) => Array.isArray(it), BasicEncoding);
export const ArrayLike = mixin((it) => Object(it) && Number(it.length), BasicEncoding);

export const ArrayOf = (type) =>
    (it) => Array(it) && it.every((value) => !!type(value))
mixin(ArrayOf, BasicEncoding);

export const Map = (it) => tag(it) === '[object Map]';
export const MapOf = (keyType, valueType) =>
    (it) => Map(it) &&
        Array.from(it.keys()).every(keyType) &&
        Array.from(it.values()).every(valueType)

const MapEncoding = {
  decode(value) {
    return new Map(Object.entries(value));
  },
  encode(value) {
    const newObj = {};
    for (const [name, value] of value) {
      newObj[name] = value;
    }
    return newObj;
  }
}

mixin(Map, MapEncoding);
mixin(MapOf, MapEncoding);

export const Has = (...keys) => (it) => keys.every((k) => it.has(k))
export const HasKeys = (...keys) => And(Map, Has(...keys))
mixin(HasKeys, MapEncoding);

export const Set = (it) => tag(it) === '[Object Set]';
export const SetOf = (type) =>
    (it) => Set(it) && Array.from(it.values()).every(type);

const SetEncoding = {
  decode(value) {
    return new Set(value);
  },
  encode(value) {
    return Array.from(value.values());
  }
}

mixin(Set, SetEncoding);
mixin(SetOf, SetEncoding);

export Timestamp = (it) => tag(it) === '[object Date]';
Timestamp.decode = (value) => new Date(value)
Timestamp.encode = (value) => value.toString()

function tag(value) {
  return $.Object.prototype.toString.call(value)
}

function mixin(type, object) {
  Object.assign(type, object);
  return type;
}
