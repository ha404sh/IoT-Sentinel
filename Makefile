.PHONY: setup up down restart reset health test certs passwd init-db

setup:
	pwsh -File scripts/setup.ps1

up:
	pwsh -File scripts/start.ps1

down:
	pwsh -File scripts/stop.ps1

reset:
	pwsh -File scripts/reset.ps1

health:
	pwsh -File scripts/healthcheck.ps1

test:
	pwsh -File scripts/test.ps1

certs:
	pwsh -File scripts/generate-certs.ps1

passwd:
	pwsh -File scripts/generate-passwords.ps1

init-db:
	pwsh -File scripts/init-db.ps1
