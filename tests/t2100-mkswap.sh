#!/bin/sh

# Copyright (C) 2007, 2009-2010 Free Software Foundation, Inc.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

test_description='create linux-swap partitions'

: ${srcdir=.}
. $srcdir/test-lib.sh

require_512_byte_sector_size_

######################################################################
# When creating a partition of type linux-swap(v1) in a DOS partition
# table, ensure that the proper file system type (0x82) is used.
# Some releases, e.g. parted-1.8.8 would mistakenly use 0x83.
######################################################################
N=2M
dev=loop-file
dev2=loop-file-2
test_expect_success \
    'create a file to simulate the underlying device' \
    'dd if=/dev/null of=$dev bs=1 seek=$N 2> /dev/null'

test_expect_success \
    'label the test disk' \
    'parted -s $dev mklabel msdos > out 2>&1'
test_expect_success 'expect no output' 'compare out /dev/null'

test_expect_success \
    'create a partition' \
    'parted -s $dev mkpart primary 2048s 4095s > out 2>&1'
test_expect_success 'expect no output' 'compare out /dev/null'

test_expect_success \
    'create a linux-swap file system' \
    'parted -s $dev mkfs 1 "linux-swap(v1)" > out 2>&1'
test_expect_success 'expect no output' 'compare out /dev/null'

# Extract the byte at offset 451.  It must be 0x82, not 0x83.
test_expect_success \
    'extract byte 451 (fs-type)' \
    'od -t x1 -An -j450 -N1 $dev > out && echo " 82" > exp'
test_expect_success 'expect it to be 82, not 83' 'compare out exp'

test_expect_success \
    'create another file to simulate the underlying device' \
    'dd if=/dev/null of=$dev2 bs=1 seek=$N 2> /dev/null'

test_expect_success \
    'label another test disk' \
    'parted -s $dev2 mklabel msdos > out 2>&1'
test_expect_success 'expect no output' 'compare out /dev/null'

test_expect_success \
    'create another partition' \
    'parted -s $dev2 mkpart primary 2048s 4095s > out 2>&1'
test_expect_success 'expect no output' 'compare out /dev/null'

test_expect_success \
    'create another linux-swap file system' \
    'parted -s $dev2 mkfs 1 "linux-swap(v1)" > out 2>&1'
test_expect_success 'expect no output' 'compare out /dev/null'

# partition starts at offset 1048576; swap UUID is 1036 bytes in
test_expect_success \
    'extract UUID 1' \
    'od -t x1 -An -j1049612 -N16 $dev > uuid1'
test_expect_success \
    'extract UUID 2' \
    'od -t x1 -An -j1049612 -N16 $dev2 > uuid2'
test_expect_failure \
    'two linux-swap file systems have different UUIDs' \
    'compare uuid1 uuid2'

test_expect_success \
    'check linux-swap file system' \
    'parted -s $dev2 check 1 > out 2>&1'
test_expect_success 'expect no output' 'compare out /dev/null'

test_expect_success \
    'extract new UUID 2' \
    'od -t x1 -An -j1049612 -N16 $dev2 > uuid2-new'
test_expect_success \
    'check preserves linux-swap UUID' \
    'compare uuid2 uuid2-new'

test_expect_success \
    'create a linux-swap file system via alias' \
    'parted -s $dev mkfs 1 linux-swap > out 2>&1'
test_expect_success 'expect no output' 'compare out /dev/null'

test_done
