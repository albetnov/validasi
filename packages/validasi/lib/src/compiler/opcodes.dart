abstract final class OpCodes {
  // ─── Common (0–99) ───────────────────────────────────────────────
  static const int required = 0;
  static const int nullable = 1;
  static const int inlineRule = 2;
  static const int having = 3;
  static const int transform = 4;

  // ─── String (100–199) ────────────────────────────────────────────
  static const int stringMinLength = 100;
  static const int stringMaxLength = 101;
  static const int stringOneOf = 102;

  // ─── Iterable / List (200–299) ───────────────────────────────────
  static const int listMinLength = 200;
  static const int listForEach = 201;

  // ─── Number (300–399) ────────────────────────────────────────────
  static const int numberFinite = 300;
  static const int numberLessThan = 301;
  static const int numberLessThanEqual = 302;
  static const int numberMoreThan = 303;
  static const int numberMoreThanEqual = 304;

  // ─── Map (400–499) ──────────────────────────────────────────────
  static const int mapHasFields = 400;
  static const int mapHasFieldKeys = 401;
  static const int mapConditionalField = 402;

  // ─── Custom / Extension base ────────────────────────────────────
  // Opcodes >= 1000 are reserved for user-defined extension rules.
  static const int extensionBase = 1000;
}
