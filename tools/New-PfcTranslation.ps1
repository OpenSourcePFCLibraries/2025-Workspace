<#
.SYNOPSIS
    Creates a first translation of the PFC language file from a Translation Toolkit dictionary.

.DESCRIPTION
    Reads the English language file (lang\pfc.lng, see New-PfcLanguageFile.ps1) and a
    PowerBuilder Translation Toolkit dictionary (.dic, such as those in the
    OpenSourcePFCLibraries/localization repository), and writes a language file with the
    translations the dictionary has:

    - Captions are looked up by their English text. The dictionaries keep access keys apart
      (Page Set&up... is "Page Setup..." with the key "u"), so the & is removed for the
      lookup and put back before the access key the dictionary gives for the translation.
      A menu shortcut after ~t is kept.
    - Messages are looked up whole. The dictionaries were made from the PFC code, where many
      messages are concatenations, so when there is no whole match the parts between the
      values (%s) and line breaks are translated one by one. Those entries are marked: check
      their word order.
    - Translations made by hand, for texts the dictionary doesn't have (or translates badly),
      are kept in a separate file (-Additions) in the same format as the language file. They
      take precedence over the dictionary, so they survive when the file is made again.
    - Entries the dictionary has no translation for are written in English at the end of the
      file, under "Not translated yet".

.PARAMETER Dictionary
    The Translation Toolkit dictionary (Windows-1252, tab separated).
.PARAMETER Output
    The language file to write (UTF-16, like lang\default.lng).
.PARAMETER Language
    Name of the language, for the comments in the file. Default: the dictionary's file name.
.PARAMETER English
    The English language file. Default: lang\pfc.lng in the repository.
.PARAMETER Additions
    Translations made by hand: ID="text" and "Caption"="text" lines, like the language file
    (UTF-8 or UTF-16 with a byte order mark). Default: additions.lng in the folder of
    -Output, if it exists.

.EXAMPLE
    pwsh -File tools\New-PfcTranslation.ps1 -Dictionary ..\localization\german.dic -Output ..\localization\lang\german\pfc.lng -Language German
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Dictionary,
    [Parameter(Mandatory)][string]$Output,
    [string]$Language = [IO.Path]::GetFileNameWithoutExtension($Dictionary),
    [string]$English = (Join-Path $PSScriptRoot '..\lang\pfc.lng'),
    [string]$Additions = (Join-Path (Split-Path $Output) 'additions.lng')
)
$ErrorActionPreference = 'Stop'

# --- translations made by hand: message ID (lower case) or "caption" (case-sensitive) -> text,
# both as written in the language file
$added = [System.Collections.Generic.Dictionary[string, string]]::new()
if (Test-Path $Additions) {
    foreach ($line in [IO.File]::ReadAllLines((Resolve-Path $Additions))) {
        if ($line -match '^#' -or $line.Trim() -eq '') { continue }
        if ($line -match '^("(?:[^"~]|~.)*")="(.*)"$') { $added[$Matches[1]] = $Matches[2] }
        elseif ($line -match '^([^"=][^=]*)="(.*)"$') { $added[$Matches[1].Trim().ToLowerInvariant()] = $Matches[2] }
        else { Write-Warning "${Additions}: not an entry: $line" }
    }
}
$used = [System.Collections.Generic.HashSet[string]]::new()

# PowerScript escapes (~r ~n ~t ~" ~' ~~) to characters
function ConvertFrom-PbEscapes([string]$t) {
    $sb = [System.Text.StringBuilder]::new(); $i = 0
    while ($i -lt $t.Length) {
        $c = $t[$i]
        if ($c -eq '~' -and $i + 1 -lt $t.Length) {
            switch -CaseSensitive ($t[$i + 1]) {
                'r' { [void]$sb.Append("`r") } 'n' { [void]$sb.Append("`n") } 't' { [void]$sb.Append("`t") }
                default { [void]$sb.Append($t[$i + 1]) }
            }
            $i += 2; continue
        }
        [void]$sb.Append($c); $i++
    }
    $sb.ToString()
}

# Characters to the escapes of the language file
function ConvertTo-LngText([string]$t) {
    $t.Replace('~', '~~').Replace('"', '~"').Replace("`t", '~t').Replace("`r", '~r').Replace("`n", '~n')
}

# A dictionary field: CSV quoting ("...", with "" for a quote) removed
function Get-Field([string]$f) {
    if ($f.Length -ge 2 -and $f.StartsWith('"') -and $f.EndsWith('"')) { $f = $f.Substring(1, $f.Length - 2).Replace('""', '"') }
    ConvertFrom-PbEscapes $f
}

# --- the dictionary: English text -> translation and access keys
$dict = @{}; $dictCI = @{}
foreach ($line in [IO.File]::ReadAllLines((Resolve-Path $Dictionary), [Text.Encoding]::GetEncoding(1252))) {
    $f = $line.Split("`t")
    if ($f.Count -lt 6) { continue }
    $en = (Get-Field $f[4]).Trim(); $tr = (Get-Field $f[2]).Trim()
    if ($en -eq '' -or $tr -eq '') { continue }
    $entry = @{ Text = $tr; Key = $f[3].Trim(); EnglishKey = $f[5].Trim() }
    # Prefer an entry with an access key (a caption) over one without
    if (-not $dict.ContainsKey($en) -or ($dict[$en].Key -eq '' -and $entry.Key -ne '')) { $dict[$en] = $entry }
    $lc = $en.ToLowerInvariant()
    if (-not $dictCI.ContainsKey($lc)) { $dictCI[$lc] = $entry }
}

function Find-Entry([string]$t) {
    $k = $t.Trim()
    if ($k -eq '') { return $null }
    if ($dict.ContainsKey($k)) { return $dict[$k] }
    if ($dictCI.ContainsKey($k.ToLowerInvariant())) { return $dictCI[$k.ToLowerInvariant()] }
    return $null
}

# Keeps the spaces and punctuation around $original on $translation (the dictionaries often
# translate ".  Please enter a value." as "Bitte geben Sie einen Wert ein.")
function Copy-Spacing([string]$original, [string]$translation) {
    if ($translation -notmatch '[\p{L}\p{N}]' -or $original -notmatch '[\p{L}\p{N}]') { return $translation }
    $lead = [regex]::Match($original, '^[^\p{L}\p{N}]*').Value
    $trail = [regex]::Match($original, '[^\p{L}\p{N}]*$').Value
    $tlead = [regex]::Match($translation, '^[^\p{L}\p{N}]*').Value
    $ttrail = [regex]::Match($translation, '[^\p{L}\p{N}]*$').Value
    if ($lead.Trim() -eq '' -or $tlead.Trim() -eq '') { $translation = $lead + $translation.Substring($tlead.Length) }
    if ($trail.Trim() -eq '' -or $ttrail.Trim() -eq '') {
        $translation = $translation.Substring(0, $translation.Length - $ttrail.Length) + $trail
    }
    $translation
}

# A caption: & and a menu shortcut (~t) handled; $null if there is no translation
function Convert-Caption([string]$caption) {
    $shortcut = ''
    $tab = $caption.IndexOf("`t")
    if ($tab -ge 0) { $shortcut = $caption.Substring($tab); $caption = $caption.Substring(0, $tab) }
    $amp = $caption -match '&(?!&)'
    $plain = $caption -replace '&(?!&)', ''
    $e = Find-Entry $plain
    if (-not $e) { return $null }
    $t = Copy-Spacing $plain $e.Text
    if ($amp) {
        $pos = -1
        if ($e.Key) { $pos = $t.IndexOf($e.Key, [StringComparison]::OrdinalIgnoreCase) }
        if ($pos -lt 0) { $pos = [regex]::Match($t, '\p{L}').Index }
        $t = $t.Insert($pos, '&')
    }
    $t + $shortcut
}

# A message: whole, or by parts; returns @{ Text; Assembled } or $null
function Convert-Message([string]$text) {
    $e = Find-Entry $text
    if ($e) { return @{ Text = (Copy-Spacing $text $e.Text); Assembled = $false } }
    $parts = [regex]::Split($text, '(%s|%[1-9]|\r\n|\r|\n)')
    if ($parts.Count -le 1) { return $null }
    $out = ''
    foreach ($p in $parts) {
        if ($p -match '^(%s|%[1-9]|\r\n|\r|\n)$' -or $p -notmatch '\p{L}') { $out += $p; continue }
        $pe = Find-Entry $p
        if (-not $pe) { return $null }
        $out += Copy-Spacing $p $pe.Text
    }
    @{ Text = $out; Assembled = $true }
}

# --- the English file
$lines = [IO.File]::ReadAllLines((Resolve-Path $English), [Text.Encoding]::Unicode)
$body = [System.Collections.Generic.List[string]]::new()
$missing = [System.Collections.Generic.List[string]]::new()
$nTranslated = 0; $nAssembled = 0; $nMissing = 0; $nAdded = 0
foreach ($line in $lines) {
    if ($line -match '^#' -or $line.Trim() -eq '') {
        # Keep the module comments; the file header is written below
        if ($line -match '^# Module:' -or ($line.Trim() -eq '' -and $body.Count -gt 0)) { $body.Add($line) }
        continue
    }
    # Translated by hand
    $left = $null; $key = $null
    if ($line -match '^("(?:[^"~]|~.)*")=') { $left = $Matches[1]; $key = $left }
    elseif ($line -match '^([^=]+)="') { $left = $Matches[1]; $key = $left.ToLowerInvariant() }
    if ($null -ne $key -and $added.ContainsKey($key)) {
        $body.Add("$left=""$($added[$key])""")
        [void]$used.Add($key); $nAdded++; $nTranslated++
        continue
    }
    if ($line -match '^"((?:[^"~]|~.)*)"=') {
        # Caption
        $en = ConvertFrom-PbEscapes $Matches[1]
        $tr = Convert-Caption $en
        if ($null -eq $tr) { $missing.Add($line); $nMissing++; continue }
        $body.Add("""$(ConvertTo-LngText $en)""=""$(ConvertTo-LngText $tr)""")
        $nTranslated++
    }
    elseif ($line -match '^([^=]+)="(.*)"$') {
        # Message (or a message title)
        $key = $Matches[1]; $en = ConvertFrom-PbEscapes $Matches[2]
        if ($key -like '*.title') { $r = Convert-Caption $en; if ($null -ne $r) { $r = @{ Text = $r; Assembled = $false } } }
        else { $r = Convert-Message $en }
        if ($null -eq $r) { $missing.Add($line); $nMissing++; continue }
        if ($r.Assembled) { $body.Add('# Check the word order: translated in parts'); $nAssembled++ }
        $body.Add("$key=""$(ConvertTo-LngText $r.Text)""")
        $nTranslated++
    }
}

$out = [System.Text.StringBuilder]::new()
[void]$out.AppendLine("# PFC language file: $Language")
[void]$out.AppendLine('#')
[void]$out.AppendLine("# A first translation, made by tools\New-PfcTranslation.ps1 from the Translation Toolkit")
[void]$out.AppendLine("# dictionary $([IO.Path]::GetFileName($Dictionary)): $nTranslated entries translated ($nAssembled of them from parts:")
[void]$out.AppendLine('# check their word order), and ' + $nMissing + ' at the end that are still in English.')
if ($nAdded) { [void]$out.AppendLine("# $nAdded of the translations were made by hand, in $([IO.Path]::GetFileName($Additions)).") }
[void]$out.AppendLine('# To use it, copy it to the lang folder of the application as pfc.lng.')
[void]$out.AppendLine('#')
[void]$out.AppendLine('# In the texts: %s (or %1 - %9) is a value, ~r~n a line break, ~" a quote, ~~ a tilde,')
[void]$out.AppendLine('# & marks the access key of a caption, and ~t separates a menu item from its shortcut.')
[void]$out.AppendLine('')
foreach ($l in $body) { [void]$out.AppendLine($l) }
if ($missing.Count) {
    [void]$out.AppendLine('')
    [void]$out.AppendLine('# Module: Not translated yet (English)')
    foreach ($l in $missing) { [void]$out.AppendLine($l) }
}

$dir = Split-Path $Output
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
[IO.File]::WriteAllText($Output, $out.ToString().Replace("`r`n", "`n").Replace("`n", "`r`n"), [System.Text.UnicodeEncoding]::new($false, $true))
foreach ($k in $added.Keys) { if (-not $used.Contains($k)) { Write-Warning "${Additions}: not in the English file: $k" } }
Write-Host ("{0}: {1} translated ({2} from parts, {3} by hand), {4} not translated" -f $Output, $nTranslated, $nAssembled, $nAdded, $nMissing)
