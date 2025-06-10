module.exports = {
  // General formatting rules
  printWidth: 100,
  tabWidth: 2,
  useTabs: false,
  semi: true,
  singleQuote: true,
  quoteProps: "as-needed",
  trailingComma: "all",
  bracketSpacing: true,
  arrowParens: "always",
  endOfLine: "lf",

  // Solidity-specific configuration
  overrides: [
    {
      files: "*.sol",
      options: {
        tabWidth: 4,
        singleQuote: false,
      },
    },
  ],

  // Plugin configuration
  plugins: ["prettier-plugin-solidity"],
};
