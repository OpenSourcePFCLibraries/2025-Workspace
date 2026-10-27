$PBExportHeader$w_appearance.srw
$PBExportComments$Examples app: the theme, whether the menu is shown as a ribbon, and where help is shown
forward
global type w_appearance from w_response
end type
type st_intro from statictext within w_appearance
end type
type st_theme from statictext within w_appearance
end type
type ddlb_theme from dropdownlistbox within w_appearance
end type
type cbx_ribbon from checkbox within w_appearance
end type
type cbx_pdfviewer from checkbox within w_appearance
end type
type lb_themes from listbox within w_appearance
end type
type cb_ok from u_cb within w_appearance
end type
type cb_cancel from u_cb within w_appearance
end type
end forward

global type w_appearance from w_response
integer width = 1800
integer height = 868
string title = "Appearance"
st_intro st_intro
st_theme st_theme
ddlb_theme ddlb_theme
cbx_ribbon cbx_ribbon
cbx_pdfviewer cbx_pdfviewer
lb_themes lb_themes
cb_ok cb_ok
cb_cancel cb_cancel
end type
global w_appearance w_appearance

type variables
Protected:
// The app's folder and INI file
string	is_folder
string	is_inifile
end variables

event pfc_postopen;call super::pfc_postopen;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			pfc_postopen
//
//	Description:	Lists the themes, the folders in the app's theme folder, and shows
//						the current settings.
//
//////////////////////////////////////////////////////////////////////////////
integer	li_i, li_index
string	ls_item, ls_theme

is_folder = gnv_app.is_appfolder
If is_folder = "" Then is_folder = GetCurrentDirectory()
is_inifile = gnv_app.of_GetAppIniFile()
If Mid(is_inifile, 2, 1) <> ":" Then is_inifile = is_folder + "\" + is_inifile

ddlb_theme.AddItem("None")
// 16 = folders, 32768 = folders only
lb_themes.DirList(is_folder + "\theme\*.*", 16 + 32768)
For li_i = 1 To lb_themes.TotalItems()
	ls_item = lb_themes.Text(li_i)
	If Left(ls_item, 1) = "[" Then ls_item = Mid(ls_item, 2, Len(ls_item) - 2)
	If ls_item = ".." Or Left(ls_item, 1) = "-" Then Continue
	ddlb_theme.AddItem(ls_item)
Next

ls_theme = ProfileString(is_inifile, "Application", "Theme", "Flat Design Grey")
li_index = ddlb_theme.FindItem(ls_theme, 0)
If li_index < 1 Then li_index = 1
ddlb_theme.SelectItem(li_index)

If IsValid(w_examplemain) Then cbx_ribbon.Checked = w_examplemain.DisplayMenuAsRibbonBar
If IsValid(gnv_app.inv_help) Then cbx_pdfviewer.Checked = (gnv_app.inv_help.of_GetViewer() = gnv_app.inv_help.PDFVIEWER)
end event

event pfc_default;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			pfc_default
//
//	Description:	Saves the settings and applies them: the theme at once (with
//						gnv_app.of_ApplyTheme, so the status bar follows it), and the ribbon
//						on the main window (w_examplemain.of_SetRibbon), and where the help
//						service shows help (gnv_app.inv_help.of_SetViewer).
//
//////////////////////////////////////////////////////////////////////////////
string	ls_theme

ls_theme = ddlb_theme.Text
SetProfileString(is_inifile, "Application", "Theme", ls_theme)
If cbx_ribbon.Checked Then
	SetProfileString(is_inifile, "Application", "RibbonBar", "1")
Else
	SetProfileString(is_inifile, "Application", "RibbonBar", "0")
End If
If cbx_pdfviewer.Checked Then
	SetProfileString(is_inifile, "Application", "HelpViewer", "PDFViewer")
Else
	SetProfileString(is_inifile, "Application", "HelpViewer", "InApp")
End If

If ls_theme = "None" Then
	// PowerBuilder can apply another theme while the app runs, but can't remove one
	If GetTheme() <> "" Then MessageBox(this.Title, "The theme is removed when you start the Examples app again.")
Else
	gnv_app.of_ApplyTheme(is_folder + "\theme\" + ls_theme)
End If
If IsValid(w_examplemain) Then w_examplemain.of_SetRibbon(cbx_ribbon.Checked)
If IsValid(gnv_app.inv_help) Then
	If cbx_pdfviewer.Checked Then
		gnv_app.inv_help.of_SetViewer(gnv_app.inv_help.PDFVIEWER)
	Else
		gnv_app.inv_help.of_SetViewer(gnv_app.inv_help.INAPP)
	End If
End If

Close(this)
end event

event pfc_cancel;Close(this)
end event

on w_appearance.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.st_theme=create st_theme
this.ddlb_theme=create ddlb_theme
this.cbx_ribbon=create cbx_ribbon
this.cbx_pdfviewer=create cbx_pdfviewer
this.lb_themes=create lb_themes
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.st_theme
this.Control[iCurrent+3]=this.ddlb_theme
this.Control[iCurrent+4]=this.cbx_ribbon
this.Control[iCurrent+5]=this.cbx_pdfviewer
this.Control[iCurrent+6]=this.lb_themes
this.Control[iCurrent+7]=this.cb_ok
this.Control[iCurrent+8]=this.cb_cancel
end on

on w_appearance.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.st_theme)
destroy(this.ddlb_theme)
destroy(this.cbx_ribbon)
destroy(this.cbx_pdfviewer)
destroy(this.lb_themes)
destroy(this.cb_ok)
destroy(this.cb_cancel)
end on

type st_intro from statictext within w_appearance
integer x = 37
integer y = 32
integer width = 1700
integer height = 216
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "The theme styles the windows and controls, the menu can be a ribbon or a menu bar and toolbar, and help can open in the app or in your PDF viewer.  They are saved in examples.ini (Theme, RibbonBar and HelpViewer in [Application])."
boolean focusrectangle = false
end type

type st_theme from statictext within w_appearance
integer x = 37
integer y = 292
integer width = 230
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Theme:"
boolean focusrectangle = false
end type

type ddlb_theme from dropdownlistbox within w_appearance
integer x = 274
integer y = 280
integer width = 1463
integer height = 600
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean sorted = false
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

type cbx_ribbon from checkbox within w_appearance
integer x = 37
integer y = 404
integer width = 1700
integer height = 80
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Show the menu as a &ribbon"
end type

type cbx_pdfviewer from checkbox within w_appearance
integer x = 37
integer y = 492
integer width = 1700
integer height = 80
integer taborder = 25
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Show help in my &PDF viewer, not in the app"
end type

type lb_themes from listbox within w_appearance
integer x = 37
integer y = 588
integer width = 400
integer height = 100
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean visible = false
boolean sorted = true
borderstyle borderstyle = stylelowered!
end type

type cb_ok from u_cb within w_appearance
integer x = 1005
integer y = 628
integer taborder = 30
string text = "OK"
boolean default = true
end type

event clicked;call super::clicked;parent.event pfc_default()
end event

type cb_cancel from u_cb within w_appearance
integer x = 1385
integer y = 628
integer taborder = 40
string text = "Cancel"
boolean cancel = true
end type

event clicked;call super::clicked;parent.event pfc_cancel()
end event
