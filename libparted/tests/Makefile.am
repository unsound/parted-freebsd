# This file is part of GNU Parted
# Copyright (C) 1999-2001, 2007-2010 Free Software Foundation, Inc.
#
# This file may be modified and/or distributed without restriction.

TESTS = t1000-label.sh t2000-disk.sh t3000-symlink.sh
EXTRA_DIST = $(TESTS)
check_PROGRAMS = label disk symlink
AM_CFLAGS = $(WARN_CFLAGS) $(WERROR_CFLAGS)

LDADD = \
  $(top_builddir)/libparted/libparted.la \
  $(CHECK_LIBS)

AM_CPPFLAGS = \
  $(CHECK_CFLAGS) \
  -I$(top_srcdir)/lib \
  -I$(top_srcdir)/include

label_SOURCES = common.h common.c label.c
disk_SOURCES  = common.h common.c disk.c
symlink_SOURCES = common.h common.c symlink.c

MAINTAINERCLEANFILES = Makefile.in

CLEANFILES = old-init.sh
all: old-init.sh
old-init.sh: Makefile.in
	rm -f $@-t $@
	echo 'PARTED_USABLE_TEST_DIR="$(PARTED_USABLE_TEST_DIR)"' > $@-t
	echo 'abs_top_srcdir="$(abs_top_srcdir)"' >> $@-t
	echo 'PATH="$(abs_builddir)$(PATH_SEPARATOR)$$PATH"; export PATH' >> $@-t
	chmod a-w $@-t
	mv $@-t $@

TESTS_ENVIRONMENT = \
  top_srcdir='$(top_srcdir)'
