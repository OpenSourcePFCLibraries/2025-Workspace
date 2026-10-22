<#
.SYNOPSIS
    Generates an English language file from PowerBuilder source: lang\pfc.lng for PFC, or an
    application's own file (lang\<application>.lng).

.DESCRIPTION
    Reads the PowerScript and DataWindow source in "pfc libs" and writes every text the PFC
    language service (n_cst_language) can translate:

      Messages, by ID:      pfc_logon_enterid="Please enter a User ID to logon."
                            pfc_logon_enterid.title="Logon"   (when the title is a literal)
         from the of_MessageBox("pfc_...", title, text, ...) calls whose text is made of
         string literals only (messages with values use %s placeholders), and from the
         of_GetText("pfc_...", "text", ...) calls.

      Captions, by text:    "&Cancel"="&Cancel"
         the Text, Title, MicroHelp, ToolbarItemText and PowerTipText of windows, controls,
         user objects and menu items, and the text objects and code table display values of
         DataWindow objects. List box items are not included: code often uses them as values.

    The file is UTF-16 with a byte order mark and CRLF line endings, like PowerBuilder's
    lang\default.lng. To translate PFC, copy it to the lang folder of the application and
    translate the texts on the right of the equal signs (or use New-PfcTranslation.ps1 to
    start from a Translation Toolkit dictionary).

    For an application, point -Source at the application's source and give the prefix of its
    message IDs with -IdPrefix. The service reads the application's file, lang\<application>.lng
    (the name of the application object), after lang\pfc.lng, and its entries take precedence.

.PARAMETER Source
    Folder with the PFC library source. Default: "ws_objects\pfc libs" in the workspace.
.PARAMETER Output
    The language file to write. Default: lang\pfc.lng in the repository.
.PARAMETER IdPrefix
    The prefix of the message IDs to collect (of_MessageBox and of_GetText). Default: pfc.
.PARAMETER Except
    A language file whose entries are left out, for example lang\pfc.lng when generating an
    application's file: the captions PFC already has don't need repeating.

.EXAMPLE
    pwsh -File tools\New-PfcLanguageFile.ps1
.EXAMPLE
    pwsh -File tools\New-PfcLanguageFile.ps1 -Source C:\MyApp\src -IdPrefix app_ -Except lang\pfc.lng -Output C:\MyApp\lang\myapp.lng
#>
[CmdletBinding()]
param(
    [string]$Source = (Join-Path $PSScriptRoot '..\ws_objects\pfc libs'),
    [string]$Output = (Join-Path $PSScriptRoot '..\lang\pfc.lng'),
    [string]$IdPrefix = 'pfc',
    [string]$Except
)
$ErrorActionPreference = 'Stop'

# Reads a PowerScript string literal starting at $pos (a " or '); returns the text and the
# position after the closing quote.
function Read-Literal([string]$s, [int]$pos) {
    $q = $s[$pos]; $sb = [System.Text.StringBuilder]::new(); $i = $pos + 1
    while ($i -lt $s.Length) {
        $c = $s[$i]
        if ($c -eq '~' -and $i + 1 -lt $s.Length) {
            $n = $s[$i + 1]
            switch -CaseSensitive ($n) {
                'n' { [void]$sb.Append("`n") }
                'r' { [void]$sb.Append("`r") }
                't' { [void]$sb.Append("`t") }
                default { [void]$sb.Append($n) }
            }
            $i += 2; continue
        }
        if ($c -eq $q) { return @{ Text = $sb.ToString(); Next = $i + 1 } }
        [void]$sb.Append($c); $i++
    }
    return @{ Text = $sb.ToString(); Next = $i }
}

# Splits the arguments of a call that starts after "(" at $pos. Each argument is
# @{ Literal = <text, or $null if it isn't made of string literals only> }.
function Read-Arguments([string]$s, [int]$pos) {
    $args2 = [System.Collections.Generic.List[object]]::new()
    $depth = 0; $lit = ''; $onlyLit = $true; $hasLit = $false; $i = $pos
    while ($i -lt $s.Length) {
        $c = $s[$i]
        if ($c -eq '"' -or $c -eq "'") {
            $r = Read-Literal $s $i; $lit += $r.Text; $hasLit = $true; $i = $r.Next; continue
        }
        if ($c -eq '(') { $depth++; $onlyLit = $false }
        elseif ($c -eq ')') {
            if ($depth -eq 0) { $args2.Add(@{ Literal = $(if ($onlyLit -and $hasLit) { $lit } else { $null }) }); break }
            $depth--
        }
        elseif ($c -eq ',' -and $depth -eq 0) {
            $args2.Add(@{ Literal = $(if ($onlyLit -and $hasLit) { $lit } else { $null }) })
            $lit = ''; $onlyLit = $true; $hasLit = $false
        }
        elseif ($c -eq '&' -or $c -eq '+' -or [char]::IsWhiteSpace($c)) { }
        else { $onlyLit = $false }
        $i++
    }
    return $args2
}

# Escapes a text for the language file (inside double quotes)
function ConvertTo-LngText([string]$t) {
    $t.Replace('~', '~~').Replace('"', '~"').Replace("`t", '~t').Replace("`r", '~r').Replace("`n", '~n')
}

$messages = [ordered]@{}; $titles = @{}; $conflicts = [System.Collections.Generic.List[string]]::new()
# Message IDs that PFC uses with different texts: the object whose text goes in the file
# (pfc_checkrequired_missingvalue: the DataWindow's text, which users see, not the DataStore's)
$preferred = @{ 'pfc_checkrequired_missingvalue' = 'pfc_u_dw.sru' }
$captions = [System.Collections.Generic.SortedSet[string]]::new([StringComparer]::Ordinal)
# Controls whose text is data, not a caption
$dataControls = '^(u_)?(sle|mle|em|ddlb|ddplb|lb|plb|rte|singlelineedit|multilineedit|editmask|dropdownlistbox|dropdownpicturelistbox|listbox|picturelistbox|richtextedit)$'

function Add-Caption([string]$t) {
    # Not captions: texts without letters, single characters (symbol font glyphs on buttons)
    # and placeholder names such as pfcmru1 or st_history
    if ($t -notmatch '\p{L}' -or $t.Trim().Length -le 1) { return }
    if ($t -cmatch '^[a-z][a-z0-9_]*$' -and $t -match '[0-9_]') { return }
    [void]$script:captions.Add($t)
}

$files = Get-ChildItem -Path $Source -Recurse -File -Include *.sru, *.srw, *.srm, *.srf, *.srd
foreach ($f in $files) {
    $s = [IO.File]::ReadAllText($f.FullName)

    if ($f.Extension -eq '.srd') {
        # Text objects (not expressions) and code table display values
        foreach ($m in [regex]::Matches($s, '(?m)^text\(.*?\btext="')) {
            $r = Read-Literal $s ($m.Index + $m.Length - 1)
            if ($r.Text -notmatch "`t") { Add-Caption $r.Text }
        }
        foreach ($m in [regex]::Matches($s, '\bvalues="')) {
            $r = Read-Literal $s ($m.Index + $m.Length - 1)
            foreach ($item in $r.Text.Split('/')) {
                $tab = $item.IndexOf("`t"); if ($tab -gt 0) { Add-Caption $item.Substring(0, $tab) }
            }
        }
        continue
    }

    # Messages: of_MessageBox("pfc_...", title, text, ...)
    foreach ($m in [regex]::Matches($s, '(?i)(?<!function integer )\bof_messagebox\s*\(')) {
        $a = Read-Arguments $s ($m.Index + $m.Length)
        if ($a.Count -lt 3) { continue }
        $id = $a[0].Literal
        if (-not $id -or $id -notmatch ('^' + [regex]::Escape($IdPrefix))) { continue }
        $text = $a[2].Literal
        if ($null -eq $text) { continue }
        $key = $id.ToLowerInvariant()
        if ($preferred.ContainsKey($key) -and $preferred[$key] -eq $f.Name) {
            $messages[$key] = $text
            if ($a[1].Literal) { $titles[$key] = $a[1].Literal }
        } elseif ($messages.Contains($key)) {
            if ($messages[$key] -cne $text -and -not $preferred.ContainsKey($key)) {
                $conflicts.Add("$id ($($f.Name)): ""$text"" (kept: ""$($messages[$key])"")")
            }
        } else {
            $messages[$key] = $text
            if ($a[1].Literal) { $titles[$key] = $a[1].Literal }
        }
    }

    # Other texts by ID: of_GetText("pfc_...", "English text", ...)
    foreach ($m in [regex]::Matches($s, '(?i)(?<!function string )\bof_gettext\s*\(')) {
        $a = Read-Arguments $s ($m.Index + $m.Length)
        if ($a.Count -lt 2) { continue }
        $id = $a[0].Literal; $text = $a[1].Literal
        if (-not $id -or $id -notmatch ('^' + [regex]::Escape($IdPrefix)) -or $null -eq $text) { continue }
        $key = $id.ToLowerInvariant()
        if ($messages.Contains($key)) {
            if ($messages[$key] -cne $text) { $conflicts.Add("$id ($($f.Name)): ""$text"" (kept: ""$($messages[$key])"")") }
        } else { $messages[$key] = $text }
    }

    # Captions: property values in type definitions and menu create events
    $type = ''
    foreach ($line in $s -split "`r?`n") {
        if ($line -match '^type \S+ from (\S+)') { $type = $Matches[1]; continue }
        if ($line -match '^global type \S+ from (\S+)') { $type = $Matches[1]; continue }
        if ($line -match '^(?:string |this\.)(text|title|microhelp|toolbaritemtext|powertiptext) = (["''])') {
            if ($Matches[1] -eq 'text' -and $type -match $dataControls) { continue }
            $r = Read-Literal $line ($line.IndexOf($Matches[2]))
            Add-Caption $r.Text
        }
    }
}

# Leave out the entries of the -Except file (its lines as they would be written here)
$skip = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
if ($Except) {
    foreach ($l in [IO.File]::ReadAllLines((Resolve-Path $Except), [Text.Encoding]::Unicode)) {
        if ($l -match '^("(?:[^"~]|~.)*")=') { [void]$skip.Add($Matches[1]) }
        elseif ($l -match '^([^#=][^=]*)=') { [void]$skip.Add($Matches[1].Trim().ToLowerInvariant()) }
    }
    foreach ($k in @($messages.Keys)) { if ($skip.Contains($k)) { $messages.Remove($k) } }
    foreach ($c in @($captions)) { if ($skip.Contains('"' + (ConvertTo-LngText $c) + '"')) { [void]$captions.Remove($c) } }
}

$out = [System.Text.StringBuilder]::new()
[void]$out.AppendLine("# Language file $([IO.Path]::GetFileName($Output)): English")
[void]$out.AppendLine('#')
[void]$out.AppendLine('# Generated from the source by tools\New-PfcLanguageFile.ps1. The PFC language service')
[void]$out.AppendLine('# (gnv_app.of_SetLanguage(TRUE)) reads lang\pfc.lng and then lang\<application>.lng in the')
[void]$out.AppendLine('# application folder. To translate, copy this file there and translate the texts on the')
[void]$out.AppendLine('# right of the equal signs.')
[void]$out.AppendLine('#')
[void]$out.AppendLine('# In the texts: %s (or %1 - %9) is a value, ~r~n a line break, ~" a quote, ~~ a tilde,')
[void]$out.AppendLine('# & marks the access key of a caption, and ~t separates a menu item from its shortcut.')
[void]$out.AppendLine('')
[void]$out.AppendLine('# Module: Messages and other texts (of_MessageBox, of_GetText), by ID; ID.title is the title of a message box')
foreach ($key in ($messages.Keys | Sort-Object)) {
    [void]$out.AppendLine("$key=""$(ConvertTo-LngText $messages[$key])""")
    if ($titles.ContainsKey($key)) { [void]$out.AppendLine("$key.title=""$(ConvertTo-LngText $titles[$key])""") }
}
[void]$out.AppendLine('')
[void]$out.AppendLine('# Module: Captions (windows, controls, menus, DataWindow objects), by English text')
foreach ($c in $captions) {
    $e = ConvertTo-LngText $c
    [void]$out.AppendLine("""$e""=""$e""")
}

$dir = Split-Path $Output
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
[IO.File]::WriteAllText($Output, $out.ToString().Replace("`r`n", "`n").Replace("`n", "`r`n"), [System.Text.UnicodeEncoding]::new($false, $true))

Write-Host ("{0}: {1} messages ({2} with a title), {3} captions" -f $Output, $messages.Count, $titles.Count, $captions.Count)
if ($conflicts.Count) {
    Write-Host "Message IDs used with different texts (the first text is used):"
    $conflicts | ForEach-Object { Write-Host "  $_" }
}
