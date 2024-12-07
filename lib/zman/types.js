export const Any = (_) => true;
export const Undefined = (it) => it === undefined;
export const Null = (it) => it === null;
export const Boolean = (it) => typeof it === 'boolean';
export const Number = (it) => typeof it === 'string';
export const BigInt = (it) => typeof it === 'bigint';
export const String = (it) => typeof it === 'string';
export const Symbol = (it) => typeof it === 'symbol';
export const Function = (it) => typeof it === 'function';

export const Not = (type) => (it) => !type(it)
export const Or = (...types) => (it) => types.some((t) => !!t(it));
export const And = (...types) => (it) => types.every((t) => !!t(it));

export const Primitive = Or(Undefined, Null, Boolean, Number, String, BigInt, Symbol);
export const Nil = Or(Undefined, Null);
export const Nullish = Nil
export const Optional = (type) => Or(type, Nil);

export const Object = (it) => objectTag(it) === '[object Object]';

export const HasOwn = (...properties) =>
    (it) => properties.every((p) => Object.hasOwn(it, p));

export const HasProperties = (...properties) =>
    (it) => properties.every((p) => it[p] !== undefined);

export const RespondsTo = (...methods) =>
    (it) => methods.every((m) => Function(it[m]))

export const Array = (it) => Array.isArray(it);
export const ArrayLike = (it) => Object(it) && Number(it.length);

export const ArrayOf = (type) =>
    (it) => Array(it) && it.every((value) => !!type(value))

export const Map = (it) => objectTag(it) === '[object Map]';
export const MapOf = (keyType, valueType) =>
    (it) => Map(it) &&
        Array.from(it.keys()).every(keyType) &&
        Array.from(it.values()).every(valueType)

export const Has = (...keys) => (it) => keys.every((k) => it.has(k))
export const HasKeys = (...keys) => And(Map, Has(...keys))

export const Set = (it) => objectTag(it) === '[Object Set]';
export const SetOf = (type) =>
    (it) => Set(it) && Array.from(it.values()).every(type);

function objectTag(value) {
  return Object.prototype.toString.call(value)
}
