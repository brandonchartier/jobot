run:
	jpm clean
	jpm build
	./build/jobot

netrepl:
	jpm install spork
	janet -e "(import spork/netrepl) (netrepl/server)"
