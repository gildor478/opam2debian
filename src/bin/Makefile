
all:
	./build.sh "$(CURDIR)/{{name}}"

install:
	cp -r "$(CURDIR)/{{name}}" "$(DESTDIR)/opt/opam2debian"

clean:
	-$(RM) -r "$(CURDIR)/{{name}}"
