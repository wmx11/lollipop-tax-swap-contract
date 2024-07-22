const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

// 0xD99D1c33F9fC3444f8101754aBC46c52416550D1 Testnet PCS Router

module.exports = buildModule("TaxSwap", (m) => {
  const taxSwap = m.contract("TaxSwap", [
    "0xb3A7Ab89c3a0e209b45338f1eCe30Dc246C0c4c0",
    "0xD99D1c33F9fC3444f8101754aBC46c52416550D1",
    "0xcCb181807bb845FE2ca80828069A5f529202Aea9",
    "0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee",
    "0x96eb94E54f385bcEb8C096784f229457B55D697a",
  ]);

  return { taxSwap };
});
