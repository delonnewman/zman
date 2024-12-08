export const Comparable = {
  isEqual(other) {
    return this.compare(other) === 0;
  },

  isGreaterThan(other) {
    return this.compare(other) === 1;
  },

  isLessThan(other) {
    return this.compare(other) === -1;
  },

  isGreaterThanOrEqual(other) {
    return this.isGreaterThan(other) || this.isEqual(other);
  },

  isLessThanOrEqual(other) {
    return this.isLessThan(other) || this.isEqual(other);
  },
};
