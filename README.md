# Db2Functs
Some samples Db2 for z/OS user defined function &amp; table functions

| Function Name         | Type          | Description                                                    |
| --------------------- | ------------- | ---------------------------------------------------------------|
| [RCDF.CSI](#csi)      | External UDTF | Return a table from the Catalog Search Interface               |
| RCDF.PDSDIR(#pdsdir)  | External UDTF | Return a list of members of a PDS/Library dataset              |
| RCDF.NSLOOKUP         | External UDF  | Return a Hostname from an IP Address using the system resolver |
| RCDF.UUID             | External UDF  | Return a Universally unique identifier                         |
| RCDF.WORD             | External UDF  | Return n-word from string using a specified separator          |
| RCDF.POSIXT_TIMESTAMP | SQL UDF       | Return a Unix/POSIX Epoch time from a Db2 TimeStamp            |
| RCDF.POSIXT_DATE      | SQL UDF       | Return a Unix/POSIX Epoch time from a Db2 Date                 |
| RCDF.B2H              | SQL UDF       | Return a number of bytes in human readable IEC 80000-13 suffixs|

# Install
* Upload all the members in this repo to a PDS/Library in your z/OS converting from ascii to ebcdic (Codepage 037).
* Customize & submit **$BUILD** and **$DDL** JCL procedures.
* Refresh the LLA, if needed, and customize & submit **$TEST**.

# CSI
Call the Catalog Search Interface
| Argument | Description |
| -------- | ----------- |
| mask     | varchar - Dataset mask (like 3.4 ISPF/PDF format) |
| type     | varchar - Dataset type. Up to 16 types, all types if null. Refer to CSIETYPE.|

Sample: to list all SYS1.** non-vsam datasets:
```sql
SELECT * FROM TABLE(RCDF.CSI('SYS1.**','A')) as T;
```
# PDSDIR
List member of a PDS/Library
| Argument | Description |
| -------- | ----------- |
| dsname   | varchar - Dataset name |

Sample: to list all members from SYS1.PARMLIB:
```sql
SELECT * FROM TABLE(RCDF.PDSDIR('SYS1.PARMLIB')) as T;
```


