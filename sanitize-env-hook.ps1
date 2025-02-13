# function to process a single env file and generate its .EXAMPLE version
function process-env-file {
  param(
      [string]$env_file  # path to the env file to process
  )

  # determine the example file name by removing a trailing .example if present and appending .EXAMPLE
  $example_file = (if ($env_file -match "\.example$") { $env_file -replace "\.example$", "" } else { $env_file }) + ".EXAMPLE"

  # if the file name ends with .example then rename it to use .EXAMPLE instead
  if ($env_file -like "*.example") {
      try {
          Rename-Item -Path $env_file -NewName $example_file -ErrorAction Stop
      } catch {
          Write-Host "failed to rename $env_file to $example_file"
      }
  }

  # always try to copy the env file to the example file
  try {
      Copy-Item -Path $env_file -Destination $example_file -ErrorAction Stop
  } catch {
      Write-Host "failed to copy $env_file to $example_file"
      return
  }

  # read the content of the example file into an array of lines
  try {
      $lines = Get-Content -Path $example_file -ErrorAction Stop
  } catch {
      Write-Host "failed to read $example_file"
      return
  }

  # for each line that does not define a port variable (ignoring case) remove the value after the equal sign
  for ($i = 0; $i -lt $lines.Count; $i++) {
      $line = $lines[$i]
      if ($line -notmatch '^[^#]*[Pp][Oo][Rr][Tt]=') {
          $lines[$i] = $line -replace '=.*', '='
      }
  }

  # add a header at the top of the file indicating it was auto generated
  $header = "# generated automatically by .git/hooks/pre-commit"
  $lines = ,$header + $lines

  # write the modified content back to the example file
  try {
      Set-Content -Path $example_file -Value $lines -ErrorAction Stop
  } catch {
      Write-Host "failed to write to $example_file"
  }

  # if .gitignore does not exist create it so we can add the env file to it
  if (-not (Test-Path .gitignore)) {
      New-Item -ItemType File -Path .gitignore -Force | Out-Null
  }
  # add the original env file to .gitignore if it's not already listed
  $gitignoreContent = Get-Content .gitignore
  if ($gitignoreContent -notcontains $env_file) {
      Add-Content -Path .gitignore -Value $env_file
  }

  # stage the example file for commit
  & git add $example_file

  # remove the original env file from staging so it is not accidentally committed
  & git rm --cached $env_file
}

# find all files starting with .env (including .env.<environment>) but exclude any ending with .EXAMPLE
$envFiles = Get-ChildItem -Path . -Recurse -File | Where-Object {
  $_.Name -like ".env*" -and $_.Name -notlike "*.EXAMPLE"
}

# process each found env file
foreach ($file in $envFiles) {
  process-env-file $file.FullName
}
