# PFC Library Extender

`tools\New-PfcExtensionLayer.ps1` adds an *intermediate extension level* (a "PFD" layer) to the
PowerBuilder Foundation Classes (PFC), in a PowerBuilder 2025 solution (`.pbsln`) or
workspace (`.pbw`). It does what the Library Extender wizard in the PowerBuilder IDE did
for the Sybase PFC (see "Library Extender" in the PFC User's Guide, chapter 7).

## Why an intermediate level?

PFC comes in two levels:

| Level | Libraries | Objects | Who changes it |
|---|---|---|---|
| Ancestor | `pfc*.pbl` | `pfc_u_dw`, `pfc_w_master`, ... | Nobody: replaced by each PFC release |
| Extension | `pfe*.pbl` | `u_dw`, `w_master`, ... (empty descendants) | Application developers |

Your application uses, and inherits from, the extension objects. If you put corporate or
departmental changes in the extension level, they're mixed in with the application
developers' changes, and you have to redo them whenever you take a new PFC release.

An intermediate level puts your shared changes in their own objects:

```
pfc_u_dw  (pfcmain.pbl)   PFC ancestor: replaced by each PFC release
   ^
pfd_u_dw  (pfdmain.pbl)   intermediate level: your corporate changes
   ^
u_dw      (pfemain.pbl)   extension level: used by the application
```

When a new PFC release comes out, you replace the `pfc` and `pfe` libraries and run the
script again. It points the new extension objects back at your `pfd_` objects.

## What the script does

For each object `X` in the extension libraries that inherits directly from `pfc_X`:

1. It creates `pfd_X` (inheriting from `pfc_X`) in an intermediate library named after
   the extension library: `pfemain` → `pfdmain`, `pfeapsrv` → `pfdapsrv`, and so on. The
   new object is an empty descendant, built from the extension object's own source so it
   declares the same inherited controls and menu items.
2. It changes `X` to inherit from `pfd_X`. Nothing else in `X` changes, so any changes
   already made to the extension level stay where they are.
3. It adds the intermediate libraries to the library list of every project (`.pbproj`) or
   target (`.pbt`) that uses the extension libraries, right after the last extension
   library.

Objects that don't inherit directly from a `pfc_` object (in PFC 2025, only `m_frame`,
which inherits from `m_master`) are left alone.

It's safe to run again:

- Objects that already inherit from their `pfd_` object are left alone.
- If `pfd_X` already exists (for example, after you install a new PFC release), the script
  points `X` at it and doesn't touch `pfd_X`.
- Objects that are new in a PFC release get new `pfd_` objects.

## Requirements

- PowerBuilder 2025 (PBAutoBuild, `pbautobuild250.exe`, is only needed for `-Build`).
- PowerShell 7 (`pwsh`) or Windows PowerShell 5.1.
- **Solution mode:** nothing else. The libraries are folders of source files.
- **Workspace mode:** the workspace must be under source control, with up-to-date source
  in its `ws_objects` folder. The script changes that source; then PBAutoBuild imports
  it into the PBLs (`-Build`). PBAutoBuild can import source into PBLs but can't export
  it from them, so the script can't work from the PBLs alone.

Close the solution or workspace in the PowerBuilder IDE first, and commit (or back up)
before you run the script, so you can review the changes and undo them.

## Usage

Preview the changes (nothing is written):

```powershell
pwsh -File tools\New-PfcExtensionLayer.ps1 -Path C:\src\MyApp\MyApp.pbsln -WhatIf
```

Create the layer and compile:

```powershell
pwsh -File tools\New-PfcExtensionLayer.ps1 -Path C:\src\MyApp\MyApp.pbsln -Build
```

Workspace: create the layer in `ws_objects` and import it into the PBLs (this creates the
new PBLs):

```powershell
pwsh -File tools\New-PfcExtensionLayer.ps1 -Path C:\src\MyApp\MyApp.pbw -Build
```

### Options

| Parameter | Default | Meaning |
|---|---|---|
| `-Path` | (required) | The `.pbsln` or `.pbw`. |
| `-Project` | all | Only update these projects' or targets' library lists (names, wildcards allowed). |
| `-AncestorPrefix` | `pfc_` | Prefix of the ancestor level's objects. |
| `-LayerPrefix` | `pfd_` | Prefix of the new level's objects. |
| `-ExtensionLibraryPrefix` | `pfe` | The extension libraries are the libraries whose names start with this. |
| `-LayerLibraryPrefix` | `pfd` | Replaces `-ExtensionLibraryPrefix` in the new libraries' names. |
| `-LayerLibrary` | | Put all new objects in this one library (for example `pfdcorp`). |
| `-LayerLibraryFolder` | the extension libraries' folder | Where the new libraries go (relative to the `.pbsln`/`.pbw`). |
| `-Include` / `-Exclude` | all / none | Wildcards for the extension objects to extend (for example `-Include u_dw,w_*`). |
| `-Comment` | `Intermediate extension level of {0}` | Object comment for the new objects. |
| `-Build` | off | Compile (solution) or import into the PBLs (workspace) afterwards. |
| `-PBAutoBuild` | PB 2025 install | Path to `pbautobuild250.exe`. |

`-WhatIf` and `-Verbose` work as usual.

Exit codes: 0 = done, 1 = PBAutoBuild reported errors, 2 = the script couldn't run.

## Taking a new PFC release

1. Commit your current state.
2. Replace the `pfc*` **and** `pfe*` libraries with the ones from the new release. Keep
   your `pfd*` libraries. (If you also made changes in the extension level, merge them
   into the new `pfe` objects, for example with your source control's merge.)
3. Run the script again with `-Build`. The new `pfe` objects inherit from `pfc_` objects
   again; the script finds your existing `pfd_` objects and points the `pfe` objects at
   them. New objects in the release get new `pfd_` objects.
4. Review the changes (your source control's diff shows them) and check the build.
   The `pfd_` objects are ordinary descendants, so a release that changes a `pfc_`
   object affects them the same way it affects any other descendant.

## More than one intermediate level

To put a department level between a corporate `pfd` level and the extension level, run the
script again with the corporate level as the ancestor:

```powershell
pwsh -File tools\New-PfcExtensionLayer.ps1 -Path MyApp.pbsln -AncestorPrefix pfd_ -LayerPrefix dpt_ -LayerLibraryPrefix dpt -Build
```

This creates `dpt_u_dw` (from `pfd_u_dw`) in `dptmain.pbl`, and so on, and points `u_dw` at
`dpt_u_dw`. The library lists end up in inheritance order: `pfe*`, `dpt*`, `pfd*`, `pfc*`.

When you take a new PFC release with more than one level, run the script once per level,
from the top down: first with the defaults (this points the new `pfe` objects at your
`pfd_` objects), then with `-AncestorPrefix pfd_ -LayerPrefix dpt_ -LayerLibraryPrefix dpt`
(this points them on at your `dpt_` objects).

## Tested

With PowerBuilder 2025 R2 (build 6430), on copies of the PFC 2025 solution and workspace:

| Scenario | Result |
|---|---|
| Solution: create the layer (256 objects, 5 libraries, 8 projects), PBC full compile of the solution | 0 errors; same 20 warnings as the unchanged solution |
| Workspace: create the layer, `-Build` (merge into 7 targets) | 5 new PBLs, 0 errors; full PBC build of `pfc examples.pbt` also 0 errors |
| Run again | Nothing changed |
| New release: pfe sources replaced, a project's library list reset, one new pfc/pfe object, a customized `pfd_u_dw` | The 256 existing `pfd_` objects were reused unchanged (the customization kept), 1 new `pfd_` object, the libraries added back, the pfe sources exactly as after the first run |
| A second (`dpt_`) level, PBC full compile | 0 errors |
| Windows PowerShell 5.1 | Same plan as PowerShell 7 (`-WhatIf`) |

## Known issue (workspace mode)

Prefer an incremental merge (`"RefreshPbl": false`, which is what `-Build` uses) to a full
refresh of the PBLs from source (`"RefreshPbl": true`) on a workspace that has an
intermediate level. In PowerBuilder 2025 (25.1.0.6430), the full refresh sometimes fails.
PBAutoBuild logs `An exception occurred in the merge object, try again` during
`cm_rebuild_application`, and the retry then fails with errors such as `Illegal data type:
u_dw` from `pfc_u_dw::of_setbase`.

It's intermittent. In our tests, 5 of 26 full refreshes with an intermediate level failed,
and running the refresh again on the same source then succeeded. None of 10 without an
intermediate level failed, though that's too few runs to say it never happens. An
incremental merge and a full PBC build compiled the same source every time. If a full
refresh fails this way, run it again.
