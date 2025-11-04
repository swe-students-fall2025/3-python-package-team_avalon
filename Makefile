# =======================
# Project Settings
# =======================
PACKAGE := eatnyc

# Read version from pyproject.toml (safe, single-line Python)
VERSION := $(shell python3 -c "import tomllib;print(tomllib.load(open('pyproject.toml','rb'))['project']['version'])")

WHEEL := dist/$(PACKAGE)-$(VERSION)-py3-none-any.whl

# =======================
# Phony Targets
# =======================
.PHONY: help show-version clean build uninstall install-wheel reinstall \
        test test-smoke verify install-testpypi \
        dev-on dev-off \
        test-unit \
        release-test release \
        tag push-tag

# =======================
# Help
# =======================
help:
	@echo "Make targets:"
	@echo "  show-version      - Print detected version from pyproject.toml"
	@echo "  clean             - Remove build artifacts"
	@echo "  build             - Build wheel/sdist"
	@echo "  uninstall         - Uninstall $(PACKAGE) from current Pipenv env"
	@echo "  install-wheel     - Install local wheel"
	@echo "  reinstall         - Clean build + install local wheel"
	@echo "  test              - Smoke test (import and show path)"
	@echo "  test-smoke        - Alias of 'test'"
	@echo "  verify            - Show import path and installed version"
	@echo "  test-unit         - Run pytest (use in dev-on/editable mode)"
	@echo "  install-testpypi  - Install $(PACKAGE)==$(VERSION) from TestPyPI"
	@echo "  dev-on            - Editable install (-e .)"
	@echo "  dev-off           - Switch to TestPyPI-installed package"
	@echo "  release-test      - Upload dist/* to TestPyPI via twine"
	@echo "  release           - Upload dist/* to PyPI via twine"
	@echo "  tag               - Create git tag v$(VERSION)"
	@echo "  push-tag          - Push tag v$(VERSION) to origin"

# =======================
# Info
# =======================
show-version:
	@echo "Detected version: $(VERSION)"

# =======================
# Build & Install (local wheel testing)
# =======================
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

# =======================
# Quick tests (smoke)
# =======================
test:
	@echo "Quick import test..."
	pipenv run python -c "import $(PACKAGE), sys; print('OK:', $(PACKAGE).__file__)"

test-smoke: test

verify:
	@echo "Verify package path & version..."
	pipenv run python -c "import importlib.metadata as m, $(PACKAGE); print('Path :', $(PACKAGE).__file__); print('Version:', m.version('$(PACKAGE)'))"

# =======================
# Unit tests (pytest) — run in dev-on/editable mode
# =======================
test-unit:
	@echo "Running pytest..."
	pipenv run pytest -q

# =======================
# TestPyPI Install Testing
# =======================
install-testpypi:
	@echo "Installing $(PACKAGE)==$(VERSION) from TestPyPI..."
	PIP_INDEX_URL=https://test.pypi.org/simple \
	PIP_EXTRA_INDEX_URL=https://pypi.org/simple \
	pipenv run pip install $(PACKAGE)==$(VERSION)

# =======================
# Developer Mode Toggle (editable)
# =======================
dev-on: uninstall
	@echo "Switching to developer editable mode..."
	pipenv install -e .
	@echo "✅ Developer mode ON (editable)."

dev-off: uninstall install-testpypi
	@echo "✅ Developer mode OFF (TestPyPI package installed)."

# =======================
# Release (local twine) — requires ~/.pypirc or env TWINE_USERNAME/TWINE_PASSWORD
# =======================
release-test: build
	@echo "Uploading to TestPyPI via twine..."
	pipenv run twine upload -r testpypi dist/*

release: build
	@echo "Uploading to PyPI via twine..."
	pipenv run twine upload dist/*

# =======================
# Git tags (to trigger CI release workflows)
# =======================
tag:
	@git tag v$(VERSION)
	@echo "Created tag v$(VERSION)."

push-tag:
	@git push origin v$(VERSION)
	@echo "Pushed tag v$(VERSION) to origin."
