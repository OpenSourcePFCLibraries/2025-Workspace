# PFC's images

The pictures that PFC's own objects show. An application finds them by their file name, so deploy them where it looks for files: beside the executable, in a folder on the system path (or, in the IDE, PowerBuilder's application path), or compiled into the executable by listing them in the application's PBR file.

| File | Used by |
|---|---|
| `pfc_msg_info.svg`, `pfc_msg_stop.svg`, `pfc_msg_warning.svg`, `pfc_msg_question.svg` | The message box (`w_message`), as the icon of an information, error, warning or question message |
| `pfc_drag_left.ico`, `pfc_drag_right.ico` | The drag-and-drop Sort dialog box (`w_sortdragdrop`), as the drag icons |
| `pfc_tree_line.svg`, `pfc_tree_branch.svg`, `pfc_tree_last.svg`, `pfc_tree_plus.svg`, `pfc_tree_minus.svg` | A printed TreeView (`d_printtree`, from `u_tv` and `n_cst_tvsrv_print` `of_PrintTree`), as the lines and the expand and collapse boxes |
| `pfc_tree_folder.svg`, `pfc_tree_folder_open.svg` | A printed TreeView, as the default item and selected item pictures |

The icons are from Microsoft's [Fluent UI System Icons](https://github.com/microsoft/fluentui-system-icons) (MIT license, in `LICENSE-fluentui-system-icons.txt`). The printed tree's lines and boxes are drawn for PFC, at the pixels of the older bitmaps, and the drag icons are ICO files because a drag icon must be one.

## Compiling them into the executable

`pfc libs\pfc.pbr` is PFC's resource file: the DataWindow objects that PFC's objects name only in their scripts (so the compiler doesn't include them by itself) and these images. Use it as the executable's PBR, or copy its lines into your application's PBR:

```
pbautobuild250 /pbc /d "myapp.pbt" /o myapp.exe /r "pfc libs\pfc.pbr"
```

Its DataWindow entries (`pfc libs\pfcapsrv.pbl(d_timerlist)` and so on) are relative to the folder you build from, the folder of the workspace's `.pbt` files; change the paths if your PFC libraries are elsewhere. Its images are listed by file name, as PFC names them, so the build finds them only if this folder is the current folder or on the path when you build (for example, `set PATH=%CD%\pfc libs\images;%PATH%` before `pbautobuild250`). An image the build doesn't find is left out without a warning.

## PowerBuilder 2025 GA

PFC 2025 is meant for PowerBuilder 2025 R2. PowerBuilder 2025 GA (the first release of 2025) doesn't show SVG images, so with it the message box shows no icon and a printed TreeView has no lines, boxes or folders. The `png` folder has a PNG of each SVG, with the same name: `pfc_msg_*.png` at 32 pixels and `pfc_tree_*.png` at the pixels of the SVGs. To use PFC 2025 with 2025 GA:

1. Deploy the PNG files from `png` instead of the SVG files (or as well), and in your PBR, list the `.png` names instead of the `.svg` names.
2. **Message box:** in `w_message` (`pfeapsrv.pbl`), select the `lv_bmp` ListView and change its four large pictures from `pfc_msg_*.svg` to `pfc_msg_*.png`. Changing them in the extension object leaves PFC's own `pfc_w_message` as it is.
3. **Printed TreeView lines and boxes:** in `d_printtree` (`pfcmain.pbl`), change the `.svg` file names in the `bitmap()` expressions of its computed fields to `.png` (in Edit Source, replace `.svg` with `.png`).
4. **Printed TreeView folders:** call `of_PrintTree` with picture names, for example `of_PrintTree(0, False, "pfc_tree_folder.png", "pfc_tree_folder_open.png")`. Alternatively, change the default names in `pfc_u_tv` and `pfc_n_cst_tvsrv_print`.

The drag icons are ICO files and work in both releases. The Examples app and PEAT, the demo apps, use SVG images throughout (menus, ribbon, toolbars and trees), so they need 2025 R2.

## Earlier versions of PFC

These replace the bitmaps and icons of [PFC-Image-Files](https://github.com/OpenSourcePFCLibraries/PFC-Image-Files) (`info.bmp`, `folder.bmp`, `arrowl.ico` and so on), which the 2019 and 2022 versions of PFC still use.
