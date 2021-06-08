dbus = Module("dbus"
dbusproxy = Module("dbusproxy"

$UPower = dbusproxy.Proxy + @
	$__initialize = @(connection) dbusproxy.Proxy.__initialize[$](connection, "org.freedesktop.UPower", "/org/freedesktop/UPower", "org.freedesktop.UPower"
	$enumerate_devices = @ $call($method("EnumerateDevices"

$Device = dbusproxy.Proxy + @
	$__initialize = @(connection, path) dbusproxy.Proxy.__initialize[$](connection, "org.freedesktop.UPower", path, "org.freedesktop.UPower.Device"
