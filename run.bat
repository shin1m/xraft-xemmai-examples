set XRAFT_ROOT=%~dp0..\xraft\
set CONFIGURATION=Debug
path %PATH%;%XRAFT_ROOT%%CONFIGURATION%
set XEMMAI_MODULE_PATH=%XRAFT_ROOT%%CONFIGURATION%
"%XRAFT_ROOT%%CONFIGURATION%\xemmai" --verbose %1
