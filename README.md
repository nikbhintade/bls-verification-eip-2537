# ERC 2537 Demo

> [!WARNING]  
> 🚧 **Work in Progress** 🚧  
> Currently only single BLS Signatures are getting verified and verification for aggregated signatures is not working. Current deductions is issue is happening in script where I am aggregating signatures.

This project implement on-chain BLS signature verification using EIP-2537 precompiles. It also uses Solady BLS.sol library to do the verification.

## Prerequisite

This project has both a foundry and a python project so make sure you have foundry and python along with uv (python package & project manager) installed.

If not you can install those by following their documentation:
- foundry: https://book.getfoundry.sh/getting-started/installation
- python: https://docs.astral.sh/uv/guides/install-python/
- uv: https://docs.astral.sh/uv/getting-started/installation/

## Building & Testing

After all that is installed, let's first clone the repo:
```bash
git clone git@github.com:nikbhintade/bls-verification-eip-2537.git .
cd bls-verification-eip-2537
```

### Python project

First we need to install the python dependencies
```bash
cd bls-py
uv sync
```

Activate the virtual environment with following command:
```bash
source .venv/bin/activate
```

Finally we can run our bls.py to generate a signature
```bash
uv run bls-single.py # generate single signature
uv run bls-aggregate.py # generate aggregated signature

cd ..
```

This will generate a file called `points.json` with public key and signature. I will explain why they are structured the way they are in a tutorial soon but keep that in mind.  

### Foundry Project

Install dependencies
```bash
forge soldeer install
```

Run tests (where you can see the signature getting verified):
```bash
forge test -vvvv --odyssey
```

## Remaining Work

Explaining BLS signatures and how verification works.

