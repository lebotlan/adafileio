.PHONY: all test clean doc build examples

UNITS = read_numbers read_text ex1 ex1b ex2 ex3 ex4 ex5

EXECS = $(UNITS:=-exe)

all: ${EXECS}

%-exe: ada/%.adb
	mkdir -p build
	gnatmake -D build -o $@ $<

clean:
	find -L . \( -name "*~" -o -name "*-exe" -o -name "*.ali" -o -name "*.o" \) -delete







