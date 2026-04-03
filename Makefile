deps:
	jpm deps

run: deps
	jpm clean
	jpm build
	./build/jobot

install:
	cp jobot.service /etc/systemd/system/jobot.service
	systemctl daemon-reload
	systemctl enable jobot.service

uninstall:
	systemctl stop jobot.service || true
	systemctl disable jobot.service || true
	rm -f /etc/systemd/system/jobot.service
	systemctl daemon-reload

start:
	systemctl start jobot.service

stop:
	systemctl stop jobot.service

restart:
	systemctl restart jobot.service

status:
	systemctl status jobot.service
