CC=gcc
SRC=airport-bssid/main.m
FRAMEWORKS:= -framework Foundation -framework CoreWLAN
LIB:= -lobjc
CFLAGS=-Wall -Werror -v
TARGET=Build/airport-bssid

all: $(SRC) $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) -o $(OBJECTS) $@ $(CFLAGS) $(LIB) $(FRAMEWORKS) -o $(TARGET) $(SRC)

.m.o:
	$(CC) -c -Wall $< -o $@
