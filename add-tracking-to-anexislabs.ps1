$ErrorActionPreference = 'Stop'

$root = 'C:\Users\anand\anexislabs\anexislabs'
$encoding = [System.Text.UTF8Encoding]::new($false)

$tracking = @'
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-N4MHWGN4MP"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'G-N4MHWGN4MP');
</script>
<script type="text/javascript">
    (function(c,l,a,r,i,t,y){
        c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
        t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
        y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
    })(window, document, "clarity", "script", "wkvsm99t6f");
</script>
'@

$inserted = 0
$skipped = 0
$files = Get-ChildItem -Path $root -Recurse -Filter *.html | Where-Object { $_.Length -gt 0 }

foreach ($file in $files) {
  $content = [System.IO.File]::ReadAllText($file.FullName)

  if (
    $content.Contains('G-N4MHWGN4MP') -or
    $content.Contains('wkvsm99t6f') -or
    $content.Contains('googletagmanager.com/gtag/js') -or
    $content.Contains('clarity.ms/tag')
  ) {
    $skipped++
    continue
  }

  $match = [System.Text.RegularExpressions.Regex]::Match(
    $content,
    '<head>',
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
  )

  if (-not $match.Success) {
    $skipped++
    continue
  }

  $updated = $content.Insert($match.Index + $match.Length, "`r`n$tracking")
  [System.IO.File]::WriteAllText($file.FullName, $updated, $encoding)
  $inserted++
}

$tagged = Get-ChildItem -Path $root -Recurse -Filter *.html |
  Where-Object { $_.Length -gt 0 } |
  Where-Object {
    Select-String -LiteralPath $_.FullName -Pattern 'G-N4MHWGN4MP' -Quiet
  }

"Inserted tracking into $inserted file(s). Skipped $skipped file(s). Tagged non-empty HTML files: $($tagged.Count)."
