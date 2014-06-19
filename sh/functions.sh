# Compatibility layer for netifrc to work with multiple init
# systems.

# First check whether e* commands are present in the environment
# XXX [[-n RC_GOT_FUNCTIONS]] ??
if [ -n "$(command -v ebegin >/dev/null 2>&1)" ]; then
	:

# Then check for the presence of functions.sh
elif [ -f /lib/gentoo/functions.sh ]; then
	. /lib/gentoo/functions.sh

else
	echo "/lib/gentoo/functions.sh not found. Exiting"
	exit -1
fi

# runscript functions
if [ -z "$(command -v service_set_value >/dev/null 2>&1)" ]; then

	# OpenRC functions used in depend
	after() {
		:
	}
	before() {
		:
	}
	program() {
		:
	}
	need() {
		:
	}

	shell_var() {
		local output=$1 sanitized_arg=
		shift 1
		for arg; do
			sanitized_arg="${arg//[^a-zA-Z0-9_]/_}"
			output="$output $arg"
		done
		echo "$output"
	}

	net_fs_list="afs ceph cifs coda davfs fuse fuse.sshfs gfs glusterfs lustre ncpfs nfs nfs4 ocfs2 shfs smbfs"
	is_net_fs()
	{
		[ -z "$1" ] && return 1

		local fs=$(mount | grep " on $1 " | cut -f 5 -d ' ')
		for x in $fs; do
			for y in $net_fs_list; do
				[ "$x" = "$y" ] && return 0
			done
		done
		return 1
	}

	service_set_value() {
		local OPTION="$1" VALUE="$2"
		if [ -z "$OPTION" ]; then
			eerror "service_set_value requires parameter KEY"
			return
		fi
		local file="$OPTIONSDIR/${OPTION}"
		echo "$VALUE" > $file
	}
	service_get_value() {
		local OPTION="$1"
		if [ -z "$OPTION" ]; then
			eerror "service_get_value requires parameter KEY"
			return
		fi
		local file="$OPTIONSDIR/${OPTION}"
		cat $file 2>/dev/null
	}
	mark_service_started() {
		:
	}
	mark_service_inactive() {
		:
	}
	mark_service_stopped() {
		:
	}
	service_started() {
		:
	}
	service_inactive() {
		:
	}
fi

# Extracts the interface for the current invocation
get_interface() {
	case $INIT in
		openrc)
			printf ${RC_SVCNAME#*.};;
		systemd)
			printf ${RC_IFACE};;
		*)
			eerror "Init system not supported. Aborting"
			exit -1;;
	esac
}

# vim: ts=4 sw=4 noexpandtab
