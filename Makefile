PROJ=SimpleBlinky

# `r0.1` or `r0.2`
VERSION:=r0.2

RM         = rm -rf
COPY       = cp -a
PATH_SEP   = /


all: ${PROJ}.dfu

dfu: ${PROJ}.dfu
	dfu-util -D $<

%.v: %.bsv
	bsc -verilog $<
	mv mkSimpleBlinky.v SimpleBlinky.v

%.json: %.v
	yosys -p "synth_ecp5 -json $@" $<

%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ --25k --package CSFBGA285 --lpf orangecrab_${VERSION}.pcf

%.bit: %_out.config
	ecppack --compress --freq 38.8 --input $< --bit $@

%.dfu : %.bit
	$(COPY) $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

clean_bit:
	$(RM) -f ${PROJ}.bit ${PROJ}_out.config ${PROJ}.json ${PROJ}.dfu 

clean_v:
	$(RM) -f ${PROJ}.v ${PROJ}.bo

clean: clean_v clean_bit

.PHONY: prog clean
