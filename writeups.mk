# When available, use latexmk to build PDFs for all .tex files

LATEXMK ?= $(shell which latexmk)
ifneq "$(LATEXMK)" ""

all::     writeups
WRITEUPS := $(patsubst %.tex,%.pdf,$(wildcard *.tex))
writeups: $(WRITEUPS)

%.pdf : %.tex
	$(LATEXMK)    -dvi- -ps- -pdf $<
	$(LATEXMK) -c -dvi- -ps- -pdf $<

clean:: writeups-clean
writeups-clean:
	rm -f $(WRITEUPS)

endif
