MAKE = /usr/bin/make

AR = /usr/bin/ar

#EXTERNAL_LIBRARY_PATH = /usr/local/lib
EXTERNAL_LIBRARY_PATH = /usr/local/lib64

BIN_PATH = /usr/local/bin

OBJ := $(patsubst %.f90, %.o, $(wildcard *.f90))

OBJ_DIRECTORY = ../objs

OBJS = $(addprefix $(OBJ_DIRECTORY)/, $(OBJ))

LIB_DIRECTORY = ../lib

LIB_NAME = modern_fftpack

LIB = $(LIB_DIRECTORY)/lib$(LIB_NAME).a

MOD_DIRECTORY = $(LIB_DIRECTORY)

FC = gfortran-6

FFLAGS = -O3 -fimplicit-none -Wall
