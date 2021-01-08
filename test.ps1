Remove-Item C:\inetpub\wwwroot\*.*
New-Item IIS:\Sites\DemoSite -physicalPath C:\DemoSite -bindings @{protocol="http";bindingInformation=":80:"}
New-Item IIS:\AppPools\DemoAppPool
Set-ItemProperty -Path IIS:\AppPools\TestSite managedRuntimeVersion "v4.0"

Set-ItemProperty IIS:\Sites\DemoSite -name applicationPool -value DemoAppPool

