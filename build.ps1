Get-Content .\versions.txt | Foreach-Object {
  $version = $_.split('-')
  $major = "$($version[0]).$($version[1])"
  $minor = "$($version[0]).$($version[1]).$($version[2])"
  docker build . --build-arg "ARMA3SYNC_VERSION=$_" `
    -t "arwynfr/arma3sync:$minor-jre11" `
    -t "arwynfr/arma3sync:$minor" `
    -t "arwynfr/arma3sync:$major-jre11" `
    -t "arwynfr/arma3sync:$major"
}