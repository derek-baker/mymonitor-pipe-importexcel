# MyMonitorPipeImportExcel

**TLDR**: 

Pipes output of [Jeff Hicks' MyMonitor](https://github.com/jdhitsolutions/MyMonitor) to [Doug Finke's ImportExcel](https://github.com/dfinke/ImportExcel). 

**Overview**: 

Scripts in this repo can be used on _Windows systems_ to measure which applications were actively used over during a monitored session. If the categories of tasks you perform are paritioned by application, it may be possible to use this data to provide insight into how how much time is spent on each category.

**Manifest:**
- `CaptureData.ps1` can be used to record data on actively used applications.
- `GenerateReport.ps1` can be used to transform the data and generate Excel-based visualizations of session data.


## Getting Started
- Clone the repo.
- Open a [Powershell](https://github.com/PowerShell/PowerShell#get-powershell) session and cd to the roow of the repo cloned previously.
- Install dependencies:
    ``` ps1
    Install-Module -Name ImportExcel -Scope CurrentUser -RequiredVersion '7.8.4'
    ```
- Capture Data:
    ``` ps1
    ./CaptureData.ps1 $sessionLengthInMinutes 1
    ```
- Generate Report:
    ``` ps1
    ./GenerateReport.ps1 # The report will be written to the working directory.
    ```

## Scheduling Automated Data Capture
TODO

