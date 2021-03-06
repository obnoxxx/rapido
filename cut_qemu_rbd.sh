#!/bin/bash
#
# Copyright (C) SUSE LINUX GmbH 2016, all rights reserved.
#
# This library is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation; either version 2.1 of the License, or
# (at your option) version 3.
#
# This library is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public
# License for more details.

RAPIDO_DIR="$(realpath -e ${0%/*})"
. "${RAPIDO_DIR}/runtime.vars"

_rt_require_dracut_args

dracut  --install "tail blockdev ps rmdir resize dd vim grep find df sha256sum \
		   strace mkfs.xfs /lib64/libkeyutils.so.1 lsscsi" \
	--include "$RAPIDO_DIR/rapido.conf" "/rapido.conf" \
	--include "$RAPIDO_DIR/vm_autorun.env" "/.profile" \
	--modules "bash base network ifcfg" \
	$DRACUT_EXTRA_ARGS \
	$DRACUT_OUT

# set qemu arguments to attach the RBD image. qemu uses librbd, and supports
# writeback caching via a "cache=writeback" parameter.
qemu_cut_args="-drive format=rbd,file=rbd:${CEPH_RBD_POOL}/${CEPH_RBD_IMAGE}"
qemu_cut_args="${qemu_cut_args}:conf=${CEPH_CONF},if=virtio,cache=none,format=raw"
setfattr -n "$QEMU_ARGS_XATTR" -v "$qemu_cut_args" $DRACUT_OUT \
	|| _fail "failed to set xattr on $DRACUT_OUT"
