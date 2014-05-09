wmi_to_json
====================

Custom PowerShell (v1) script which uses WMI Windows interface to query items and prints output in JSON format.

This can be used as a discovery script for Zabbix.

Usage
-----

```
wmi_discovery.ps1 <namespace> <WMI querry>
```

Execute from the cmd.exe

```
powershell.exe -NoProfile -NoLogo -File "<full path to script directory>\wmi_discovery.ps1" "Namespace" "WMI querry"
```

Example Usage

```
powershell -NoProfile -NoLogo -File "D:\krogon\wmi_discovery.ps1" "root/cimv2" "Select Name, LogFilesSizeKB, LogTruncations from Win32_PerfFormattedData_MsSqlServer_SqlServerDatabases where Name not like '%_repl%'"
```

Zabbix Discovery Configuration
------------------------------

* Download [latest release](https://github.intel.com/krogon/wmi_to_json/releases/) of wmi_discovery.ps1 script and place it at C:\devtools\zabbix\scripts
  
* Append configuration to zabbix_agentd.userparams.conf
  
  ```
  EnableRemoteCommands=1
  UnsafeUserParameters=1
  UserParameter=custom.mssql_db_discover[*],powershell.exe -NoProfile -NoLogo -File "C:\devtools\zabbix\scripts\wmi_discovery.ps1" "root/cimv2" "SELECT Name FROM Win32_PerfFormattedData_MsSqlServer_SqlServerDatabases WHERE Name != '_Total' $1"
  ```

* Restart Zabbix Agent service

* Set the global macro for the template/hosts

  ```
  {$MSSQL_WQL_WHERE_GLOBAL}="AND Name!='_Total' AND Name!='master'  AND Name!='msdb' AND Name!='model' AND Name!='mssqlsystemresource' AND Name!='tempdb'"
  ```

* (Optional) Set the local macro for the template/hosts (ex.)

  ```
  {$MSSQL_SQL_WHERE}="AND NOT Name like '%[_]repl'"
  ```

  This will exclude all DBs which ends with "_repl".

* You may setup new discover item in Zabbix Server with the following key (unless it is already defined in template)
  
  ```
  custom.mssql_db_discover["{$MSSQL_WQL_WHERE_GLOBAL} {$MSSQL_WQL_WHERE}"]
  ```

