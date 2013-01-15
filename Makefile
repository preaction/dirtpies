MXMLC = mxmlc
FLASHPUNK = flashpunk
SRC = Mudpies.as Mudpies/*
MAIN = Mudpies.as
SWF = Mudpies.swf
OPTIONS = -default-size=960,600 -static-link-runtime-shared-libraries=true
DEBUG_OPTIONS = -omit-trace-statements=false -debug=true

$(SWF) : $(SRC)
	$(MXMLC) $(OPTIONS) $(DEBUG_OPTIONS) -sp+=$(FLASHPUNK) -o $(SWF) -- $(MAIN)

debug : $(SWF)
	fdb $(SWF)

clean :
	-rm $(SWF)
