#!/bin/ash
set -e

# get current uid/gid for user mosquitto
APP_UID=$(/usr/bin/id -u mosquitto)
APP_GID=$(/usr/bin/id -g mosquitto)

# prepare user/group and permissions
if [ "$(/usr/bin/id -u)" != '0' ]; then
	# some debugging info
	echo "running as: $(/usr/bin/id)"
elif [[ "${HOST_GID}" != "${APP_GID}" -o "${HOST_UID}" != "${APP_UID}" ]]; then
	# change user/group to HOST_UID/HOST_GID
	/usr/sbin/groupmod --gid "${HOST_GID}" mosquitto 2>/dev/null || true
	/usr/sbin/usermod --uid "${HOST_UID}" --gid mosquitto mosquitto 2>/dev/null || true
	# change owner of /app
	[ -d "/app" ] && /bin/chown --recursive mosquitto:mosquitto /mosquitto 2>/dev/null || true
else
	# nothing to do
fi

# execute CMD
if [ "$(/usr/bin/id -u)" != '0' ]; then
	# already running as unprivileged user
	exec "$@"
else
	# drop from root to appuser
	/usr/bin/setuidgid appuser "$@"
fi
