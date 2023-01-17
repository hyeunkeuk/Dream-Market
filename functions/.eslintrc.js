module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "quotes": ["error", "double"],
    "import/no-unresolved": 0,
    "max-len": ["error", {"code": 120}],
  },
};
