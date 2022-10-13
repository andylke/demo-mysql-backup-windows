echo off

for /F "tokens=* USEBACKQ" %%a IN (`powershell -c "get-date -format yyyyMMdd_HHmmss"`) do (
    set run_timestamp=%%a
)
set run_properties_filename=%~n0.properties

set vars_filename=%run_properties_filename%
for /F "eol=# delims== tokens=1,*" %%a in (%~dp0%vars_filename%) do (
    if not "%%a"=="" (
		set %%a=%%b
	)
)
