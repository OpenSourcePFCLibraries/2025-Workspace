$PBExportHeader$w_ribbonsheet.srw
$PBExportComments$Sheet of the Ribbon Bar example (w_ribbonframe)
forward
global type w_ribbonsheet from w_sheet
end type
type st_info from statictext within w_ribbonsheet
end type
end forward

global type w_ribbonsheet from w_sheet
integer width = 1700
integer height = 800
st_info st_info
end type
global w_ribbonsheet w_ribbonsheet

event open;call super::open;// The frame passes the sheet's title
this.Title = Message.StringParm
end event

on w_ribbonsheet.create
int iCurrent
call super::create
this.st_info=create st_info
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_info
end on

on w_ribbonsheet.destroy
call super::destroy
destroy(this.st_info)
end on

type st_info from statictext within w_ribbonsheet
integer x = 37
integer y = 32
integer width = 1590
integer height = 600
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "The ribbon bar (u_rbb) spans the top of the frame, and w_frame's of_LayoutClient fits the client area, where the sheets are, under it.  On the View tab, hide the panel text or the tab header: u_rbb's of_SetHidePanelText and of_SetHideTabHeader change the ribbon bar's height and lay the frame out again.  The Home tab opens, closes and arranges the sheets."
boolean focusrectangle = false
end type
