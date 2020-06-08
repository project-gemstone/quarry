
.PHONY: fmt
fmt:
	find . -name "pkgbuild" -execdir shfmt -i 2 -ci -w {} \;
