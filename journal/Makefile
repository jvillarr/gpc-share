TARGET=GPC
ASCIIDOC=asciidoc
ASCIIDOC_DBLATEX_STY=asciidoc-dblatex-custom.sty
ASCIIDOC_OPTS=-v
DBLATEX_OPTS=-V -Platex.hyperparam=colorlinks,linkcolor=blue,citecolor=blue,urlcolor=blue -Pdoc.publisher.show=0 -s $(ASCIIDOC_DBLATEX_STY)
ASCIIDOC_CONF="./xhtml11.conf"

.PHONY: clean html xml pdf

html: $(TARGET).html

xml: $(TARGET).xml

pdf: $(TARGET).pdf

epub: $(TARGET).epub

%.html: %.adoc
	$(ASCIIDOC) $(ASCIIDOC_OPTS) -o $@ $<
#	$(ASCIIDOC) --conf ${ASCIIDOC_CONF} $(ASCIIDOC_OPTS) -o $@ $<

%.xml: %.adoc
	$(ASCIIDOC) -b docbook -d article $(ASCIIDOC_OPTS) $<

%.pdf: %.xml %-revhistory.xml
	a2x --verbose --icons -d book --asciidoc-opts="$(ASCIIDOC_OPTS)" --no-xmllint --dblatex-opts="$(DBLATEX_OPTS)" -f pdf $<

%.epub: %.adoc
	a2x --verbose --icons -d book --asciidoc-opts="$(ASCIIDOC_OPTS)" --no-xmllint -f epub $<

clean:
	rm -f *~ $(TARGET).xml $(TARGET).pdf $(TARGET).html $(TARGET).epub
