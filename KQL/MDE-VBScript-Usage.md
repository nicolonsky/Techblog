# MDE-VBScript-Usage

KQL Query to identify usage of VBScript engine and artefacts in your environment with Defender for Endpoint for the upcoming deprecation.

## Query

### Sentinel
```kusto
union DeviceProcessEvents, DeviceNetworkEvents, DeviceEvents
| where TimeGenerated > ago(30d)
| where ProcessCommandLine has_any ("wscript", "Wscript.Shell", "WScript.CreateObject", "cscript", "vbscript")
| extend CommandLine =  parse_command_line(ProcessCommandLine, "windows")
| mv-expand CommandLine
| where CommandLine has ".vbs"
| summarize Count = count() by VBScript = tostring(CommandLine)
```

### Defender XDR
```kusto
union DeviceProcessEvents, DeviceNetworkEvents, DeviceEvents
| where Timestamp > ago(30d)
| where ProcessCommandLine has_any ("wscript", "Wscript.Shell", "WScript.CreateObject", "cscript", "vbscript")
| extend CommandLine =  parse_command_line(ProcessCommandLine, "windows")
| mv-expand CommandLine
| where CommandLine has ".vbs"
| summarize Count = count() by VBScript = tostring(CommandLine)
```

## Hunt Tags

* **Author:** [Nicola Suter](https://nicolasuter.ch)
* **License:** [MIT License](https://github.com/nicolonsky/techblog/blob/master/LICENSE)

### Additional information

* <https://techcommunity.microsoft.com/t5/windows-it-pro-blog/vbscript-deprecation-timelines-and-next-steps/ba-p/4148301>

### MITRE ATT&CK Tags

* **Tactic:** N/A
* **Technique:**
    * N/A
