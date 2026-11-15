<#
.SYNOPSIS
    Adds an intermediate extension level (a "PFD" layer) between the PFC ancestor level
    (pfc_ objects) and the PFC extension level (pfe libraries), in a PowerBuilder 2025
    solution (.pbsln) or workspace (.pbw).

.DESCRIPTION
    This does what the PowerBuilder IDE's PFC Library Extender wizard did. For each
    object X in the extension libraries (pfe*.pbl) that inherits directly from pfc_X, it:

      1. Creates pfd_X, inheriting from pfc_X, in an intermediate library (pfemain.pbl's
         objects go to pfdmain.pbl, pfeapsrv.pbl's to pfdapsrv.pbl, and so on).
      2. Changes X to inherit from pfd_X instead of pfc_X. Anything else in X (your
         changes to the extension level) stays as it is.
      3. Adds the intermediate libraries to the library list of every project (.pbproj) or
         target (.pbt) that uses the extension libraries, after the last extension library.

    You put your corporate or departmental changes in the pfd_ objects. When a new PFC
    release comes out, replace the pfc and pfe libraries with the new ones and run this
    script again: it finds the pfd_ objects you already have, leaves them alone, and points
    the new pfe objects back at them. Objects that are new in the release get new pfd_
    objects. Running the script again is always safe: objects that already inherit from
    their pfd_ object are left alone.

    To add another level (for example a department level below a corporate one), run it
    again with -AncestorPrefix set to the existing level's prefix and new -LayerPrefix and
    -LayerLibraryPrefix values.

    The script works on source code only:

    - Solution mode (.pbsln): the libraries are folders of source files. The script writes
      and changes those files and the .pbproj files. Use -Build, or a full build in the
      IDE, to compile.
    - Workspace mode (.pbw): the libraries are binary PBL files, so the script works on the
      source in the workspace's ws_objects folder (the workspace must be under source
      control, and ws_objects must be up to date) and changes the .pbt files. Then it must
      import that source into the PBLs: -Build does that with PBAutoBuild (a "Merging"
      step with RefreshPbl false), which also creates the new PBLs.

    Close the solution or workspace in the PowerBuilder IDE before you run the script.
    Commit (or back up) first, so you can review the changes and undo them. -WhatIf shows
    what would change without changing anything.

.PARAMETER Path
    The solution (.pbsln) or workspace (.pbw) to extend.

.PARAMETER Project
    Only change these projects or targets (file names, with or without the extension;
    wildcards allowed). The default is every project or target that uses the extension
    libraries. The objects in the extension libraries are changed either way, so every
    project that uses those libraries needs the intermediate libraries in its library list.

.PARAMETER AncestorPrefix
    The prefix of the ancestor level's objects. Default: pfc_

.PARAMETER LayerPrefix
    The prefix of the new level's objects. Default: pfd_

.PARAMETER ExtensionLibraryPrefix
    The extension libraries are the libraries whose names start with this. Default: pfe

.PARAMETER LayerLibraryPrefix
    Each new library is named after its extension library, with ExtensionLibraryPrefix
    replaced by this. Default: pfd (pfemain.pbl -> pfdmain.pbl)

.PARAMETER LayerLibrary
    Put all of the new objects in this one library (for example "pfdcorp") instead of
    one new library per extension library.

.PARAMETER LayerLibraryFolder
    The folder for the new libraries, relative to the solution or workspace folder. The
    default is the folder of the extension libraries.

.PARAMETER Include
    Only create pfd_ objects for extension objects whose names match one of these
    wildcard patterns (for example u_dw, w_*). Default: all of them.

.PARAMETER Exclude
    Don't create pfd_ objects for extension objects whose names match one of these
    wildcard patterns.

.PARAMETER Comment
    The object comment for the new objects; {0} is replaced with the ancestor's name.

.PARAMETER Build
    After the changes, run PBAutoBuild for every project or target that uses the extension
    libraries: in solution mode, a PBC full compile (of the whole solution, or of each
    project given with -Project); in workspace mode, import the source into the PBLs
    (Merging, RefreshPbl false), which compiles them. Logs go to the build folder next to
    the solution or workspace.

.PARAMETER PBAutoBuild
    The path to pbautobuild250.exe. Default: the one in the PowerBuilder 2025 IDE folder,
    or else the one in the PowerBuilder Utilities folder.

.EXAMPLE
    pwsh -File tools\New-PfcExtensionLayer.ps1 -Path "C:\src\MyApp\MyApp.pbsln" -WhatIf

    Shows what would be created and changed.

.EXAMPLE
    pwsh -File tools\New-PfcExtensionLayer.ps1 -Path "C:\src\MyApp\MyApp.pbsln" -Build

    Creates the pfd layer in a solution and compiles it.

.EXAMPLE
    pwsh -File tools\New-PfcExtensionLayer.ps1 -Path "C:\src\MyApp\MyApp.pbw" -Build

    Creates the pfd layer in a workspace (source in ws_objects) and imports it into the PBLs.

.EXAMPLE
    pwsh -File tools\New-PfcExtensionLayer.ps1 -Path MyApp.pbsln -AncestorPrefix pfd_ -LayerPrefix dpt_ -LayerLibraryPrefix dpt

    Adds a department level (dpt_ objects in dpt*.pbl) between an existing pfd level and
    the pfe level.

.NOTES
    Exit code: 0 = done (and, with -Build, built without errors), 1 = PBAutoBuild reported
    errors, 2 = the script could not run (file not found, bad source, ...).

    Workspace mode: don't use a PBAutoBuild "Merging" step with RefreshPbl true (a full
    refresh of the PBLs) on a workspace that has an intermediate level. PowerBuilder 2025's
    full refresh fails to compile it ("Illegal data type: u_dw" and similar errors), even
    though an incremental merge, a full PBC build and the IDE all compile it.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,
    [string[]]$Project,
    [string]$AncestorPrefix = 'pfc_',
    [string]$LayerPrefix = 'pfd_',
    [string]$ExtensionLibraryPrefix = 'pfe',
    [string]$LayerLibraryPrefix = 'pfd',
    [string]$LayerLibrary,
    [string]$LayerLibraryFolder,
    [string[]]$Include = @('*'),
    [string[]]$Exclude = @(),
    [string]$Comment = 'Intermediate extension level of {0}',
    [switch]$Build,
    [string]$PBAutoBuild
)

$ErrorActionPreference = 'Stop'
$SourceExtensions = @('.sru', '.srw', '.srm')
# Characters that can be part of a PowerScript identifier
$IdentChars = '[\w$#%-]'

function Stop-Script([string]$Message) {
    Write-Host "Error: $Message" -ForegroundColor Red
    exit 2
}

# --- Text files ---------------------------------------------------------------------

# Reads a text file, remembering its encoding so it can be written back the same way.
function Read-TextFile([string]$File) {
    $bytes = [IO.File]::ReadAllBytes($File)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $encoding = New-Object Text.UTF8Encoding($true); $skip = 3
    }
    elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
        $encoding = New-Object Text.UnicodeEncoding($false, $true); $skip = 2
    }
    else {
        $encoding = New-Object Text.UTF8Encoding($false); $skip = 0
    }
    $text = $encoding.GetString($bytes, $skip, $bytes.Length - $skip)
    $newline = if ($text -match "`r`n") { "`r`n" } elseif ($text -match "`n") { "`n" } else { "`r`n" }
    [pscustomobject]@{ Text = $text; Encoding = $encoding; NewLine = $newline }
}

function Write-TextFile([string]$File, [string]$Text, [Text.Encoding]$Encoding) {
    $dir = Split-Path -Parent $File
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [IO.File]::WriteAllText($File, $Text, $Encoding)
}

# --- Paths --------------------------------------------------------------------------

function Get-FullPath([string]$BaseDir, [string]$RelativePath) {
    [IO.Path]::GetFullPath([IO.Path]::Combine($BaseDir, $RelativePath))
}

function Get-RelativePath([string]$BaseDir, [string]$FullPath) {
    $baseUri = New-Object Uri(($BaseDir.TrimEnd('\') + '\'))
    $targetUri = New-Object Uri($FullPath)
    [Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()).Replace('/', '\')
}

function Test-SamePath([string]$A, [string]$B) {
    [string]::Equals($A.TrimEnd('\'), $B.TrimEnd('\'), [StringComparison]::OrdinalIgnoreCase)
}

function Test-NameMatch([string]$Name, [string[]]$Patterns) {
    foreach ($pattern in $Patterns) { if ($Name -like $pattern) { return $true } }
    $false
}

# --- Solution and workspace files ---------------------------------------------------

# Returns the project (.pbproj) or target (.pbt) files of the solution or workspace.
function Get-ProjectFiles([string]$ContainerFile, [string]$Mode) {
    $dir = Split-Path -Parent $ContainerFile
    $text = (Read-TextFile $ContainerFile).Text
    if ($Mode -eq 'Solution') {
        $xml = [xml]$text
        foreach ($node in @($xml.Solution.Projects.Project)) {
            if ($node) { Get-FullPath $dir $node.Path }
        }
    }
    else {
        $block = [regex]::Match($text, '(?s)@begin Targets(.*?)@end;')
        if (-not $block.Success) { Stop-Script "No targets found in $ContainerFile" }
        foreach ($m in [regex]::Matches($block.Groups[1].Value, '"([^"]+)"')) {
            Get-FullPath $dir $m.Groups[1].Value
        }
    }
}

# Reads a project's or target's library list (full paths of the libraries).
function Read-ProjectFile([string]$File, [string]$Mode) {
    $content = Read-TextFile $File
    $dir = Split-Path -Parent $File
    $libraries = New-Object System.Collections.Generic.List[string]
    if ($Mode -eq 'Solution') {
        foreach ($m in [regex]::Matches($content.Text, '<Library\s+Path="([^"]*)"')) {
            $libraries.Add((Get-FullPath $dir ([Net.WebUtility]::HtmlDecode($m.Groups[1].Value))))
        }
    }
    else {
        $m = [regex]::Match($content.Text, '(?m)^LibList\s+"((?:[^"\\]|\\.)*)"')
        if (-not $m.Success) { Stop-Script "No LibList found in $File" }
        foreach ($entry in ($m.Groups[1].Value -replace '\\\\', '\') -split ';') {
            if ($entry.Trim()) { $libraries.Add((Get-FullPath $dir $entry.Trim())) }
        }
    }
    [pscustomobject]@{ File = $File; Name = [IO.Path]::GetFileName($File); Dir = $dir
        Content = $content; Libraries = $libraries }
}

# Returns the project file's text with $NewLibraries inserted after $AfterLibrary.
function Add-ProjectLibraries($ProjectInfo, [string]$Mode, [string]$AfterLibrary, [string[]]$NewLibraries) {
    $text = $ProjectInfo.Content.Text
    $nl = $ProjectInfo.Content.NewLine
    $relative = @($NewLibraries | ForEach-Object { Get-RelativePath $ProjectInfo.Dir $_ })
    if ($Mode -eq 'Solution') {
        $lines = [regex]::Split($text, "`r?`n")
        $result = New-Object System.Collections.Generic.List[string]
        foreach ($line in $lines) {
            $result.Add($line)
            $m = [regex]::Match($line, '^(\s*)<Library\s+Path="([^"]*)"')
            if ($m.Success) {
                $lib = Get-FullPath $ProjectInfo.Dir ([Net.WebUtility]::HtmlDecode($m.Groups[2].Value))
                if (Test-SamePath $lib $AfterLibrary) {
                    foreach ($rel in $relative) {
                        $result.Add(('{0}<Library Path="{1}"/>' -f $m.Groups[1].Value, [Security.SecurityElement]::Escape($rel)))
                    }
                }
            }
        }
        return ($result -join $nl)
    }
    $m = [regex]::Match($text, '(?m)^LibList\s+"((?:[^"\\]|\\.)*)"')
    $entries = New-Object System.Collections.Generic.List[string]
    foreach ($entry in ($m.Groups[1].Value -replace '\\\\', '\') -split ';') {
        if (-not $entry.Trim()) { continue }
        $entries.Add($entry)
        if (Test-SamePath (Get-FullPath $ProjectInfo.Dir $entry.Trim()) $AfterLibrary) {
            foreach ($rel in $relative) { $entries.Add($rel) }
        }
    }
    $value = ($entries -join ';').Replace('\', '\\')
    $text.Substring(0, $m.Groups[1].Index) + $value + $text.Substring($m.Groups[1].Index + $m.Groups[1].Length)
}

# --- Libraries and objects ----------------------------------------------------------

# The folder that holds a library's source: the library folder itself in a solution, the
# library's folder under ws_objects in a workspace.
function Get-SourceFolder([string]$Library) {
    if ($script:Mode -eq 'Solution') { return $Library }
    $relative = Get-RelativePath $script:ContainerDir $Library
    Join-Path (Join-Path $script:ContainerDir 'ws_objects') ($relative + '.src')
}

# Reads the "global type X from Y" line of an object's source.
function Get-ObjectHeader([string]$Text) {
    $m = [regex]::Match($Text, '(?im)^global\s+type\s+(\S+)\s+from\s+(\S+)')
    if (-not $m.Success) { return $null }
    [pscustomobject]@{ Name = $m.Groups[1].Value; Ancestor = $m.Groups[2].Value }
}

# Builds the source of the new-level object $NewName from the source of the extension
# object $Name (which inherits from $Ancestor). It keeps only what PowerBuilder needs for an
# empty descendant of $Ancestor: the object's create and destroy calls, the inherited menu
# items' create and destroy calls, and the declarations of inherited controls. Anything the
# extension object adds (variables, scripts, properties, controls, menu items) is left out.
function New-LayerSource([string]$Text, [string]$Name, [string]$Ancestor, [string]$NewName,
    [string]$Extension, [string]$NewLine) {
    $ancestorRef = [regex]::Escape($Ancestor) + '`'
    $lines = [regex]::Split($Text, "`r?`n")
    $own = [ordered]@{}
    $items = New-Object System.Collections.Generic.List[string]
    $controls = New-Object System.Collections.Generic.List[string]
    $inForward = $false
    $block = $null
    foreach ($line in $lines) {
        if ($null -ne $block) {
            if ($line -match '^\s*end\s+on\s*$') {
                if ($block.Name -ieq $Name) {
                    $kept = New-Object System.Collections.Generic.List[string]
                    foreach ($l in $block.Lines) {
                        if ($l -match ('^\s*' + [regex]::Escape($Name) + '\s*=\s*this\s*$')) { $kept.Add("$NewName=this") }
                        elseif ($l -match ('^\s*call\s+\S+::' + $block.Kind + '\s*$')) { $kept.Add($l.Trim()) }
                    }
                    $own[$block.Kind] = $kept
                }
                else {
                    foreach ($l in $block.Lines) {
                        if ($l -match ('^\s*call\s+' + $ancestorRef + '\S+::' + $block.Kind + '\s*$')) {
                            $items.Add(("on {0}.{1}{2}{3}{2}end on" -f $block.Name, $block.Kind, $NewLine, $l.Trim()))
                            break
                        }
                    }
                }
                $block = $null
            }
            else { $block.Lines.Add($line) }
            continue
        }
        if ($inForward) {
            if ($line -match '^\s*end\s+forward\s*$') { $inForward = $false }
            continue
        }
        if ($line -match '^\s*forward\s*$') { $inForward = $true; continue }
        $m = [regex]::Match($line, '^\s*on\s+(\S+)\.(create|destroy)\s*$', 'IgnoreCase')
        if ($m.Success) {
            $block = @{ Name = $m.Groups[1].Value; Kind = $m.Groups[2].Value.ToLower()
                Lines = (New-Object System.Collections.Generic.List[string]) }
            continue
        }
        $m = [regex]::Match($line, ('^\s*type\s+(\S+)\s+from\s+(' + $ancestorRef + '\S+)\s+within\s+(\S+)\s*$'), 'IgnoreCase')
        if ($m.Success) {
            $parent = if ($m.Groups[3].Value -ieq $Name) { $NewName } else { $m.Groups[3].Value }
            $controls.Add(("type {0} from {1} within {2}{3}end type" -f $m.Groups[1].Value, $m.Groups[2].Value, $parent, $NewLine))
        }
    }

    $out = New-Object System.Collections.Generic.List[string]
    $objectComment = $Comment -f $Ancestor
    if ($Text.TrimStart([char]0xFEFF) -match '^\$PBExportHeader\$') {
        $out.Add('$PBExportHeader$' + $NewName + $Extension)
        $out.Add('$PBExportComments$' + $objectComment)
    }
    else {
        $out.Add('//objectcomments ' + $objectComment)
    }
    $out.Add('forward'); $out.Add("global type $NewName from $Ancestor"); $out.Add('end type'); $out.Add('end forward')
    $out.Add('')
    $out.Add("global type $NewName from $Ancestor"); $out.Add('end type'); $out.Add("global $NewName $NewName")
    $out.Add('')
    foreach ($kind in @('create', 'destroy')) {
        if ($own.Contains($kind)) {
            $out.Add("on $NewName.$kind")
            foreach ($l in $own[$kind]) { $out.Add($l) }
            $out.Add('end on')
            $out.Add('')
        }
    }
    foreach ($item in $items) { $out.Add($item); $out.Add('') }
    foreach ($control in $controls) { $out.Add($control); $out.Add('') }
    ($out -join $NewLine)
}

# Points the extension object at the new-level object: every reference to $Ancestor
# (the ancestor in "from", "call ancestor::create", "ancestor`control") becomes $NewName.
function Set-LayerAncestor([string]$Text, [string]$Ancestor, [string]$NewName) {
    $pattern = '(?i)(?<!' + $IdentChars + ')' + [regex]::Escape($Ancestor) + '(?!' + $IdentChars + ')'
    [regex]::Replace($Text, $pattern, $NewName.Replace('$', '$$'))
}

function Get-LayerLibrary([string]$ExtensionLibrary) {
    $folder = if ($LayerLibraryFolder) { Get-FullPath $script:ContainerDir $LayerLibraryFolder }
              else { Split-Path -Parent $ExtensionLibrary }
    if ($LayerLibrary) {
        $name = [IO.Path]::GetFileNameWithoutExtension($LayerLibrary)
    }
    else {
        $base = [IO.Path]::GetFileNameWithoutExtension($ExtensionLibrary)
        if ($base.StartsWith($ExtensionLibraryPrefix, [StringComparison]::OrdinalIgnoreCase)) {
            $base = $base.Substring($ExtensionLibraryPrefix.Length)
        }
        $name = $LayerLibraryPrefix + $base
    }
    Join-Path $folder ($name + '.pbl')
}

# --- PBAutoBuild --------------------------------------------------------------------

function Invoke-PBAutoBuild([string[]]$Arguments, [string]$Log, [string]$WorkingDirectory) {
    # With /l PBAutoBuild writes the log itself; otherwise the log is its (UTF-16) output
    $stdout = if ($Arguments -contains '/l') { "$Log.stdout" } else { $Log }
    Remove-Item -LiteralPath $Log, $stdout -ErrorAction SilentlyContinue
    $process = Start-Process $script:PBAutoBuildExe -ArgumentList $Arguments -WorkingDirectory $WorkingDirectory `
        -NoNewWindow -Wait -PassThru -RedirectStandardOutput $stdout
    $file = if (Test-Path -LiteralPath $Log) { $Log } else { $stdout }
    $lines = @()
    if (Test-Path -LiteralPath $file) {
        $lines = [IO.File]::ReadAllText($file, [Text.Encoding]::Unicode) -split "`r?`n"
    }
    [pscustomobject]@{ ExitCode = $process.ExitCode; Lines = $lines; Log = $file }
}

function Show-BuildResult($Result) {
    # Case-sensitive: PBAutoBuild also writes "[Normal] [ERROR] Compilation failed", a summary
    $errors = @($Result.Lines | Where-Object { $_ -cmatch '\[Error\]' })
    if ($errors.Count -gt 0) {
        Write-Host "  Errors:"
        $errors | Select-Object -First 60 | ForEach-Object { Write-Host ("    " + ($_ -replace '^\S+ \[Error\]\s?', '')) }
        if ($errors.Count -gt 60) { Write-Host "    ... ($($errors.Count) lines; see the log)" }
    }
    Write-Host ("  {0} error line(s), PBAutoBuild exit code {1}. Log: {2}" -f $errors.Count, $Result.ExitCode, $Result.Log)
    if ($errors.Count -eq 0 -and $Result.ExitCode -ne 0) {
        $Result.Lines | Where-Object { $_.Trim() -and $_ -notmatch '\.\.\.\s*$' } | Select-Object -Last 15 |
            ForEach-Object { Write-Host "    $_" }
    }
    ($errors.Count -eq 0 -and $Result.ExitCode -eq 0)
}

# =====================================================================================

if (-not (Test-Path -LiteralPath $Path)) { Stop-Script "Not found: $Path" }
$ContainerFile = (Resolve-Path -LiteralPath $Path).ProviderPath
$ContainerDir = Split-Path -Parent $ContainerFile
switch ([IO.Path]::GetExtension($ContainerFile).ToLower()) {
    '.pbsln' { $Mode = 'Solution' }
    '.pbw' { $Mode = 'Workspace' }
    default { Stop-Script "Path must be a solution (.pbsln) or a workspace (.pbw): $ContainerFile" }
}
if ($AncestorPrefix -ieq $LayerPrefix) { Stop-Script "AncestorPrefix and LayerPrefix must be different." }
Write-Host "$Mode mode: $ContainerFile"
Write-Host "Adding $LayerPrefix objects between the $AncestorPrefix objects and the objects in the $ExtensionLibraryPrefix* libraries."
if ($Mode -eq 'Workspace' -and -not (Test-Path -LiteralPath (Join-Path $ContainerDir 'ws_objects'))) {
    Stop-Script "No ws_objects folder next to the workspace. The workspace must be under source control, with its source in ws_objects."
}

# --- Projects ------------------------------------------------------------------------

$projects = New-Object System.Collections.Generic.List[object]
foreach ($file in Get-ProjectFiles $ContainerFile $Mode) {
    if (-not (Test-Path -LiteralPath $file)) { Write-Warning "Project not found, skipped: $file"; continue }
    $name = [IO.Path]::GetFileName($file)
    if ($Project) {
        $match = $false
        foreach ($p in $Project) {
            if ($name -like $p -or [IO.Path]::GetFileNameWithoutExtension($name) -like $p) { $match = $true }
        }
        if (-not $match) { continue }
    }
    $info = Read-ProjectFile $file $Mode
    $extensionLibs = @($info.Libraries | Where-Object {
        [IO.Path]::GetFileName($_).StartsWith($ExtensionLibraryPrefix, [StringComparison]::OrdinalIgnoreCase) })
    $info | Add-Member -NotePropertyName ExtensionLibraries -NotePropertyValue $extensionLibs
    if ($extensionLibs.Count -gt 0) { $projects.Add($info) }
}
if ($projects.Count -eq 0) { Stop-Script "No project uses a library whose name starts with '$ExtensionLibraryPrefix'." }

# The extension libraries, in library-list order of first appearance
$extensionLibraries = New-Object System.Collections.Generic.List[string]
foreach ($p in $projects) {
    foreach ($lib in $p.ExtensionLibraries) {
        if (-not ($extensionLibraries | Where-Object { Test-SamePath $_ $lib })) { $extensionLibraries.Add($lib) }
    }
}

# --- Index every object in every library (and in the new libraries, if they exist) -----

$objectLibrary = @{}   # object name -> library (hashtable keys are case-insensitive)
$indexed = @{}
$allLibraries = @($projects | ForEach-Object { $_.Libraries }) + @($extensionLibraries | ForEach-Object { Get-LayerLibrary $_ })
foreach ($lib in $allLibraries) {
    if ($indexed.ContainsKey($lib)) { continue }
    $indexed[$lib] = $true
    $folder = Get-SourceFolder $lib
    if (-not (Test-Path -LiteralPath $folder)) { continue }
    foreach ($f in Get-ChildItem -LiteralPath $folder -File) {
        $objectName = [IO.Path]::GetFileNameWithoutExtension($f.Name)
        if (-not $objectLibrary.ContainsKey($objectName)) { $objectLibrary[$objectName] = $lib }
    }
}

# --- Plan ----------------------------------------------------------------------------

$creates = New-Object System.Collections.Generic.List[object]    # new-level objects to write
$repoints = New-Object System.Collections.Generic.List[object]   # extension objects to change
$alreadyDone = 0
$reused = 0
$skipped = New-Object System.Collections.Generic.List[string]
$dependencies = @{}    # extension library -> new-level libraries its objects inherit from

foreach ($lib in $extensionLibraries) {
    $dependencies[$lib] = New-Object System.Collections.Generic.List[string]
    $folder = Get-SourceFolder $lib
    if (-not (Test-Path -LiteralPath $folder)) { Stop-Script "Source folder not found for $lib`: $folder" }
    $targetLibrary = Get-LayerLibrary $lib
    foreach ($f in Get-ChildItem -LiteralPath $folder -File | Sort-Object Name) {
        if ($SourceExtensions -notcontains $f.Extension.ToLower()) { continue }
        $source = Read-TextFile $f.FullName
        $header = Get-ObjectHeader $source.Text
        if (-not $header) { continue }
        $name = $header.Name
        $newName = $LayerPrefix + $name
        $ancestorName = $AncestorPrefix + $name
        $useLibrary = $null

        if ($header.Ancestor -ieq $newName) {
            # Done on an earlier run
            $alreadyDone++
            if ($objectLibrary.ContainsKey($newName)) { $useLibrary = $objectLibrary[$newName] }
            elseif ($creates | Where-Object { $_.Name -ieq $newName }) { $useLibrary = $targetLibrary }
            else { Write-Warning "$name inherits from $newName, but $newName is not in any library." }
        }
        elseif ($header.Ancestor -ine $ancestorName) {
            $skipped.Add("$name (inherits from $($header.Ancestor))")
            continue
        }
        elseif (-not (Test-NameMatch $name $Include) -or (Test-NameMatch $name $Exclude)) {
            $skipped.Add("$name (excluded)")
            continue
        }
        else {
            if (-not $objectLibrary.ContainsKey($ancestorName)) {
                Write-Warning "$name inherits from $ancestorName, which is not in any library of the projects."
            }
            if ($objectLibrary.ContainsKey($newName)) {
                # The new-level object exists (for example after installing a new PFC release)
                $useLibrary = $objectLibrary[$newName]
                $reused++
            }
            else {
                $useLibrary = $targetLibrary
                $newFile = Join-Path (Get-SourceFolder $targetLibrary) ($newName + $f.Extension.ToLower())
                $newText = New-LayerSource $source.Text $name $header.Ancestor $newName $f.Extension.ToLower() $source.NewLine
                $creates.Add([pscustomobject]@{ Name = $newName; File = $newFile; Text = $newText
                    Encoding = $source.Encoding; Library = $targetLibrary })
                $objectLibrary[$newName] = $targetLibrary
            }
            $repoints.Add([pscustomobject]@{ Name = $name; File = $f.FullName
                Text = (Set-LayerAncestor $source.Text $header.Ancestor $newName); Encoding = $source.Encoding })
        }
        if ($useLibrary -and -not ($dependencies[$lib] | Where-Object { Test-SamePath $_ $useLibrary })) {
            $dependencies[$lib].Add($useLibrary)
        }
    }
}

# Library list changes: each project needs the new-level libraries its extension libraries use
$projectChanges = New-Object System.Collections.Generic.List[object]
foreach ($p in $projects) {
    $missing = New-Object System.Collections.Generic.List[string]
    foreach ($lib in $p.ExtensionLibraries) {
        foreach ($dep in $dependencies[$lib]) {
            $inList = $p.Libraries | Where-Object { Test-SamePath $_ $dep }
            $planned = $missing | Where-Object { Test-SamePath $_ $dep }
            if (-not $inList -and -not $planned) { $missing.Add($dep) }
        }
    }
    if ($missing.Count -gt 0) {
        $after = $p.ExtensionLibraries[$p.ExtensionLibraries.Count - 1]
        $projectChanges.Add([pscustomobject]@{ Project = $p; Libraries = $missing
            Text = (Add-ProjectLibraries $p $Mode $after $missing.ToArray()) })
    }
}

# --- Apply ---------------------------------------------------------------------------

$newLibraries = @($creates | ForEach-Object { $_.Library } | Sort-Object -Unique)
foreach ($lib in $newLibraries) {
    $folder = Get-SourceFolder $lib
    if (-not (Test-Path -LiteralPath $folder) -and $PSCmdlet.ShouldProcess($folder, 'Create library folder')) {
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        if ($Mode -eq 'Solution') {
            # Same format as the .pblmeta files PowerBuilder writes
            $version = '250'
            $sample = Get-ChildItem -LiteralPath $extensionLibraries[0] -Filter *.pblmeta -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($sample) {
                $vm = [regex]::Match((Read-TextFile $sample.FullName).Text, '"version"\s*:\s*"([^"]+)"')
                if ($vm.Success) { $version = $vm.Groups[1].Value }
            }
            $meta = "{`r`n    `"version`": `"$version`",`r`n    `"comment`": `"PFC intermediate extension level`"`r`n}"
            $metaFile = Join-Path $folder ([IO.Path]::GetFileNameWithoutExtension($lib) + '.pblmeta')
            Write-TextFile $metaFile $meta (New-Object Text.UTF8Encoding($true))
        }
    }
}
foreach ($c in $creates) {
    if ($PSCmdlet.ShouldProcess($c.File, 'Create object')) { Write-TextFile $c.File $c.Text $c.Encoding }
}
foreach ($r in $repoints) {
    if ($PSCmdlet.ShouldProcess($r.File, "Change ancestor to $LayerPrefix$($r.Name)")) { Write-TextFile $r.File $r.Text $r.Encoding }
}
foreach ($pc in $projectChanges) {
    $what = 'Add ' + (($pc.Libraries | ForEach-Object { [IO.Path]::GetFileName($_) }) -join ', ') + ' to the library list'
    if ($PSCmdlet.ShouldProcess($pc.Project.File, $what)) {
        Write-TextFile $pc.Project.File $pc.Text $pc.Project.Content.Encoding
    }
}

# --- Report --------------------------------------------------------------------------

Write-Host ""
Write-Host ("{0} {1} object(s) created, {2} extension object(s) pointed at them." -f $creates.Count, $LayerPrefix, $repoints.Count)
if ($reused -gt 0) { Write-Host "$reused extension object(s) pointed at $LayerPrefix objects that already existed." }
if ($alreadyDone -gt 0) { Write-Host "$alreadyDone extension object(s) already inherited from their $LayerPrefix object." }
foreach ($lib in $newLibraries) {
    $count = @($creates | Where-Object { Test-SamePath $_.Library $lib }).Count
    Write-Host ("  {0}: {1} new object(s)" -f (Get-RelativePath $ContainerDir $lib), $count)
}
if ($skipped.Count -gt 0) {
    Write-Host "Not changed (not a direct descendant of a $AncestorPrefix object, or excluded):"
    $skipped | ForEach-Object { Write-Host "  $_" }
}
foreach ($pc in $projectChanges) {
    Write-Host ("Library list of {0}: added {1}" -f $pc.Project.Name, (($pc.Libraries | ForEach-Object { [IO.Path]::GetFileName($_) }) -join ', '))
}
if ($WhatIfPreference) { exit 0 }

if (-not $Build) {
    if ($Mode -eq 'Workspace' -and ($creates.Count -gt 0 -or $repoints.Count -gt 0)) {
        Write-Host ""
        Write-Host "The source in ws_objects has changed, but the PBLs haven't. Run again with -Build to import" -ForegroundColor Yellow
        Write-Host "the source into the PBLs (or use a PBAutoBuild Merging step with RefreshPbl false)." -ForegroundColor Yellow
    }
    exit 0
}

# --- Build ---------------------------------------------------------------------------

if (-not $PBAutoBuild) {
    foreach ($candidate in @("${env:ProgramFiles(x86)}\Appeon\PowerBuilder 25.0\pbautobuild250.exe",
                             "${env:ProgramFiles(x86)}\Appeon\PowerBuilderUtilities 25.0\pbautobuild250.exe")) {
        if (Test-Path -LiteralPath $candidate) { $PBAutoBuild = $candidate; break }
    }
}
if (-not $PBAutoBuild -or -not (Test-Path -LiteralPath $PBAutoBuild)) { Stop-Script "pbautobuild250.exe not found (use -PBAutoBuild)." }
$PBAutoBuildExe = $PBAutoBuild
$buildDir = Join-Path $ContainerDir 'build'
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
$ok = $true

if ($Mode -eq 'Solution') {
    # The whole solution in one compile, or each selected project
    $compileFiles = if ($Project) { @($projects | ForEach-Object { $_.File }) } else { @($ContainerFile) }
    foreach ($file in $compileFiles) {
        Write-Host ""
        Write-Host ("Compiling {0} ..." -f [IO.Path]::GetFileName($file))
        $log = Join-Path $buildDir ("pfcextender-" + [IO.Path]::GetFileNameWithoutExtension($file) + ".log")
        $result = Invoke-PBAutoBuild @('/pbc', '/c', "`"$file`"", '/f') $log (Split-Path -Parent $file)
        if (-not (Show-BuildResult $result)) { $ok = $false }
    }
}
else {
    # PBAutoBuild build file: import the changed source from ws_objects into the PBLs of each
    # target. RefreshPbl must be false (see .NOTES).
    $merging = @($projects | ForEach-Object {
        [ordered]@{ Target = $_.File; LocalProjectPath = $ContainerDir; RefreshPbl = $false } })
    $buildFile = [ordered]@{
        # PBAutoBuild requires RuntimeVersion: use its own version (for example 25.1.0.6430)
        MetaInfo = [ordered]@{ IDEVersion = '250'
            RuntimeVersion = (Get-Item -LiteralPath $PBAutoBuildExe).VersionInfo.FileVersion
            BuildFileVersion = '1.0.0.1' }
        BuildPlan = [ordered]@{
            SourceControl = [ordered]@{ PreCommand = ''; ClearSrcBeforeDownload = $false; SVN = @(); Git = @(); VSS = @()
                Merging = $merging; PostCommand = '' }
            BuildJob = [ordered]@{ PreCommand = ''; Projects = @(); PostCommand = '' }
        }
    }
    $jsonFile = Join-Path $buildDir 'pfcextender-merge.json'
    [IO.File]::WriteAllText($jsonFile, ($buildFile | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))
    Write-Host ""
    Write-Host ("Importing the source into the PBLs of {0} target(s) ..." -f $projects.Count)
    $log = Join-Path $buildDir 'pfcextender-merge.log'
    $result = Invoke-PBAutoBuild @('/f', "`"$jsonFile`"", '/l', "`"$log`"") $log $ContainerDir
    if (-not (Show-BuildResult $result)) { $ok = $false }
}

if (-not $ok) { exit 1 }
exit 0
