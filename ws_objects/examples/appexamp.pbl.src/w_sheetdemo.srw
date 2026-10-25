$PBExportHeader$w_sheetdemo.srw
$PBExportComments$Sheet of the Sheet Manager example (w_sheetframe)
forward
global type w_sheetdemo from w_sheet
end type
type st_info from statictext within w_sheetdemo
end type
type cb_list from u_cb within w_sheetdemo
end type
type st_title from statictext within w_sheetdemo
end type
type sle_title from singlelineedit within w_sheetdemo
end type
type cb_find from u_cb within w_sheetdemo
end type
type lb_sheets from listbox within w_sheetdemo
end type
end forward

global type w_sheetdemo from w_sheet
integer width = 1700
integer height = 1100
st_info st_info
cb_list cb_list
st_title st_title
sle_title sle_title
cb_find cb_find
lb_sheets lb_sheets
end type
global w_sheetdemo w_sheetdemo

forward prototypes
protected function n_cst_winsrv_sheetmanager of_sheetmanager ()
end prototypes

protected function n_cst_winsrv_sheetmanager of_sheetmanager ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_SheetManager
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Returns:			n_cst_winsrv_sheetmanager
//						The sheet manager of the frame the sheet is in
//
//////////////////////////////////////////////////////////////////////////////
w_frame	lw_frame
n_cst_winsrv_sheetmanager	lnv_none

lw_frame = this.ParentWindow()
If IsValid(lw_frame) Then Return lw_frame.inv_sheetmanager
Return lnv_none
end function

event open;call super::open;// The frame passes the sheet's title
this.Title = Message.StringParm
end event

on w_sheetdemo.create
int iCurrent
call super::create
this.st_info=create st_info
this.cb_list=create cb_list
this.st_title=create st_title
this.sle_title=create sle_title
this.cb_find=create cb_find
this.lb_sheets=create lb_sheets
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_info
this.Control[iCurrent+2]=this.cb_list
this.Control[iCurrent+3]=this.st_title
this.Control[iCurrent+4]=this.sle_title
this.Control[iCurrent+5]=this.cb_find
this.Control[iCurrent+6]=this.lb_sheets
end on

on w_sheetdemo.destroy
call super::destroy
destroy(this.st_info)
destroy(this.cb_list)
destroy(this.st_title)
destroy(this.sle_title)
destroy(this.cb_find)
destroy(this.lb_sheets)
end on

type st_info from statictext within w_sheetdemo
integer x = 37
integer y = 32
integer width = 1590
integer height = 228
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Arrange the sheets with the Window menu (the sheet manager does Cascade, Tile, Layer, Minimize All and Undo Arrange), open more with File > New, and change the toolbars with Tools > Customize Toolbars.  The frame remembers its size, position and toolbars."
boolean focusrectangle = false
end type

type cb_list from u_cb within w_sheetdemo
integer x = 37
integer y = 284
integer width = 549
integer taborder = 10
string text = "&List the Sheets"
end type

event clicked;call super::clicked;// of_GetSheets, of_GetSheetCount, and the last arrangement (of_GetCurrentState)
n_cst_winsrv_sheetmanager	lnv_sheets
window	lw_sheets[]
integer	li_count, li_i
arrangetypes	le_state
string	ls_state

lnv_sheets = parent.of_SheetManager()
If Not IsValid(lnv_sheets) Then Return

lb_sheets.Reset()
li_count = lnv_sheets.of_GetSheets(lw_sheets)
For li_i = 1 To li_count
	lb_sheets.AddItem(lw_sheets[li_i].Title + " (" + lw_sheets[li_i].ClassName() + ")")
Next

le_state = lnv_sheets.of_GetCurrentState()
Choose Case le_state
	Case Cascade!
		ls_state = "cascaded"
	Case Layer!
		ls_state = "layered"
	Case Tile!
		ls_state = "tiled vertically"
	Case TileHorizontal!
		ls_state = "tiled horizontally"
	Case Icons!
		ls_state = "minimized"
	Case Else
		ls_state = "as the user left them"
End Choose
lb_sheets.AddItem(String(lnv_sheets.of_GetSheetCount()) + " sheets, " + ls_state)
end event

type st_title from statictext within w_sheetdemo
integer x = 37
integer y = 404
integer width = 160
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Title:"
boolean focusrectangle = false
end type

type sle_title from singlelineedit within w_sheetdemo
integer x = 210
integer y = 392
integer width = 375
integer height = 84
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
string text = "Sheet 1"
borderstyle borderstyle = stylelowered!
end type

type cb_find from u_cb within w_sheetdemo
integer x = 608
integer y = 392
integer width = 549
integer taborder = 30
string text = "&Go to the Sheet"
end type

event clicked;call super::clicked;// of_GetSheetsByTitle finds the sheets with that title; the first one gets the focus
n_cst_winsrv_sheetmanager	lnv_sheets
window	lw_found[]

lnv_sheets = parent.of_SheetManager()
If Not IsValid(lnv_sheets) Then Return

If lnv_sheets.of_GetSheetsByTitle(lw_found, sle_title.Text) > 0 Then
	lw_found[1].BringToTop = True
	lw_found[1].SetFocus()
Else
	MessageBox(parent.Title, "No sheet has the title " + sle_title.Text + ".")
End If
end event

type lb_sheets from listbox within w_sheetdemo
integer x = 37
integer y = 512
integer width = 1590
integer height = 440
integer taborder = 40
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
boolean vscrollbar = true
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type
