
# Colors
RESET				= \033[0m
BOLD				= \033[1m
RED					= \033[0;31m
GREEN				= \033[0;32m
YELLOW				= \033[0;33m
BLUE				= \033[0;34m
MAGENTA				= \033[0;35m
CYAN				= \033[0;36m
WHITE				= \033[0;37m

BRIGHT_RED			= \033[0;91m
BRIGHT_GREEN		= \033[0;92m
BRIGHT_YELLOW		= \033[0;93m
BRIGHT_BLUE			= \033[0;94m
BRIGHT_CYAN			= \033[0;96m

# Git settings
GITHUB_USER			:= SabaDevvy
GITHUB_URL			:= git@github.com:$(GITHUB_USER)/

# Make settings and machine info
LOG_TIME			= $$(date "+%H:%M:%S")
UNAME_S				:= $(shell uname -s)
UNAME_M				:= $(shell uname -m)
IS_LINUX			:= $(filter Linux,$(UNAME_S))

JOBS				:= $(shell nproc 2>/dev/null || echo 2)

ifeq ($(filter --jobserver-fds=% -j%,$(MAKEFLAGS)),)
  ifeq ($(MAKELEVEL), 0)
    MAKEFLAGS += -j$(JOBS)
  endif
endif

ifndef VERBOSE
	MAKEFLAGS += -s
endif

ifdef DEBUG
CFLAGS				+= -g -DDEBUG
endif

# Project
PROJECT				= libft_io

NAME				= $(addsuffix .a, $(PROJECT))

NAME_TEST			= $(addsuffix _test.exe, $(PROJECT))
NAME_DEBUG			= $(addsuffix _debug.exe, $(PROJECT))
NAME_DEBUG_VAL		= $(addsuffix _debug_val.exe, $(PROJECT))
ASAN_LOGS			= $(addsuffix .dSYM, $(NAME_DEBUG))

# Libraries
# LIBS_LOCAL if you don't use submodules, else LIBS_SUBMODULE. LIBS_EXTERNAL = external libraries.
LIBS_LOCAL			:= libft
LIBS_SUBMODULE		:=
LIBS_EXTERNAL		:=
LIBS				:= $(LIBS_EXTERNAL) $(LIBS_LOCAL) $(LIBS_SUBMODULE)
LIBS_CLEAN			:= $(strip $(LIBS))

# Compile settings
CC					= cc
CFLAGS				= -Wall -Wextra -Werror -Iincludes
DEBUG_FLAGS			= -gdwarf-4 -DDEBUG -fno-omit-frame-pointer
SANITIZE_COMPILE	= -fsanitize=address -fsanitize=undefined
SANITIZE_LINK		= -fsanitize=address -fsanitize=undefined
AR					= ar rcs
RM					= rm -rf

# Directories
SRCS_DIR			:= src/
OBJS_DIR 			:= objs/
OBJS_DIRS			= $(sort $(dir $(OBJS)))
DEBUG_DIR			= debug/
DOCKER_DIR			= debug/docker/
LIBS_DIR			:= ../
LIBS_DIRS			:= $(addprefix $(LIBS_DIR), $(addsuffix /, $(LIBS)))

OBJS_DEBUG_DIR		= debug/objs/
OBJS_DOCKER_DIR		= debug/docker/objs/

# Compile info
SRCS				:= $(shell find src -type f -name "*.c")
OBJS				:= $(SRCS:$(SRCS_DIR)%.c=$(OBJS_DIR)%.o)
OBJS_DEBUG			:= $(SRCS:$(SRCS_DIR)%.c=$(OBJS_DEBUG_DIR)%.o)
OBJS_DOCKER			:= $(SRCS:$(SRCS_DIR)%.c=$(OBJS_DOCKER_DIR)%.o)


DEPS				:= $(wildcard includes/*.h)

LIBS_LINKS			:= $(addprefix -L, $(LIBS_DIRS)) $(addprefix -l, $(subst lib,,$(LIBS)))
LIBS_LINKS_DOCKER	:= $(addprefix -L, $(DOCKER_DIR)) $(addprefix -l, $(subst lib,,$(addsuffix _docker,$(LIBS))))

TEST_FILES			:= test.c

# # Includes
# INCLUDES_DIR		:= includes/
# INCLUDES_DIRS		:= $(INCLUDES_DIR) $(addsuffix $(INCLUDES_DIR), $(LIBS_DIRS))
# vpath %.h $(INCLUDES_DIRS)
# CFLAGS				+= $(addprefix -I, $(INCLUDES_DIRS))
# $(info $(INCLUDES_DIRS))

all:
	@mkdir -p $(sort $(dir $(OBJS)))
	$(MAKE) $(NAME)

$(NAME): $(OBJS)
	@echo "[$(LOG_TIME)]$(BRIGHT_YELLOW)[$(PROJECT)]	[COMPILE]	Compiling archive [$(NAME)]...$(RESET)"
	$(AR) $(NAME) $(OBJS)
	@echo "[$(LOG_TIME)]$(BRIGHT_GREEN)[$(PROJECT)]	[SUCCESS]	Archive [$(NAME)] successfully compiled!$(RESET)"

test: validate_env all build-libs
	@echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[COMPILE]	Compiling exe [$(NAME_TEST)]...$(RESET)"
	$(CC) $(CFLAGS) $(TEST_FILES) -L. -l$(subst lib,,$(PROJECT)) $(LIBS_LINKS) -o $(NAME_TEST)
	@echo "[$(LOG_TIME)]$(BRIGHT_GREEN)[$(PROJECT)]	[SUCCESS]	Exe [$(NAME_TEST)] successfully compiled!$(RESET)"
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[RUN]		Running [$(NAME_TEST)]...$(RESET)"
	echo "\n-----------------------------------------"
	./$(NAME_TEST)
	echo "\n-----------------------------------------"

$(OBJS_DIR)%.o: $(SRCS_DIR)%.c $(DEPS)
ifeq ($(DETAILS),1)
	@echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[COMPILE]	Compiling $< in $(OBJS_DIR)$(RESET)"
endif
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	@echo "[$(LOG_TIME)]$(RED)[$(PROJECT)]	[CLEAN]		Cleaning [$(NAME)] object files...$(RESET)"
	$(RM) $(OBJS_DIR)

fclean: clean
	@echo "[$(LOG_TIME)]$(BRIGHT_RED)[$(PROJECT)]	[CLEAN]		Full cleaning: Removing [$(NAME)]...$(RESET)"
	$(RM) $(NAME) $(NAME_TEST) $(NAME_DEBUG)

re:
	$(MAKE) fclean
	$(MAKE) all

validate_env:
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[INFO]		Creating/checking [$(NAME)] environment...$(RESET)"
	# Check for outdated or uninitialized submodules
	@if git submodule status --recursive | grep '^[+-]' > /tmp/submodule_issues; then \
		echo "[$(LOG_TIME)]$(BRIGHT_RED)[$(PROJECT)]	[ERROR]		Some submodules are outdated or not initialized!$(RESET)"; \
		while read -r line; do \
			submodule=$$(echo $$line | awk '{print $$2}'); \
			submodule_name=$$(basename $$submodule); \
			if echo "$$line" | grep -q '^+'; then \
				echo "$[(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[WARNING]	Submodule $$submodule_name is outdated!$(RESET)"; \
			elif echo "$$line" | grep -q '^-'; then \
				echo "[$(LOG_TIME)]$(RED)[$(PROJECT)]	[ERROR]		Submodule $$submodule_name is not initialized!$(RESET)"; \
			fi; \
		done < /tmp/submodule_issues; \
		rm /tmp/submodule_issues; \
	fi
	# Check if required libs paths exist
	@for library in $(LIBS); do \
		if [ ! -d "$(LIBS_DIR)$$library" ]; then \
			echo "[$(LOG_TIME)]$(BRIGHT_RED)[$(PROJECT)]	[ERROR]		$$library directory not found! Run: [$(BRIGHT_YELLOW)make clone_libs / make update_submodules$(BRIGHT_RED)]$(RESET)"; \
			exit 1; \
		fi; \
	done
	# Checks uncommitted changes
	@for submodule in $(LIBS_SUBMODULE); do \
		if cd $(LIBS_DIR)$$submodule && git status --porcelain | grep -q .; then \
			echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[WARNING]	Detected changes in submodule [$$submodule]. Remember to commit in modified submodules!$(RESET)"; \
		fi; \
		cd $(CURDIR); \
	done
	@echo "[$(LOG_TIME)]$(GREEN)[$(PROJECT)]	[INFO]		Environment [$(NAME)] has been validated$(RESET)"

update_submodules:
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[INFO]		Initializing/updating submodules [$(LIBS_SUBMODULE)]...$(RESET)"
	@git submodule update --init --recursive
	@echo "[$(LOG_TIME)]$(GREEN)[$(PROJECT)]	[SUCCESS]	All submodules are now initialized and up to date!$(RESET)"

clone_repos:
	@if [ -z "$(LIBS_LOCAL)" ]; then \
		echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[INFO]		No local libraries to clone!$(RESET)"; \
	else \
		for library in $(LIBS_LOCAL); do \
			echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[INFO]		Cloning [$(BRIGHT_BLUE)$$library$(BLUE)] in $(LIBS_DIR)$$library$(RESET)"; \
			git clone $(GITHUB_URL)$$library.git $(LIBS_DIR)$$library; \
		done; \
		echo "[$(LOG_TIME)]$(GREEN)[$(PROJECT)]	[SUCCESS]  All needed libraries have been cloned!$(RESET)"; \
	fi

build-libs:
	@if [ -z "$(LIBS_CLEAN)" ]; then \
		echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[INFO]		No libraries to build.$(RESET)"; \
	else \
		echo "[$(LOG_TIME)]$(BRIGHT_BLUE)[$(PROJECT)]	[INFO]		Building libraries...$(RESET)"; \
		for lib_dir in $(LIBS_DIRS); do \
			echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[BUILD]		Building in $$lib_dir$(RESET)"; \
			$(MAKE) -C $$lib_dir; \
		done; \
	fi

re-build-libs:
	@if [ -z "$(LIBS_CLEAN)" ]; then \
		echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[INFO]		No libraries to rebuild.$(RESET)"; \
	else \
		@echo "[$(LOG_TIME)]$(BRIGHT_BLUE)[$(PROJECT)]	[INFO]		Rebuilding libraries...$(RESET)"; \
		@for lib_dir in $(LIBS_DIRS); do \
			echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[BUILD]		re-Building in $$lib_dir$(RESET)"; \
			$(MAKE) -C $$lib_dir re; \
		done; \
	fi

clean-deep:
	@if [ -z "$(LIBS_CLEAN)" ]; then \
		echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[INFO]  No libraries to clean.$(RESET)"; \
	else \
		echo "[$(LOG_TIME)]$(BRIGHT_RED)[$(PROJECT)]	[DEEP CLEAN]	Cleaning all dependent libraries: [$(LIBS)]...$(RESET)"; \
		for lib_dir in $(LIBS_DIRS); do \
			echo "[$(LOG_TIME)]$(RED)[$(PROJECT)]	[CLEAN]		Cleaning in $$lib_dir$(RESET)"; \
			$(MAKE) -C $$lib_dir clean; \
		done; \
		$(MAKE) clean; \
	fi

fclean-deep:
	@if [ -z "$(LIBS_CLEAN)" ]; then \
		echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[INFO]  No libraries to full clean.$(RESET)"; \
	else \
		echo "[$(LOG_TIME)]$(BRIGHT_RED)[$(PROJECT)]	[DEEP FCLEAN]	Full Cleaning all dependent libraries: [$(LIBS)]...$(RESET)"; \
		for lib_dir in $(LIBS_DIRS); do \
			echo "[$(LOG_TIME)]$(RED)[$(PROJECT)]	[FCLEAN]	Full cleaning in $$lib_dir$(RESET)"; \
			$(MAKE) -C $$lib_dir fclean; \
		done; \
		$(MAKE) fclean; \
	fi

re-deep:
	@if [ -z "$(LIBS_CLEAN)" ]; then \
		echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[INFO]  No libraries to re-make.$(RESET)"; \
	else \
		echo "[$(LOG_TIME)]$(BRIGHT_BLUE)[$(PROJECT)]	[REBUILD]	Completely rebuilding all libraries and project...$(RESET)"; \
		for lib_dir in $(LIBS_DIRS); do \
			echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[REBUILD]	Rebuilding in $$lib_dir$(RESET)"; \
			$(MAKE) -C $$lib_dir re; \
		done; \
		$(MAKE) re; \
	fi

# Debug
ASAN_CHECK := $(shell $(CC) -fsanitize=address -x c -c /dev/null -o /dev/null 2>/dev/null && echo "supported" || echo "not_supported")
debug: all
	@mkdir -p $(sort $(dir $(OBJS_DEBUG)))
	$(MAKE) validate_env NAME=$(NAME_DEBUG) OBJS=$(OBJS_DEBUG)
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[DEBUG]		Building debug version...$(RESET)"
	if [ "$(ASAN_CHECK)" = "supported" ]; then \
		echo "[$(LOG_TIME)]$(GREEN)[$(PROJECT)]	[INFO]		Address Sanitizer is supported and will be enabled$(RESET)"; \
		$(MAKE) build-libs; \
		$(MAKE) $(OBJS_DEBUG); \
		$(MAKE) --no-print-directory SANITIZE=yes debug-build; \
	else \
		echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[WARNING]	Address Sanitizer not enabled/supported, building with basic debug symbols$(RESET)"; \
		$(MAKE) build-libs; \
		$(MAKE) --no-print-directory debug-build_no_asan; \
	fi

debug-build: $(OBJS_DEBUG)
	@echo "[$(LOG_TIME)]$(BRIGHT_YELLOW)[$(PROJECT)]	[DEBUG]		Compiling [$(NAME_DEBUG)] exe...$(RESET)"
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) $(SANITIZE_COMPILE) \
	$(TEST_FILES) $(OBJS_DEBUG) -L. -l$(subst lib,,$(PROJECT)) $(LIBS_LINKS) -o $(NAME_DEBUG) $(SANITIZE_LINK)
	@echo "[$(LOG_TIME)]$(BRIGHT_GREEN)[$(PROJECT)]	[SUCCESS]	Debug build complete with: $(RESET)"
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[INFO]		- Debug symbols enabled$(RESET)"
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[INFO]		- Address sanitizer active (detects memory issues)$(RESET)"
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[INFO]		- Undefined behavior detection active$(RESET)"
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[INFO]		- Frame pointer preserved (for better backtraces)$(RESET)"
	@mv -f $(NAME_DEBUG) $(ASAN_LOGS) ./$(DEBUG_DIR) 2>/dev/null || true
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[INFO]		[$(NAME_DEBUG)] and [$(ASAN_LOGS)] in ./$(DEBUG_DIR) $(RESET)"

debug-build_no_asan: $(OBJS_DEBUG) #OBJS_DEBUG=$(...) NAME_DEBUG=$(...) LIBS_LINKS=$(...)
	@echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[DEBUG]		Compiling [$(NAME_DEBUG)] exe without sanitizers...$(RESET)"
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) $(TEST_FILES) $(OBJS_DEBUG) $(LIBS_LINKS) -o $(NAME_DEBUG)
	@echo "[$(LOG_TIME)]$(BRIGHT_GREEN)[$(PROJECT)]	[SUCCESS]	Debug build complete with basic debug symbols$(RESET)"
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[INFO]		[$(NAME_DEBUG)] in ./$(DEBUG_DIR) $(RESET)"

$(OBJS_DEBUG_DIR)%.o: $(SRCS_DIR)%.c $(DEPS)
ifeq ($(DETAILS),1)
	@echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[COMPILE]	Compiling: $< in $(OBJS_DEBUG_DIR)$(RESET)"
endif
ifeq ($(SANITIZE),yes)
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) $(SANITIZE_COMPILE) -c $< -o $@
else
	$(CC) $(CFLAGS) $(DEBUG_FLAGS) -c $< -o $@
endif

debug-run: debug
	@echo "[$(LOG_TIME)]$(BRIGHT_BLUE)[$(PROJECT)]	[DEBUG]		Running [$(NAME_DEBUG)] with sanitizers enabled...$(RESET)"
	./$(DEBUG_DIR)$(NAME_DEBUG)

leak-check: debug
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[DEBUG]		Running [$(NAME_DEBUG)] with leak detection...$(RESET)"
	ASAN_OPTIONS=detect_leaks=1 ./$(DEBUG_DIR)$(NAME_DEBUG)

debug-gdb: debug
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[DEBUG]		Starting [$(NAME_DEBUG)] with GDB session...$(RESET)"
	gdb -ex "set confirm off" -ex "b main" -ex "run" ./$(DEBUG_DIR)$(NAME_DEBUG)

clean-debug:
	@echo "[$(LOG_TIME)]$(RED)[$(PROJECT)]	[CLEAN]		Cleaning debug objed files...$(RESET)"
	$(RM) $(OBJS_DEBUG_DIR)

fclean-debug:
	@echo "[$(LOG_TIME)]$(BRIGHT_RED)[$(PROJECT)]	[FCLEAN]	Full cleaning: Removing [$(NAME_DEBUG) $(NAME_DEBUG_VAL) $(ASAN_LOGS)]...$(RESET)"
	$(RM) $(DEBUG_DIR)

re-debug:
	$(MAKE) debug-fclean
	$(MAKE) debug

debug-makeflags:
	@echo "[$(LOG_TIME)][$(PROJECT)]	MAKELEVEL: $(MAKELEVEL)"
	@echo "[$(LOG_TIME)][$(PROJECT)]	MAKEFLAGS: $(MAKEFLAGS)"
	@echo "[$(LOG_TIME)][$(PROJECT)]	Extracted -jN from MAKEFLAGS: $(filter -j%,$(MAKEFLAGS))"


# Valgrind configuration
VALGRIND_IMAGE_NAME	:= valgrind-env
VALGRIND_PERS_CONT	:= valgrind-persistent
VALGRIND_REPORT		:= valgrind_report.txt
NAME_DEBUG_VAL_PATH	:= $(DEBUG_DIR)$(NAME_DEBUG_VAL)
REPORT_PATH			:= $(DEBUG_DIR)$(VALGRIND_REPORT)
VALGRIND_DOCKERFILE	:= $(DOCKER_DIR)/Dockerfile
VALGRIND_FLAGS		:= --leak-check=full --show-leak-kinds=all --track-origins=yes

# Main Valgrind rule - detects environment and calls appropriate implementation
# Example: make valgrind ARGS='"1 2 3" "5 4 10"'(multiple argv); make valgrind ARGS="1 2 3 5 4 10" (unique argv)
valgrind:
ifeq ($(IS_LINUX),Linux)
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[VALGRIND]	Linux detected, running Valgrind natively...$(RESET)"
	@mkdir -p $(sort $(dir $(OBJS_DEBUG)))
	$(MAKE) valgrind-native
else
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[VALGRIND]	Non-Linux OS detected, using Docker-based Valgrind...$(RESET)"
	@mkdir -p $(sort $(dir $(OBJS_DOCKER)))
	@if [ "[$(LOG_TIME)]$(SLEEP)" = "1" ]; then \
		$(MAKE) valgrind-docker_sleep; \
	else \
		$(MAKE) valgrind-docker; \
	fi
endif
	@echo "[$(LOG_TIME)]$(GREEN)[$(PROJECT)]	[SUCCESS]	Valgrind analysis complete.$(RESET)"
	@echo "[$(LOG_TIME)]$(GREEN)[$(PROJECT)]	[SUCCESS]	Full report saved in $(REPORT_PATH)$(RESET)"
	$(MAKE) process-valgrind-report REPORT_PATH=$(VALGRIND_REPORT)
	@mv -f $(NAME_DEBUG_VAL) $(VALGRIND_REPORT) ./$(DEBUG_DIR) 2>/dev/null || true

valgrind-native:
	@echo "[$(LOG_TIME)]$(BRIGHT_BLUE)[$(PROJECT)]	[VALGRIND]	Running Valgrind analysis natively...$(RESET)"
	$(MAKE) validate_env OBJS=$(OBJS_DEBUG) NAME=$(NAME_DEBUG_VAL)
	@if ! command -v valgrind >/dev/null 2>&1; then \
		echo "[$(LOG_TIME)]$(RED)[$(PROJECT)]	[ERROR]	Valgrind is not installed. Please install it first.$(RESET)"; \
		echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[INFO]		Install with command: [sudo apt-get install valgrind]$(RESET)"; \
		exit 1; \
	fi; \
	$(MAKE) debug-build_no_asan NAME_DEBUG=$(NAME_DEBUG_VAL)
	@echo "[$(LOG_TIME)]$(BRIGHT_BLUE)[$(PROJECT)]	[VALGRIND]	Running memory analysis with Valgrind...$(RESET)"
	@echo "-----------------------------------------"
	@valgrind $(VALGRIND_FLAGS) --log-file=$(VALGRIND_REPORT) \
		./$(NAME_DEBUG_VAL) $(ARGS)
	@echo "\n-----------------------------------------"
	@mv -f $(NAME_DEBUG_VAL) ./$(DEBUG_DIR) 2>/dev/null

# Docker Valgrind setup
valgrind-docker-setup:
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[VALGRIND]	Preparing Docker Valgrind environment...$(RESET)"
	$(MAKE) validate_env OBJS=$(OBJS_DOCKER) NAME=$(NAME_DEBUG_VAL) 2>/dev/null || true
	@if ! command -v docker >/dev/null 2>&1; then \
		echo "[$(LOG_TIME)]$(RED)[$(PROJECT)]	[ERROR]	Docker is not installed. Please install Docker Desktop first.$(RESET)"; \
		exit 1; \
	fi
	@if ! docker info >/dev/null 2>&1; then \
		echo "[$(LOG_TIME)]$(RED)[$(PROJECT)]	[ERROR]	Docker daemon is not running. Please start Docker Desktop.$(RESET)"; \
		exit 1; \
	fi
	# Check if Docker image exists and build if needed
	@if ! docker image inspect $(VALGRIND_IMAGE_NAME) >/dev/null 2>&1; then \
		echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[VALGRIND]	Creating [$(VALGRIND_DOCKERFILE)] Dockerfile...$(RESET)"; \
		echo "FROM ubuntu:22.04" > $(VALGRIND_DOCKERFILE); \
		echo "ENV DEBIAN_FRONTEND=noninteractive" >> $(VALGRIND_DOCKERFILE); \
		echo "RUN apt-get update && apt-get install -y build-essential gcc make valgrind git && apt-get clean && rm -rf /var/lib/apt/lists/*" >> $(VALGRIND_DOCKERFILE); \
		echo "WORKDIR /app" >> $(VALGRIND_DOCKERFILE); \
		echo "[$(LOG_TIME)]$(BLUE)[VALGRIND]	Building Docker image with Valgrind...$(RESET)"; \
		docker build -q -t $(VALGRIND_IMAGE_NAME) -f $(VALGRIND_DOCKERFILE) . ; \
		echo "[$(LOG_TIME)]$(GREEN)[$(PROJECT)]	[SUCCESS]	Docker image [$(VALGRIND_IMAGE_NAME)] successfully created$(RESET)"; \
	else \
		echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[VALGRIND]	Using existing Docker image [$(VALGRIND_IMAGE_NAME)] for Valgrind...$(RESET)"; \
	fi

valgrind-docker: valgrind-docker-setup
	@echo "[$(LOG_TIME)]$(BRIGHT_BLUE)[$(PROJECT)]	[INFO]		Running Valgrind analysis inside docker container...$(RESET)"
	@docker run --rm \
		-v $(abspath ..):/parent \
		-w /parent/$(notdir $(CURDIR)) \
		$(VALGRIND_IMAGE_NAME) \
		/bin/bash -c " \
			export MAKE=/usr/bin/make && \
			echo -e '[$(LOG_TIME)]$(BRIGHT_CYAN)[$(PROJECT)]	[DOCKER]	Building debug version inside docker container...$(RESET)' && \
			\$$MAKE build-libs_docker DETAILS=$(DETAILS) && \
			\$$MAKE debug-build_no_asan DETAILS=$(DETAILS) \
			OBJS_DEBUG=\"$(OBJS_DOCKER)\" \
			OBJS_DEBUG_DIR=\"$(OBJS_DOCKER_DIR)\" \
			NAME_DEBUG=\"$(NAME_DEBUG_VAL)\" \
			LIBS_LINKS=\"$(LIBS_LINKS_DOCKER)\" \
			ASAN_CHECK=\"not_supported\" && \
			echo -e '[$(LOG_TIME)]$(CYAN)[$(PROJECT)]	[DOCKER]	Checking for executable...$(RESET)'; \
			if [ ! -f \"$(NAME_DEBUG_VAL)\" ]; then \
				echo -e '[$(LOG_TIME)]$(RED)[$(PROJECT)]	[DOCK-ERROR]	Debug executable not found. Something went wrong during compilation...$(RESET)'; \
				exit 1; \
			fi; \
			echo -e '[$(LOG_TIME)]$(BRIGHT_CYAN)[$(PROJECT)]	[DOCKER]	Valgrind build successfully compiled in docker container!$(RESET)' && \
			echo -e '[$(LOG_TIME)]$(BRIGHT_CYAN)[$(PROJECT)]	[DOCKER]	Running Valgrind analysis in docker container...$(RESET)' && \
			echo -e '-----------------------------------------' && \
			valgrind $(VALGRIND_FLAGS) --log-file=\"$(VALGRIND_REPORT)\" \
			\"./$(NAME_DEBUG_VAL)\" $(ARGS) && \
			echo -e '\n-----------------------------------------' && \
			mv -f \"$(NAME_DEBUG_VAL)\" \"./$(DEBUG_DIR)/\" 2>/dev/null "

valgrind-docker_sleep: valgrind-docker-setup valgrind-container-start
	@echo "[$(LOG_TIME)]$(BRIGHT_BLUE)[$(PROJECT)]	[INFO]		Running Valgrind analysis inside persistent docker container...$(RESET)"
	@docker exec $(VALGRIND_PERS_CONT) \
		/bin/bash -c " \
			export MAKE=/usr/bin/make && \
			echo -e '[$(LOG_TIME)]$(BRIGHT_CYAN)[$(PROJECT)]	[DOCK-INFO]	Building debug version inside docker container...$(RESET)' && \
			\$$MAKE build-libs_docker DETAILS=$(DETAILS) && \
			\$$MAKE debug-build_no_asan DETAILS=$(DETAILS) \
			OBJS_DEBUG=\"$(OBJS_DOCKER)\" \
			OBJS_DEBUG_DIR=\"$(OBJS_DOCKER_DIR)\" \
			NAME_DEBUG=\"$(NAME_DEBUG_VAL)\" \
			LIBS_LINKS=\"$(LIBS_LINKS_DOCKER)\" \
			ASAN_CHECK=\"not_supported\" && \
			echo -e '[$(LOG_TIME)]$(CYAN)[$(PROJECT)]	[DOCK-INFO]	Checking for executable...$(RESET)'; \
			if [ ! -f \"$(NAME_DEBUG_VAL)\" ]; then \
				echo -e '[$(LOG_TIME)]$(RED)[$(PROJECT)]	[DOCK-ERROR]	Debug executable not found. Something went wrong during compilation...$(RESET)'; \
				exit 1; \
			fi; \
			echo -e '[$(LOG_TIME)]$(BRIGHT_CYAN)[$(PROJECT)]	[DOCK-BUILD]	Valgrind build successfully compiled in docker container!$(RESET)' && \
			echo -e '[$(LOG_TIME)]$(BRIGHT_CYAN)[$(PROJECT)]	[DOCK-RUN]	Running Valgrind analysis in docker container...$(RESET)' && \
			valgrind $(VALGRIND_FLAGS) --log-file=\"/app/$(VALGRIND_REPORT)\" \
			echo -e '\-----------------------------------------' && \
			\"./$(NAME_DEBUG_VAL)\" $(ARGS) && \
			echo -e '\n-----------------------------------------' && \
			mv -f \"$(NAME_DEBUG_VAL)\" \"./$(DEBUG_DIR)/\" 2>/dev/null "

valgrind-container-start:
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[VALGRIND]	Starting persistent Valgrind container...$(RESET)"
	@if ! docker ps -a --format '{{.Names}}' | grep -q $(VALGRIND_PERS_CONT); then \
		echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[VALGRIND]	Creating [$(VALGRIND_PERS_CONT)] container...$(RESET)"; \
		docker run -d --name $(VALGRIND_PERS_CONT) \
			-v $(abspath ..):/parent \
			-w /parent/$(notdir $(CURDIR)) \
			$(VALGRIND_IMAGE_NAME) \
			sleep infinity \
			| xargs -I {} printf "$(BLUE)[$(PROJECT)]	[DOCK-INFO]	[$(VALGRIND_PERS_CONT)] ID: {}$(RESET)\n"; \
	elif ! docker ps --format '{{.Names}}' | grep -q $(VALGRIND_PERS_CONT); then \
		echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[VALGRIND]	Starting existing [$(VALGRIND_PERS_CONT)] container...$(RESET)"; \
		docker start $(VALGRIND_PERS_CONT); \
	else \
		echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[VALGRIND]	Container [$(VALGRIND_PERS_CONT)] already running$(RESET)"; \
	fi

valgrind-container-stop:
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[DOCK-INFO]	Stopping [$(VALGRIND_PERS_CONT)] docker container...$(RESET)"
	@if docker ps --format '{{.Names}}' | grep -q $(VALGRIND_PERS_CONT); then \
		docker stop valgrind-persistent 1>/dev/null && \
		echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[DOCK-INFO]	Container [$(VALGRIND_PERS_CONT)] successfully stopped!$(RESET)"; \
	fi
	@if docker ps -a --format '{{.Names}}' | grep -q $(VALGRIND_PERS_CONT); then \
		docker rm $(VALGRIND_PERS_CONT) 1>/dev/null && \
		echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[DOCK-INFO]	Container [$(VALGRIND_PERS_CONT)] successfully removed!$(RESET)"; \
	fi

build-libs_docker:
	@if [ -z "$(LIBS)" ]; then \
		echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[INFO]  No libraries to build.$(RESET)"; \
	else \
		echo "[$(LOG_TIME)]$(BRIGHT_BLUE)[$(PROJECT)]	[DOCK-INFO]	Building docker libraries without relinking...$(RESET)"; \
		for lib_dir in $(LIBS_DIRS); do \
			NAME=$$(basename "$$lib_dir")_docker.a; \
			$(MAKE) -C "$$lib_dir" NAME="$$NAME" 1>/dev/null 2>/dev/null; \
			LIB_FILE="$$lib_dir/$$NAME"; \
			if [ -f "$$LIB_FILE" ]; then \
				cp -f "$$LIB_FILE" "$(DOCKER_DIR)$$NAME"; \
			else \
				echo "[$(LOG_TIME)]$(RED)[$(PROJECT)]	[DOCK-ERROR]	Library $$NAME was not generated in $$lib_dir!$(RESET)"; \
				exit 1; \
			fi; \
		done; \
		echo "[$(LOG_TIME)]$(GREEN)[$(PROJECT)]	[DOCK-SUCCESS]	All docker_libraries built and copied to $(DOCKER_DIR) $(RESET)"; \
	fi

# Memory allocation and access errors
VALGRIND_MEM_ACCESS	= "Invalid read" "Invalid write" "Jump to the invalid address" \
					  "Address .* is .* bytes after a block of size" "Address .* is .* bytes before a block of size" \
					  ".* bytes in .* blocks are definitely lost"

# Memory management errors
VALGRIND_MEM_MGMT	= "Invalid free" "Mismatched free" "Invalid memory pool address"

# Uninitialized value errors
VALGRIND_UNINIT		= "Uninitialised value" "Use of uninitialised value" \
					  "Conditional jump or move depends on uninitialised value"
# Other errors
VALGRIND_OTHER		= "Source and destination overlap" "Syscall param" \
					  "Process terminating with non-zero status"

VALGRIND_ERRORS		= $(VALGRIND_MEM_ACCESS) $(VALGRIND_MEM_MGMT) $(VALGRIND_UNINIT) $(VALGRIND_OTHER)

process-valgrind-report: #REPORT_PATH=$() full path needed es. ./valgrind_report.txt , standard one is debug/valgrind_report.txt
	@if [ ! -f "$(REPORT_PATH)" ]; then \
		echo "[$(LOG_TIME)]$(RED)[$(PROJECT)]	[VAL-ERROR]	Valgrind report not found at $(REPORT_PATH).$(RESET)"; \
		exit 1; \
	fi; \
	echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[VAL-INFO]	Processing memory analysis results...$(RESET)"; \
	if grep -q "ERROR SUMMARY: [1-9]" "$(REPORT_PATH)"; then \
		error_count=$$(grep "ERROR SUMMARY" "$(REPORT_PATH)" | awk '{print $$4}'); \
		echo "[$(LOG_TIME)]$(BRIGHT_RED)[$(PROJECT)]	[VAL-ERROR]	$$error_count memory errors detected$(RESET)"; \
		\
		for error in $(VALGRIND_ERRORS); do \
			if grep -q "$$error" "$(REPORT_PATH)"; then \
				display_error=$$(echo "$$error" | sed 's/"//g'); \
				echo "[$(LOG_TIME)]$(RED)[$(PROJECT)]	[VAL-ERROR]	$$display_error detected:$(RESET)"; \
				\
				error_line=$$(grep -n "$$error" "$(REPORT_PATH)" | head -1 | cut -d: -f1); \
				awk -v line=$$error_line -v err="$$error" ' \
					BEGIN { found=0; printed=0; } \
					NR >= line { \
						if ($$0 ~ err && found == 0) { \
							found=1; \
							print; \
							printed++; \
						} else if (found == 1) { \
							if ($$0 ~ /^==.*== $$/) { \
								exit; \
							} \
							print; \
							printed++; \
							if (printed >= 20) exit; \
						} \
					}' "$(REPORT_PATH)"; \
				\
				count=$$(grep -c "$$error" "$(REPORT_PATH)"); \
				if [ "$$count" -gt 1 ]; then \
					echo "[$(LOG_TIME)]$(YELLOW)[$(PROJECT)]	[INFO]	... ($$count total occurrences of this error type) ...$(RESET)"; \
				fi; \
			fi; \
		done; \
	else \
		echo "[$(LOG_TIME)]$(BRIGHT_GREEN)[$(PROJECT)]	[VAL-SUCCESS]	No memory errors detected.$(RESET)"; \
	fi; \
	if grep -q "LEAK SUMMARY:" "$(REPORT_PATH)"; then \
		echo "[$(LOG_TIME)]$(BRIGHT_RED)[$(PROJECT)]	[VAL-ERROR]	Memory leaks detected:$(RESET)"; \
		echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[VAL-INFO]	Memory leak summary:$(RESET)"; \
		grep -A 5 "LEAK SUMMARY" "$(REPORT_PATH)"; \
	else \
		echo "[$(LOG_TIME)]$(BRIGHT_GREEN)[$(PROJECT)]	[VAL-SUCCESS]	No memory leaks detected.$(RESET)"; \
	fi; \
	echo "[$(LOG_TIME)]$(BRIGHT_YELLOW)[$(PROJECT)]	[WARNING]	Always double-check full details available in: $(DEBUG_DIR)$(VALGRIND_REPORT)$(RESET)";

re-valgrind:
	@echo "[$(LOG_TIME)]$(BLUE)[$(PROJECT)]	[INFO]		Rebuilding valgrind version from scratch$(RESET)"
ifeq ($(IS_LINUX),Linux)
	$(RM) $(OBJS_DEBUG_DIR)
else
	$(RM) $(OBJS_DOCKER_DIR)
endif
	$(RM) $(NAME_DEBUG_VAL_PATH) $(REPORT_PATH)
	$(MAKE) valgrind

# Help command
help:
	@echo ""
	@echo "$(BLUE)Configuration:$(RESET)"
	@echo "  Compiler:		$(YELLOW)$(CC)$(RESET)"
	@echo "  Flags:		$(YELLOW)$(CFLAGS)$(RESET)"
	@echo "  Debug Flags:		$(YELLOW)$(DEBUG_FLAGS)$(RESET)"
	@echo "  Valgrind Flags	$(YELLOW)$(VALGRIND_FLAGS)$(RESET)"
	@echo ""
	@echo "$(BLUE)Compile & debug info:$(RESET)"
	@echo "  Address Sanitizer:	$(ASAN_CHECK)"
	@echo "  Sources:		$(words $(SRCS)) files"
	@echo "  Objects:		$(words $(OBJS)) files"
	@echo "  Debug Objects:	$(words $(OBJS_DEBUG)) files\n"
	@echo "  Sources:		$(SRCS)\n"
	@echo "  Objects:		$(OBJS)\n"
	@echo "  Debug Objects:	$(OBJS_DEBUG)\n"
	@echo "  Libraries:	$(LIBS)\n"
	@echo ""
	@echo "$(BRIGHT_BLUE)+- Available Commands -----------------+ $(RESET)"
	@echo ""
	@echo "$(BLUE)Main Commands: $(RESET)"
	@echo "  $(GREEN)make all$(RESET)					-  $(WHITE)Build the project (default)$(RESET)"
	@echo "  $(GREEN)make test$(RESET)					-  $(WHITE)Build the project and links it with TEST_FILES to make an exe$(RESET)"
	@echo "  $(GREEN)make validate_env$(RESET)				-  $(WHITE)Checks if directory environment is set up$(RESET)"
	@echo "  $(GREEN)make update_submodules$(RESET)			-  $(WHITE)Initialize and update all submodules$(RESET)"
	@echo "  $(GREEN)make clone_repos$(RESET)				-  $(WHITE)Clone necessary repositories for local libraries$(RESET)"
	@echo "  $(GREEN)make build-libs$(RESET)				-  $(WHITE)Build all dependent libraries$(RESET)"
	@echo "  $(GREEN)make re-build-libs$(RESET)				-  $(WHITE)Rebuild all dependent libraries$(RESET)"
	@echo "  $(GREEN)make re$(RESET)					-  $(WHITE)Rebuild current project from scratch$(RESET)"
	@echo "  $(RED)make clean$(RESET)					-  $(WHITE)Remove object files$(RESET)"
	@echo "  $(RED)make fclean$(RESET)					-  $(WHITE)Remove all generated files$(RESET)"
	@echo "  $(GREEN)make re-deep$(RESET)					-  $(WHITE)Rebuild all libraries and project from scratch$(RESET)"
	@echo "  $(RED)make clean-deep$(RESET)				-  $(WHITE)Clean all libraries and project objects$(RESET)"
	@echo "  $(RED)make fclean-deep$(RESET)				-  $(WHITE)Full clean of all libraries and project$(RESET)"
	@echo ""
	@echo "$(BLUE)Debug Commands: $(RESET)"
	@echo "  $(CYAN)make debug$(RESET)					-  $(WHITE)Build with sanitizers for leak and error detection$(RESET)"
	@echo "  $(CYAN)make debug-run$(RESET)				-  $(WHITE)Run the program with sanitizers$(RESET)"
	@echo "  $(CYAN)make leak-check$(RESET)				-  $(WHITE)Memory leak detection with AddressSanitizer$(RESET)"
	@echo "  $(CYAN)make debug-gdb$(RESET)				-  $(WHITE)Build and debug with GDB$(RESET)"
	@echo "  $(GREEN)make re-debug$(RESET)					-  $(WHITE)Rebuild current debug version from scratch$(RESET)"
	@echo "  $(RED)make clean-debug$(RESET)				-  $(WHITE)Remove debug objects$(RESET)"
	@echo "  $(RED)make fclean-debug$(RESET)				-  $(WHITE)Remove all generated debug files$(RESET)"
	@echo "  $(CYAN)make debug-makeflags$(RESET)				-  $(WHITE)Display make flags information$(RESET)"
	@echo ""
	@echo "$(BLUE)Valgrind Commands: $(RESET)"
	@echo "  $(CYAN)make valgrind$(RESET)					-  $(WHITE)Auto-selects best Valgrind method for your platform (default)$(RESET)"
	@echo "  $(CYAN)make valgrind-native$(RESET)				-  $(WHITE)Run Valgrind natively (Linux only)$(RESET)"
	@echo "  $(CYAN)make valgrind-docker$(RESET)				-  $(WHITE)Run Valgrind via Docker (any platform)$(RESET)"
	@echo "  $(CYAN)make valgrind-docker_sleep$(RESET)			-  $(WHITE)Run Valgrind in persistent Docker container$(RESET)"
	@echo "  $(CYAN)make valgrind-container-start$(RESET)			-  $(WHITE)Start persistent Valgrind container$(RESET)"
	@echo "  $(CYAN)make valgrind-container-stop$(RESET)			-  $(WHITE)Stop and remove persistent Valgrind container$(RESET)"
	@echo "  $(CYAN)make process-valgrind-report$(RESET)			-  $(WHITE)Process and display Valgrind report$(RESET)"
	@echo "  $(GREEN)make re-valgrind$(RESET)				-  $(WHITE)Rebuild and run Valgrind from scratch$(RESET)"
	@echo "  $(CYAN)make build-libs_docker$(RESET)			-  $(WHITE)Build libraries from Docker environment (Linux)$(RESET)"
	@echo ""
	@echo "$(BLUE)Options: $(RESET)"
	@echo "  Add $(MAGENTA)VERBOSE=1$(RESET)					-  $(WHITE)For detailed output$(RESET)"
	@echo "  Add $(MAGENTA)DETAILS=1$(RESET)					-  $(WHITE)For detailed files compilation$(RESET)"
	@echo "  Add $(MAGENTA)DEBUG=1$(RESET)					-  $(WHITE)For debug mode -> Use #ifdef DEBUG ... #endif for debug commands$(RESET)"
	@echo "  Add $(MAGENTA)SLEEP=1$(RESET)					-  $(WHITE)For Docker valgrind in persistent container. Remember to run make valgrind-container-stop when needed$(RESET)"
	@echo "  Add $(MAGENTA)ARGS=\"...\"$(RESET)				-  $(WHITE)To pass arguments to valgrind tests. For multiple arguments use: ARGS='\"...\" \"...\"'$(RESET)"
	@echo ""
	@echo "$(BRIGHT_BLUE)+--------------------------------------+ $(RESET)"

.PHONY: all clean fclean re validate_env update_submodules clone_repos build-libs re-build-libs \
	clean-deep fclean-deep re-deep \
	debug debug-build debug-build_no_asan debug-run leak-check debug-gdb clean-debug fclean-debug re-debug debug-makeflags \
	valgrind valgrind-native valgrind-docker valgrind-docker-setup valgrind-docker_sleep \
	valgrind-container-start valgrind-container-stop build-libs_docker process-valgrind-report re-valgrind \
	help
