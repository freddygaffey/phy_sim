CXX = c++

# Taken from Tools/ardupilotwaf/boards.py (the clang branch)
CXXFLAGS = -std=gnu++11 -g \
           -fno-exceptions -fno-rtti \
           -cl-single-precision-constant \
           -fsigned-char \
           -Wall -Wextra -Wno-unused-parameter \
           -Werror=shadow -Werror=narrowing -Werror=return-type \
           -Werror=unused-result -Werror=unused-variable \
           -Werror=sign-compare -Werror=switch -Werror=uninitialized \
           -Werror=implicit-fallthrough -Werror=reorder \
           -Wdouble-promotion

# `make debug`: full debug info, no optimisation, plus runtime checkers
#   -g3                      debug info including macros (e.g. `p MAX_EDGE_CNT`)
#   -O0 -fno-inline          code runs line-by-line as written, all variables visible
#   -fno-omit-frame-pointer  reliable backtraces
#   -fsanitize=address       stops on out-of-bounds / use-after-free with the exact line
#   -fsanitize=undefined     stops on signed overflow, null deref, bad shifts etc.
DEBUG_FLAGS = -g3 -O0 -fno-inline -fno-omit-frame-pointer \
              -fsanitize=address,undefined -fno-sanitize-recover=all

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

# Always rebuilds from clean so optimised and debug builds never mix
debug: CXXFLAGS += $(DEBUG_FLAGS)
debug: clean prog

# Build debug and launch straight into lldb
lldb: debug
	lldb ./prog

clean:
	rm -rf prog prog.dSYM

.PHONY: check-headers run clean debug lldb
