build:
	nim c --app:lib -d:release --outdir:./lib ./ihacres/ihacres.nim

docs:
    nim doc --project --outdir=./docs --index:on ihacres/ihacres.nim
