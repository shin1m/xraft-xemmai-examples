dbus = Module("dbus");
dbusproxy = Module("dbusproxy");

$UPower = Class(dbusproxy.Proxy) :: @{
	$__initialize = @(connection) :$^__initialize[$](connection, "org.freedesktop.UPower", "/org/freedesktop/UPower", "org.freedesktop.UPower");
	$enumerate_devices = @() $call($method("EnumerateDevices"));
};

$Device = Class(dbusproxy.Proxy) :: @{
	$__initialize = @(connection, path) :$^__initialize[$](connection, "org.freedesktop.UPower", path, "org.freedesktop.UPower.Device");
};
