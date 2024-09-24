# Makefile

# Define directories
EVM_DIR := evm
APTOS_DIR := aptos
SIGNATURE_VERIFIER_DIR := signature_verifier

# Default target, in case no target is specified
.PHONY: all
all: sign test

# Run yarn sign in the evm/ directory
.PHONY: install
sign:
	@echo "Installing packages in the evm/ directory..."
	cd $(EVM_DIR) && yarn install


# Run yarn sign in the evm/ directory
.PHONY: sign
sign:
	@echo "Running yarn sign in the evm/ directory..."
	cd $(EVM_DIR) && yarn sign

# Run aptos move test in the aptos/ directory
.PHONY: test
test:
	@echo "Running aptos move test --package-dir signature_verifier in the aptos/ directory..."
	cd $(APTOS_DIR) && aptos move test --package-dir $(SIGNATURE_VERIFIER_DIR)

# Clean target to remove any built artifacts (optional)
.PHONY: clean
clean:
	@echo "Cleaning up..."
	rm -rf $(EVM_DIR)/node_modules
	rm -rf $(APTOS_DIR)/build
	rm -rf $(APTOS
