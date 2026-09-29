CXX = c++

# Taken from Tools/ardupilotwaf/boards.py (the clang branch)
CXXFLAGS = -std=gnu++11 \
           -fno-exceptions -fno-rtti \
           -cl-single-precision-constant \
           -fsigned-char \
           -Wall -Wextra -Wno-unused-parameter \
           -Werror=shadow -Werror=narrowing -Werror=return-type \
           -Werror=unused-result -Werror=unused-variable \
           -Werror=sign-compare -Werror=switch -Werror=uninitialized \
           -Werror=implicit-fallthrough -Werror=reorder \
           -Wdouble-promotion

SRCS = $(wildcard *.cpp)
BANNED_HEADERS = vector|string|map|list|set|unordered_map|memory|functional|thread|mutex|iostream|sstream|fstream|chrono|exception|stdexcept

RAYLIB = raylib/src
LDLIBS = $(RAYLIB)/libraylib.a \
         -framework Cocoa -framework IOKit -framework CoreVideo -framework OpenGL -framework QuartzCore

prog: $(SRCS) check-headers $(RAYLIB)/libraylib.a
	$(CXX) $(CXXFLAGS) -isystem $(RAYLIB) $(SRCS) -o prog $(LDLIBS)
	@# Same idea as check_elf_symbols in Tools/ardupilotwaf/ardupilotwaf.py
	@if nm -C prog | grep -E 'operator new(\[\])?\(unsigned long\)$$|std::__throw'; then \
		echo "ERROR: plain new or exception symbol found - use new(std::nothrow)"; rm prog; exit 1; fi

$(RAYLIB)/libraylib.a:
	$(MAKE) -C $(RAYLIB) PLATFORM=PLATFORM_DESKTOP

check-headers:
	@if grep -nE '#include *<($(BANNED_HEADERS))>' $(SRCS); then \
		echo "ERROR: STL header not allowed in ArduPilot style"; exit 1; fi

run: prog
	./prog

clean:
	rm -f prog

.PHONY: check-headers run clean
