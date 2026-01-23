.PHONY: install

install:
	@command -v pipx >/dev/null 2>&1 || { echo "pipx not found. Install: brew install pipx"; exit 1; }
	@pipx install pre-commit >/dev/null 2>&1 || pipx upgrade pre-commit
	@pre-commit --version
	@pre-commit clean
	@pre-commit install --hook-type pre-commit --overwrite
	@pre-commit install --hook-type commit-msg --overwrite

