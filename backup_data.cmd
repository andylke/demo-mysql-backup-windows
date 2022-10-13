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
set /p continue="<< BACKUP DATA >> for [%run_env%] ? (y/n)"
if not "%continue%"=="y" (
	exit /b
)

if not exist "..\backup" (
    mkdir "..\backup"
)
set backup_data_filename=..\backup\%run_timestamp%_%run_env%-data_backup.sql
set backup_log_filename=..\backup\%run_timestamp%_%run_env%-backup.log

echo.
echo ## adding truncate all tables to file [%backup_data_filename%]
echo.


set select_truncate_all_tsql=select CONCAT('TRUNCATE TABLE ', t.TABLE_SCHEMA, '.', t.TABLE_NAME, ';') from INFORMATION_SCHEMA.TABLES t where t.TABLE_SCHEMA in ('clmdat', 'clmpar', 'clmwrk', 'depdat', 'deppar', 'depwrk', 'fisdat', 'fispar', 'glsdat', 'glspar', 'glswrk', 'icsarc', 'icsdat', 'icspar', 'icswrk', 'ifswrk', 'lnsdat', 'lnspar', 'lnswrk', 'sysarc', 'sysdat', 'syslog', 'syspar');
mysql -h %db_hostname% -P %db_port% -u %db_username% -p%db_password% -s -e "%select_truncate_all_tsql%" > %backup_data_filename%


echo.
echo ## backing up data to file [%backup_data_filename%], error log [%backup_log_filename%]
echo.

mysqldump -h %db_hostname% -P %db_port% -u %db_username% -p%db_password% --no-create-db --no-create-info --replace --complete-insert --skip-comments --log-error=%backup_log_filename% --databases %backup_schemas% >> %backup_data_filename%

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

7z a -tzip -mx6 %backup_data_filename%.zip %backup_data_filename%

echo.
for %%a in ("%backup_data_filename%") do ( 
    echo ## completed data backup to file [%backup_data_filename%] with size [%%~za]
)
echo.

timeout /t %wait_interval%
