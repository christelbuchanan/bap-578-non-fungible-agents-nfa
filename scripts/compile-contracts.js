const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const solc = require('solc');

// Function to find all Solidity files in a directory
function findSolidityFiles(dir, fileList = []) {
  const files = fs.readdirSync(dir);
  
  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    
    if (stat.isDirectory()) {
      findSolidityFiles(filePath, fileList);
    } else if (file.endsWith('.sol')) {
      fileList.push(filePath);
    }
  });
  
  return fileList;
}

// Function to read imports from a Solidity file
function getImports(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const importRegex = /import\s+["'](.+?)["'];/g;
  const imports = [];
  let match;
  
  while ((match = importRegex.exec(content)) !== null) {
    imports.push(match[1]);
  }
  
  return imports;
}

// Main function to compile contracts
async function compileContracts() {
  console.log('Compiling contracts...');
  
  // Find all Solidity files
  const contractsDir = path.join(__dirname, '..', 'contracts');
  const solidityFiles = findSolidityFiles(contractsDir);
  
  console.log(`Found ${solidityFiles.length} Solidity files`);
  
  // Create input object for solc
  const input = {
    language: 'Solidity',
    sources: {},
    settings: {
      outputSelection: {
        '*': {
          '*': ['abi', 'evm.bytecode']
        }
      },
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  };
  
  // Add sources to input
  solidityFiles.forEach(file => {
    const relativePath = path.relative(contractsDir, file);
    input.sources[relativePath] = {
      content: fs.readFileSync(file, 'utf8')
    };
  });
  
  // Compile contracts
  console.log('Compiling...');
  const output = JSON.parse(solc.compile(JSON.stringify(input)));
  
  // Check for errors
  if (output.errors) {
    output.errors.forEach(error => {
      console.error(error.formattedMessage);
    });
    
    if (output.errors.some(error => error.severity === 'error')) {
      throw new Error('Compilation failed');
    }
  }
  
  // Create artifacts directory if it doesn't exist
  const artifactsDir = path.join(__dirname, '..', 'artifacts');
  if (!fs.existsSync(artifactsDir)) {
    fs.mkdirSync(artifactsDir, { recursive: true });
  }
  
  // Write artifacts
  for (const sourcePath in output.contracts) {
    const contracts = output.contracts[sourcePath];
    
    for (const contractName in contracts) {
      const contract = contracts[contractName];
      const artifactPath = path.join(artifactsDir, `${contractName}.json`);
      
      fs.writeFileSync(
        artifactPath,
        JSON.stringify({
          contractName,
          abi: contract.abi,
          bytecode: contract.evm.bytecode.object
        }, null, 2)
      );
      
      console.log(`Compiled ${contractName}`);
    }
  }
  
  console.log('Compilation complete!');
}

compileContracts().catch(error => {
  console.error(error);
  process.exit(1);
});
