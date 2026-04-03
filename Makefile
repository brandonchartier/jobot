deps:
	jpm deps

build: deps
	jpm clean
	jpm build

run: build
	./build/jobot

config:
	@test ! -f config.jdn && cp config.example.jdn config.jdn && echo "Created config.jdn — edit it with your settings" || echo "config.jdn already exists"

install: build
	cp jobot.service /etc/systemd/system/jobot.service
	cp build/jobot /opt/jobot/build/jobot
	@test -f /var/lib/jobot/config.jdn || cp config.example.jdn /var/lib/jobot/config.jdn && echo "Created /var/lib/jobot/config.jdn — edit it with your settings"
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
