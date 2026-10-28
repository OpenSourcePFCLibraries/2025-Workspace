# PFC's images

The pictures that PFC's own objects show. An application finds them by their file name, so deploy them where it looks for files: beside the executable, in a folder on the system path (or, in the IDE, PowerBuilder's application path), or compiled into the executable by listing them in the application's PBR file.

| File | Used by |
|---|---|
| `pfc_msg_info.svg`, `pfc_msg_stop.svg`, `pfc_msg_warning.svg`, `pfc_msg_question.svg` | The message box (`w_message`), as the icon of an information, error, warning or question message |
| `pfc_drag_left.ico`, `pfc_drag_right.ico` | The drag-and-drop Sort dialog box (`w_sortdragdrop`), as the drag icons |
| `pfc_tree_line.png`, `pfc_tree_branch.png`, `pfc_tree_last.png`, `pfc_tree_plus.png`, `pfc_tree_minus.png` | A printed TreeView (`d_printtree`, from `u_tv` and `n_cst_tvsrv_print` `of_PrintTree`), as the lines and the expand and collapse boxes |
| `pfc_tree_folder.png`, `pfc_tree_folder_open.png` | A printed TreeView, as the default item and selected item pictures |

The icons are from Microsoft's [Fluent UI System Icons](https://github.com/microsoft/fluentui-system-icons) (MIT license, in `LICENSE-fluentui-system-icons.txt`). The printed tree's pictures are PNG because a DataWindow's `bitmap()` expression can't show SVG, and the drag icons are ICO files because a drag icon must be one.

## Compiling them into the executable

`pfc libs\pfc.pbr` is PFC's resource file: the DataWindow objects that PFC's objects name only in their scripts (so the compiler doesn't include them by itself) and these images. Use it as the executable's PBR, or copy its lines into your application's PBR:

```
pbautobuild250 /pbc /d "myapp.pbt" /o myapp.exe /r "pfc libs\pfc.pbr"
```

Its DataWindow entries (`pfc libs\pfcapsrv.pbl(d_timerlist)` and so on) are relative to the folder you build from, the folder of the workspace's `.pbt` files; change the paths if your PFC libraries are elsewhere. Its images are listed by file name, as PFC names them, so the build finds them only if this folder is the current folder or on the path when you build (for example, `set PATH=%CD%\pfc libs\images;%PATH%` before `pbautobuild250`). An image the build doesn't find is left out without a warning.

These replace the bitmaps and icons of [PFC-Image-Files](https://github.com/OpenSourcePFCLibraries/PFC-Image-Files) (`info.bmp`, `folder.bmp`, `arrowl.ico` and so on), which the 2019 and 2022 versions of PFC still use.
