XMLINFILES=$(wildcard *.xml)
XMLFILES = $(patsubst %.xml,%.xml,$(XMLINFILES))

all: po $(XMLFILES) sort

po: $(XMLINFILES)
	make -C po -f Makefile || exit 1

clean:
	@rm -fv *~ *.xml

validate: $(XMLFILES) comps.rng
	# Run xmllint on each file and exit with non-zero if any validation fails
	RES=0; for f in $(XMLFILES); do \
		xmllint --noout --relaxng comps.rng $$f; \
		RES=$$(($$RES + $$?)); \
	done; exit $$RES

sort:
	@# Run xsltproc on each xml.in file and exit with non-zero if any sorting fails
	@# The comps-eln.xml.in is not sorted alphabetically but manually
	@# based on the need needs of Fedora ELN SIG.
	@RES=0; for f in $(XMLINFILES); do \
		if [[ "$$f" == 'comps-eln.xml' ]]; then \
			continue; \
		fi; \
		xsltproc --novalid -o $$f comps-cleanup.xsl $$f; \
		RES=$$(($$RES + $$?)); \
	done; exit $$RES

%.xml: %.xml
	@xmllint --noout $<
	@if test ".$(CLEANUP)" == .yes; then xsltproc --novalid -o $< comps-cleanup.xsl $<; fi
	./update-comps $@