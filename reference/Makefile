CC := clang
CXX := clang++

CFLAGS := -g -Wall
CXXFLAGS := -g -Wall --std=c++17

.SILENT:
.SUFFIXES:

ifndef SRC_ROOT
SRC_ROOT := $(CURDIR)
endif

ifndef BUILD_ROOT
BUILD_ROOT := $(SRC_ROOT)/build
endif

GLOBAL_DEP := $(SRC_ROOT)/mt19937.h
OBJ_FILES := $(BUILD_ROOT)/mt19937ar.o $(BUILD_ROOT)/mt19937-64.o
OBJXX_FILES := $(BUILD_ROOT)/mt_output.o

OUTPUT_EXE := $(BUILD_ROOT)/mt_output

.PHONY: default
default: build
	@echo "Generating reference output."
	$(OUTPUT_EXE)

.PHONY: build
build: $(OUTPUT_EXE)

$(OUTPUT_EXE): $(OBJ_FILES) $(OBJXX_FILES)
	$(CXX) $(CXXFLAGS) -lstdc++ $^ -o $@

$(OBJ_FILES): $(BUILD_ROOT)/%.o: $(SRC_ROOT)/%.c $(GLOBAL_DEP)
$(OBJXX_FILES): $(BUILD_ROOT)/%.o: $(SRC_ROOT)/%.cpp $(GLOBAL_DEP)

$(OBJ_FILES):
	-mkdir -p $(@D)
	$(CC) -c -o $@ $(CFLAGS) $<
	@echo "$(<F)"

$(OBJXX_FILES):
	-mkdir -p $(@D)
	$(CXX) -c -o $@ $(CXXFLAGS) $<
	@echo "$(<F)"

.PHONY: clean
clean:
	-rm -rf "$(BUILD_ROOT)"
