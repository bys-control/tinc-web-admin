build:
	docker build -t byscontrol/tinc-webadmin:1.1pre14 .
	docker tag byscontrol/tinc-webadmin:1.1pre14 byscontrol/tinc-webadmin:latest
