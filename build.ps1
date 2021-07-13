[CmdletBinding()]
param()
  
function New-Image {

  [CmdletBinding()]
  param (
    [Parameter()]
    [int]
    $JavaVersion,
    [Parameter()]
    [string]
    $Arma3SyncVersion
  )

  $version = $Arma3SyncVersion.split('-')
  $major = "$($version[0]).$($version[1])"
  $minor = "$($version[0]).$($version[1]).$($version[2])"
  docker build . --build-arg "ARMA3SYNC_VERSION=$Arma3SyncVersion" --build-arg "JAVA_VERSION=$JavaVersion" `
    -t "arwynfr/arma3sync:$minor-jre$JavaVersion" `
    -t "arwynfr/arma3sync:$minor" `
    -t "arwynfr/arma3sync:$major-jre$JavaVersion" `
    -t "arwynfr/arma3sync:$major"
}

$javaVersions = 8, 11, 16
$arma3syncVersions = Get-Content .\versions.txt
foreach ($javaVersion in $javaVersions) {
  foreach ($arma3syncVersion in $arma3syncVersions) {
    New-Image -JavaVersion $javaVersion -Arma3SyncVersion $arma3syncVersion
  }
}

# docker push -a arwynfr/arma3sync