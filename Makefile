play:
	love ./src/

love:
	mkdir -p dist
	cd src && zip -r ../dist/CarRace.love .

js: love
	love.js -c --title="Car Race" ./dist/CarRace.love ./dist/js
