echo off

call backup_vars

cls
echo.
echo db_hostname=[%db_hostname%]
echo db_port=[%db_port%]
echo db_username=[%db_username%]
echo db_password=[%db_password%]
echo.

set /p continue="<< BACKUP DATABASE >> for [%run_env%] ? (y/n)"
if not "%continue%"=="y" (
	exit /b
)

if not exist "..\backup" (
    mkdir "..\backup"
)
set backup_filename=..\backup\%run_timestamp%_%run_env%-backup.sql
set backup_log_filename=..\backup\%run_timestamp%_%run_env%-backup.log

echo.
echo ## backing up data to file [%backup_filename%], error log [%backup_log_filename%]
echo.

mysqldump -h %db_hostname% -P %db_port% -u %db_username% -p%db_password% --replace --complete-insert --skip-comments --log-error=%backup_log_filename% --databases %backup_schemas% >> %backup_filename%

for %%a in ("%backup_log_filename%") do ( 
    if not "%%~za"=="0" (
        echo.
        echo ## backup data exited with error
        echo.
		type "%%a"
        echo.

        echo.
    	echo aborting [%run_name%] for [%run_env%] - [%run_timestamp%]
        echo.
        pause
        exit 1
	)
)

7z a -tzip -mx6 %backup_filename%.zip %backup_filename%

echo.
for %%a in ("%backup_filename%") do ( 
    echo ## completed database backup to file [%backup_filename%] with size [%%~za]
)
echo.

pause
