PowerBuilder Foundation Classes

To get the PBLs, fork the project into your own workspace and then do a Connect to Workspace/Solution from the PowerBuilder IDE.  That will download all the source and create the PBLs with the latest changes.

<img width="802" height="91" alt="image" src="https://github.com/user-attachments/assets/9948fd63-e0dc-4406-9653-6027cc51effc" />

Once you have forked the project your copy will show you when we have made additional changes and you can sync your fork to update your copy.

<img width="1157" height="80" alt="image" src="https://github.com/user-attachments/assets/1a708200-0ddc-4355-9afe-9800447323bf" />

## PowerBuilder version

PFC 2025 is meant for PowerBuilder 2025 R2: PFC's message box and printed TreeView, and the Examples app and PEAT, show SVG images, which PowerBuilder shows from 2025 R2. PFC itself also works with PowerBuilder 2025 GA after a few changes to use PNG versions of its images; see [pfc libs/images](pfc%20libs/images/README.md#powerbuilder-2025-ga). The Examples app and PEAT need 2025 R2.

## The Examples app

The `pfc examples` target is a catalog of small windows that each show a PFC service at work.  See [examples/README.md](examples/README.md) for setting it up (the EASDEMO database and the images) and for the list of examples.

## Demo apps

- `peat demo app` (PEAT, in `demoapp`): a small project estimation and tracking application built with PFC, with a ribbon, a UI theme and SVG icons. See [demoapp/README.md](demoapp/README.md).
- `openid demo`: signing in with an OpenID Connect identity provider (Authentik, Microsoft Entra ID, Google), the OAuth 2.0 flows, and PFC security from the provider's groups. See [openid demo/README.md](openid%20demo/README.md).
- `smtp demo`: sending mail with `n_smtpclient` and an OAuth 2.0 token. See [smtp demo/README.md](smtp%20demo/README.md).

## Documentation

The PFC documentation (the User's Guide and the Object Reference, converted to Markdown and kept up to date) is in the [docs](https://github.com/OpenSourcePFCLibraries/docs) repository.

## Help files

The help files are PDF files, and they are not included in this repository.  Download them and put them beside your application's exe:

- [pfcdlg.pdf](https://github.com/OpenSourcePFCLibraries/docs/raw/main/dialog-help/pfcdlg.pdf): help for the PFC dialogs, which their Help buttons open (built from the [dialog help](https://github.com/OpenSourcePFCLibraries/docs/tree/main/dialog-help) in the docs repository)
- [PFCEXAMP.pdf](https://github.com/OpenSourcePFCLibraries/Example-application-help-file/releases/latest/download/PFCEXAMP.pdf): help for the PFC example application ([Example-application-help-file](https://github.com/OpenSourcePFCLibraries/Example-application-help-file/releases/latest))
- [pfctutor.pdf](https://github.com/OpenSourcePFCLibraries/PFCTUTOR-help-file-and-source/releases/latest/download/pfctutor.pdf): help for the PFC tutorial ([PFCTUTOR-help-file-and-source](https://github.com/OpenSourcePFCLibraries/PFCTUTOR-help-file-and-source/releases/latest))

PFC's help service (`n_cst_help`, started with `gnv_app.of_SetHelp(True)`) shows a PDF help file at a topic, in a window of the application (`w_helpviewer`, with the Microsoft Edge WebView2 PDF viewer) or, with `gnv_app.inv_help.of_SetViewer(gnv_app.inv_help.PDFVIEWER)`, in the user's PDF viewer.  A topic is a named destination in the PDF file: `topic_<number>` for a help topic number, or a name, such as the PFC dialogs' `w_find`.  Compiled HTML Help (.chm) files are still shown with ShowHelp.

## Building from the command line

`tools\build.ps1` (PowerShell 7) refreshes the PBLs from the source in `ws_objects`, the same as the IDE's refresh, and then builds targets with PowerBuilder 2025's PBAutoBuild, without opening the IDE. Close PowerBuilder first, because the IDE keeps the PBLs open.

```
pwsh -File tools\build.ps1                                          # refresh and build the PEAT demo
pwsh -File tools\build.ps1 -Target "peat demo app,security administrator"
pwsh -File tools\build.ps1 -All -Full                               # every target, full compilation
pwsh -File tools\build.ps1 -NoBuild                                 # only refresh the PBLs
```

The exe and PBDs go to `build\<target>\`. The script exits with 0 on success, 1 if the refresh or a build fails (compile errors are listed), and 2 if it could not start. The refresh imports every object of a target, so it takes a minute or so; the build is incremental unless you pass `-Full`.

The refresh uses `refresh.json`, a PBAutoBuild build file with a "Merging" entry for each target, which can also be run on its own: `pbautobuild250 /f refresh.json`.

If you would like to contribute to the project, please watch this video:

https://vimeo.com/478243534
