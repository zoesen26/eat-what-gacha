Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$htmlPath = Join-Path $root 'index.html'
$outDir = Join-Path $root 'transparent-assets'

if (-not (Test-Path $outDir)) {
  New-Item -ItemType Directory -Path $outDir | Out-Null
}

function Test-BackgroundPixel {
  param([System.Drawing.Color]$Color)

  $max = [Math]::Max($Color.R, [Math]::Max($Color.G, $Color.B))
  $min = [Math]::Min($Color.R, [Math]::Min($Color.G, $Color.B))
  $brightness = ($Color.R + $Color.G + $Color.B) / 3
  $saturation = $max - $min

  return ($brightness -ge 236 -and $saturation -le 28)
}

function Get-FeatherAlpha {
  param([System.Drawing.Color]$Color)

  $brightness = ($Color.R + $Color.G + $Color.B) / 3
  if ($brightness -ge 250) { return 0 }
  if ($brightness -le 236) { return 255 }
  return [int][Math]::Round(255 * (250 - $brightness) / 14)
}

function Convert-ToTransparentPng {
  param(
    [byte[]]$Bytes,
    [string]$OutputPath
  )

  $stream = [System.IO.MemoryStream]::new($Bytes)
  $source = [System.Drawing.Image]::FromStream($stream)
  $bitmap = [System.Drawing.Bitmap]::new($source.Width, $source.Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.DrawImage($source, 0, 0, $source.Width, $source.Height)
  $graphics.Dispose()
  $source.Dispose()
  $stream.Dispose()

  $width = $bitmap.Width
  $height = $bitmap.Height
  $visited = New-Object 'bool[,]' $width, $height
  $queue = [System.Collections.Generic.Queue[object]]::new()

  for ($x = 0; $x -lt $width; $x++) {
    $queue.Enqueue([int[]]@($x, 0))
    $queue.Enqueue([int[]]@($x, ($height - 1)))
  }
  for ($y = 0; $y -lt $height; $y++) {
    $queue.Enqueue([int[]]@(0, $y))
    $queue.Enqueue([int[]]@(($width - 1), $y))
  }

  while ($queue.Count -gt 0) {
    $point = [int[]]$queue.Dequeue()
    $x = $point[0]
    $y = $point[1]

    if ($x -lt 0 -or $x -ge $width -or $y -lt 0 -or $y -ge $height) { continue }
    if ($visited[$x, $y]) { continue }

    $color = $bitmap.GetPixel($x, $y)
    if (-not (Test-BackgroundPixel $color)) { continue }

    $visited[$x, $y] = $true
    $alpha = Get-FeatherAlpha $color
    $bitmap.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, $color.R, $color.G, $color.B))

    $queue.Enqueue([int[]]@(($x + 1), $y))
    $queue.Enqueue([int[]]@(($x - 1), $y))
    $queue.Enqueue([int[]]@($x, ($y + 1)))
    $queue.Enqueue([int[]]@($x, ($y - 1)))
  }

  $bitmap.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $bitmap.Dispose()
}

$html = [System.IO.File]::ReadAllText($htmlPath)
$regex = [regex]'data:image/(jpeg|jpg|png);base64,([A-Za-z0-9+/=]+)'
$matches = $regex.Matches($html)
$seen = @{}
$updated = $html
$index = 0

foreach ($match in $matches) {
  $dataUrl = $match.Value
  if ($seen.ContainsKey($dataUrl)) { continue }

  $bytes = [Convert]::FromBase64String($match.Groups[2].Value)
  $outPath = Join-Path $outDir ("image-{0:D2}.png" -f $index)
  Convert-ToTransparentPng -Bytes $bytes -OutputPath $outPath

  $pngBytes = [System.IO.File]::ReadAllBytes($outPath)
  $pngDataUrl = 'data:image/png;base64,' + [Convert]::ToBase64String($pngBytes)
  $updated = $updated.Replace($dataUrl, $pngDataUrl)
  $seen[$dataUrl] = $pngDataUrl
  $index++
}

[System.IO.File]::WriteAllText($htmlPath, $updated, [System.Text.UTF8Encoding]::new($false))
Write-Output "Converted $index embedded image(s) to transparent PNG."
