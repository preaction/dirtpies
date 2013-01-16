MXMLC = mxmlc
FLASHPUNK = flashpunk
SRC = dirtpies.as dirtpies/*
MAIN = dirtpies.as
SWF = dirtpies.swf
OPTIONS = -default-size=960,600 -static-link-runtime-shared-libraries=true
DEBUG_OPTIONS = -omit-trace-statements=false -debug=true

$(SWF) : $(SRC)
	$(MXMLC) $(OPTIONS) $(DEBUG_OPTIONS) -sp+=$(FLASHPUNK) -o $(SWF) -- $(MAIN)

debug : $(SWF)
	fdb $(SWF)

clean :
	-rm $(SWF)
