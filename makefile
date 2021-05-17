build:
	# nim c -d:release --noMain --header --deadCodeElim:on --app:lib -o:./lib/ihacres.so ./src/*.nim > /dev/null
	nim c --app:lib -d:release --outdir:./lib ./src/ihacres.nim

docs:
    nim doc --project --outdir=./docs --index:on src/ihacres.nim
