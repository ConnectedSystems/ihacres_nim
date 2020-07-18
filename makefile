build:
	nim c -d:release --noMain --header --deadCodeElim:on --app:lib -o:./lib/ihacres.so ./src/*.nim > /dev/null


