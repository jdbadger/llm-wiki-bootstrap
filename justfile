# Rebuild the starter-vault from current templates. Usage: just rebuild-starter
rebuild-starter:
	#!/usr/bin/env bash
	set -euo pipefail
	rm -rf starter-vault
	bash wiki-bootstrap.sh starter-vault
	echo "✓ starter-vault rebuilt"

# Run smoke tests. Usage: just test
test:
	bash _smoke-test.sh
