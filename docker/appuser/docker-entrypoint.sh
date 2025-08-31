#!/bin/ash
set -e

# get current uid/gid for user mosquitto
APP_UID=$(/usr/bin/id -u mosquitto)
APP_GID=$(/usr/bin/id -g mosquitto)

# prepare user/group and permissions
if [ "$(/usr/bin/id -u)" != '0' ]; then
	# some debugging info
	echo "running as: $(/usr/bin/id)"
elif [[ "${HOST_GID}" != "${APP_GID}" ]] || [[ "${HOST_UID}" != "${APP_UID}" ]]; then
	# change user/group to HOST_UID/HOST_GID
	[[ "${HOST_GID}" != "${APP_GID}" ]] && /usr/sbin/groupmod --gid "${HOST_GID}" mosquitto 2>/dev/null || true
	[[ "${HOST_UID}" != "${APP_UID}" ]] && /usr/sbin/usermod --uid "${HOST_UID}" --gid "${HOST_GID}" --groups mosquitto mosquitto 2>/dev/null || true
	# change owner of /app
	[ -d "/mosquitto" ] && /bin/chown --recursive "${HOST_UID}:${HOST_GID}" /mosquitto 2>/dev/null || true
fi

# execute CMD
if [ "$(/usr/bin/id -u)" != '0' ]; then
	# already running as unprivileged user
	exec "$@"
else
	[ -x /usr/bin/setuidgid ] || apk --no-cache add daemontools-encore
	# drop from root to mosquitto
	/usr/bin/setuidgid mosquitto "$@"
fi
