const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// Ensure the artifacts directory exists
const artifactsDir = path.join(__dirname, '../artifacts');
if (!fs.existsSync(artifactsDir)) {
  fs.mkdirSync(artifactsDir, { recursive: true });
}

console.log('Compiling BEP-007 contracts...');

try {
  // Run Hardhat compile
  execSync('npx hardhat compile', { stdio: 'inherit' });
  console.log('Compilation successful!');

  // Generate documentation from NatSpec comments
  console.log('Generating documentation from NatSpec comments...');
  
  // This would typically use a tool like solidity-docgen
  // For now, we'll just note that this step would happen here
  console.log('Documentation generation placeholder - implement with solidity-docgen or similar tool');

  console.log('Compilation and documentation process complete!');
} catch (error) {
  console.error('Compilation failed:', error.message);
  process.exit(1);
}
