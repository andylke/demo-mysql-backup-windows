echo off

call backup_vars

cls
echo.
echo db_hostname=[%db_hostname%]
echo db_port=[%db_port%]
echo db_username=[%db_username%]
echo db_password=[%db_password%]
echo.

cls
set /p continue="<< BACKUP STRUCTURE >> for [%run_env%] ? (y/n)"
if not "%continue%"=="y" (
    exit /b
)

if not exist "..\backup" (
    mkdir "..\backup"
)
set backup_structure_filename=..\backup\%run_timestamp%_%run_env%-structure_backup.sql
set backup_log_filename=..\backup\%run_timestamp%_%run_env%-backup.log


echo.
echo ## backing up structures to file [%backup_structure_filename%], error log [%backup_log_filename%]
echo.

mysqldump -h %db_hostname% -P %db_port% -u %db_username% -p%db_password% --no-data --skip-comments --log-error=%backup_log_filename% --databases %backup_schemas% > %backup_structure_filename%

for %%a in ("%backup_log_filename%") do ( 
    if not "%%~za"=="0" (
        echo.
        echo ## backup structure exited with error
        echo.
		type "%%a"
        echo.

        echo.
    	echo aborting
        echo.
        pause
        exit 1
	)
)


7z a -tzip -mx6 %backup_structure_filename%.zip %backup_structure_filename%

echo.
for %%a in ("%backup_structure_filename%") do ( 
    echo ## completed structure backup to file [%backup_structure_filename%] with size [%%~za]
)
echo.

pause
