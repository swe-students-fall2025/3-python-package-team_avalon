PACKAGE := eatnyc

# Read version from pyproject.toml
VERSION := $(shell python3 -c "import tomllib;print(tomllib.load(open('pyproject.toml','rb'))['project']['version'])")

WHEEL := dist/$(PACKAGE)-$(VERSION)-py3-none-any.whl

.PHONY: show-version clean build uninstall install-wheel reinstall test install-testpypi verify dev-on dev-off


# Info
show-version:
	@echo "Detected version: $(VERSION)"


# Build & Install (local wheel testing)
clean:
	@echo "Cleaning build artifacts..."
	rm -rf dist build src/*.egg-info

build: clean
	@echo "Building distribution..."
	pipenv run python -m build

install-wheel:
	@echo "Installing wheel: $(WHEEL)"
	pipenv install $(WHEEL)

uninstall:
	@echo "Uninstalling $(PACKAGE)..."
	-pipenv run pip uninstall -y $(PACKAGE)

reinstall: uninstall build install-wheel
	@echo "Reinstalled local wheel for $(PACKAGE) $(VERSION)."


# Quick tests
test:
	@echo "Quick import test..."
	pipenv run python -c "import $(PACKAGE), sys; print('OK:', $(PACKAGE).__file__)"

verify:
	@echo "Verify package path & version..."
	pipenv run python -c "import importlib.metadata as m, $(PACKAGE); print('Path:', $(PACKAGE).__file__); print('Version:', m.version('$(PACKAGE)'))"


# TestPyPI Install Testing
install-testpypi:
	@echo "Installing $(PACKAGE)==$(VERSION) from TestPyPI..."
	PIP_INDEX_URL=https://test.pypi.org/simple \
	PIP_EXTRA_INDEX_URL=https://pypi.org/simple \
	pipenv run pip install $(PACKAGE)==$(VERSION)


# Developer Mode Toggle (editable)
dev-on: uninstall
	@echo "Switching to developer editable mode..."
	pipenv install -e .
	@echo "✅ Developer mode ON (editable)."

dev-off: uninstall install-testpypi
	@echo "✅ Developer mode OFF (TestPyPI package installed)."
