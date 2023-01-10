# Db2Functs
Some samples Db2 for z/OS user defined function &amp; table functions

| Function Name          | Type          | Description                                                    |
| ---------------------- | ------------- | ---------------------------------------------------------------|
| [RCDF.CSI](#csi)       | External UDTF | Return a table from the Catalog Search Interface               |
| [RCDF.PDSDIR](#pdsdir) | External UDTF | Return a list of members of a PDS/Library dataset              |
| [RCDF.NSLOOKUP](#nslookup) | External UDF  | Return a Hostname from an IP Address using the system resolver |
| [RCDF.UUID](#uuid)         | External UDF  | Return a Universally unique identifier                         |
| [RCDF.WORD](#word)              | External UDF  | Return n-word from string using a specified separator          |
| [RCDF.POSIXT_TIMESTAMP](#posixt-timestamp)  | SQL UDF       | Return a Unix/POSIX Epoch time from a Db2 TimeStamp            |
| [RCDF.POSIXT_DATE](#posixt-date)     | SQL UDF       | Return a Unix/POSIX Epoch time from a Db2 Date                 |
| [RCDF.B2H](#b2h)               | SQL UDF       | Return a number of bytes in human readable IEC 80000-13 suffixs|

# Other samples
| file         | Description |
| ------------ | ----------- |
| SAMPLECX.rx  | Sample call to SYSPROX.DSNACCOX from Rexx |

# Install
* Upload $XMIT file as binary 80/FB and receive with TSO: **RECEIVE INDA('yourfile.XMIT')**
* Alternatively, upload all the members in this repo to a PDS/Library in your z/OS converting from ascii to ebcdic (Codepage 037).
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

# NSLOOKUP
Get host name from IPv4 address using system resolver.
| Argument | Description |
| -------- | ----------- |
| ipaddr   | varchar - IPv4 Address |

Sample: show host name:
```sql
SELECT RCDF.NSLOOKUP('127.0.0.1') FROM SYSIBM.SYSDUMMY1;  
```

# UUID
Generate Univiersal Unique Identifier (Format af8b1f38-fba2-4464-8860-42f7fce3ea19)

Sample:
```sql
SELECT RCDF.UUID() FROM SYSIBM.SYSDUMMY1;
```

# WORD
Extract n-word from string
| Argument | Description |
| -------- | ----------- |
| string   | varchar - original string |
| n        | int - n-word |
| sep      | char - Separator |

Sample:
```sql
SELECT RCDF.WORD('ISP.SISPLPA',2,'.') FROM SYSIBM.SYSDUMMY1; 
```

# POSIXT TIMESTAMP
Return Epoch time from Db2 Timestamp
| Argument | Description |
| -------- | ----------- |
| timestamp | timestamp |

Sample:
```sql
SELECT RCDF.POSIXT_TIMESTAMP(CURRENT TIMESTAMP) FROM SYSIBM.SYSDUMMY1;
```

# POSIXT DATE
Return Epoch time from Db2 Date
| Argument | Description |
| -------- | ----------- |
| date     | date|

Sample:
```sql
SELECT RCDF.POSIXT_DATE(CURRENT DATE) FROM SYSIBM.SYSDUMMY1; 
```

# B2H
eturn a number of bytes in human readable IEC 80000-13 suffixs
| Argument | Description |
| -------- | ----------- |
| number   | bigint - Bytes |

Sample: will return 1MB.
```sql
 SELECT RCDF.B2H(1048576) FROM SYSIBM.SYSDUMMY1;  
```


