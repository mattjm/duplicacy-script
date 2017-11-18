$duplicacyBinary = "C:\Users\myuser\AppData\Local\Duplicacy\duplicacy.exe"

# comma separated list of folders to back up
$backupLocations = "C:\Users\myuser", "D:\ORGANIZE"

#where to put logs
$logFolder = "C:\Users\myuser\Documents\backup_logs\"
$logFileName = "duplicacy.log"
$logPath = ($logFolder + $logFileName)
# size to roll over at in megabytes
$logMaxSize = 5mb
# age after which to delete logs (in days)
$logMaxAge = 30



# function to roll over logs when they get too big
#
# pre-create the log file the first time you run the script since 
# this doesn't error check
function Rollover-Logs
{
    

    # roll over by size
    if ((Get-Item $logPath).Length -gt $logMaxSize) {
        
        
        $currentDate = (Get-Date -UFormat %Y%m%d%H%M%S%Z)
        Rename-Item $logPath ($logPath + "." + $currentDate)
        echo ("Rolled over logs at " + $currentDate >> $logPath)
    
    # delete when too old
    if ((Get-Item $logPath).LastWriteTime.AddDays(-$logMaxAge) -gt (Get-Date)) {
    
    
    }
        
}
}

Rollover-Logs

foreach ($location in $backupLocations) {

    

    cd $location
    echo ("running backups for " + $location + " at " + (Get-Date -UFormat %Y%m%d%T%Z)) *>> $logPath
    & $duplicacyBinary prune -keep 0:360 -keep 30:180 -keep 7:30 -keep 1:7 *>> $logPath
    & $duplicacyBinary backup -stats -vss *>> $logPath
    & $duplicacyBinary prune --delete-only *>> $logPath
    & $duplicacyBinary prune -keep 0:360 -keep 30:180 -keep 7:30 -keep 1:7 -storage b2 *>> $logPath
    & $duplicacyBinary copy -to b2 -threads 10 *>> $logPath
    & $duplicacyBinary prune --delete-only -storage b2 *>> $logPath

}




# SIG # Begin signature block
# MIIFVQYJKoZIhvcNAQcCoIIFRjCCBUICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNRmWjSxSvU73XjYIDFMHOFOT
# urSgggL4MIIC9DCCAdygAwIBAgIQHB1E92Tt3J5EmITDvfuxkDANBgkqhkiG9w0B
# AQsFADASMRAwDgYDVQQDDAdCYWNrdXBzMB4XDTE3MTAzMTA1MTExMVoXDTE4MTAz
# MTA1MzExMVowEjEQMA4GA1UEAwwHQmFja3VwczCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBAKLuwlouwvEDniEdA6PeoXy+qQIDLvguNzrGTb9ue91gaso8
# hwbcn/GKjBz848BRoEf3GXTb7AORiWaxrROHaDIFThy/0e37ay56qi3Stco+c4pv
# ekPiHiBbwOPVwPZx0nB2sAw1/YG/a8jap7ZA3oWtvzkpw6YQa/VJxTIuxx2hVBsl
# YYGsukuRQfu0wd1KCBmwECdH2SMg+Cjv/hmnnxRHBJH4Z/rzXdv38ARcsUgVbzqr
# 13hPLWIzWKxDwfk/Ch6uhi/+Hsy0Hxv1A1xNdKgsfoLCV9+WzTq1KZZPAifMqeg9
# SbrahmfwMOCKsFNqCK6FsikahsSL+NacQHWQLUkCAwEAAaNGMEQwDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBTOBJL90YADmaqI
# Jklz54YE5Yh9WjANBgkqhkiG9w0BAQsFAAOCAQEAj1qJPdpnZhzSVJEfMzq4y4LZ
# G4XHELO98j8rGD260GaZG1IoSt0Q1c5vPKSdhXxefFwq9cGTUYTqefCUb+1oC4AR
# x60p/1qK7r1ScKPCL5/dCCCYaH7fqIXfK32eNr/5e2TS30+G7fQGdf2BbYdp89wx
# Ln0JAn9aDZZWcv9fx6q48hSmpXNH1E4hU4h5Sd6Ob1xzrP9GZ1irv4GwtoG4nEku
# DDTV+mq0GQV9Zv44Zp6KMfibgKT4ihP5fYyMHni/4E/qCs3FQxvf0HvWHQCHBSEg
# Iw1gWa5UHcKQ41S+O82WWo9y9OUPvp16VuX2dpX9f1Kk0aQsvB2OfMK8e+5ntjGC
# AccwggHDAgEBMCYwEjEQMA4GA1UEAwwHQmFja3VwcwIQHB1E92Tt3J5EmITDvfux
# kDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG
# 9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIB
# FTAjBgkqhkiG9w0BCQQxFgQUy0NAbSkQjUV7NNXnp+q1XJ0q7PkwDQYJKoZIhvcN
# AQEBBQAEggEAITM3Jvx6qlYE/smdNfiqxntScnK3WEhUDz4PAn5wXzbyPsghgDJ+
# 89gmUfPGJzeN8xZek3J8kDf+zm8qjmZ75Go6+pXECl+vrgUEqrvaNv3esBjj0OmI
# mHiar/L3KSvIMZCSBm4EtgqAHSHRFN0FE7857NVDCB+8DTH3q67VQNdUdQmsK2EO
# ZZm+WRAUHNvDBSw827qkxxqyXGcktvqbksM05/U46RRXWzF8hI89mnnD49yRPMAT
# izQ4w8CnBPUqDYtfkZWHSZZ0mSWnyInx8Q02TjU9bpsSrFD9wGDoj+DPFutrHLVo
# U1xg23i1hBCaik70mrNkC9aBEhJ7J66aVA==
# SIG # End signature block
