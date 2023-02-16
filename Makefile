 VERSION	:= r9

image:
	podman build . -t ghcr.io/bketelsen/vanilla-os:$(VERSION)

