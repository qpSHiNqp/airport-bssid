CC=gcc
SRC=airport-bssid/main.m
FRAMEWORKS:= -framework Foundation -framework CoreWLAN -framework CoreLocation
LIB:= -lobjc
CFLAGS=-Wall -Werror -v
TARGET=Build/airport-bssid
OBJECTS=$(SRC:%.m=%.o)

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CC) $^ $(CFLAGS) $(LIB) $(FRAMEWORKS) -o $@

.m.o:
	$(CC) -c -Wall $< -o $@
