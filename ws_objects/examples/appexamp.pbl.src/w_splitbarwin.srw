$PBExportHeader$w_splitbarwin.srw
$PBExportComments$Example of split bars (u_st_splitbar) on tab pages, and their settings
forward
global type w_splitbarwin from w_main
end type
type st_intro from statictext within w_splitbarwin
end type
type tab_1 from tab within w_splitbarwin
end type
type tabpg_vertical from userobject within tab_1
end type
type mle_left from multilineedit within tabpg_vertical
end type
type st_v1 from u_st_splitbar within tabpg_vertical
end type
type mle_right from multilineedit within tabpg_vertical
end type
type tabpg_vertical from userobject within tab_1
mle_left mle_left
st_v1 st_v1
mle_right mle_right
end type
type tabpg_horizontal from userobject within tab_1
end type
type mle_top from multilineedit within tabpg_horizontal
end type
type st_h1 from u_st_splitbar within tabpg_horizontal
end type
type mle_bottom from multilineedit within tabpg_horizontal
end type
type tabpg_horizontal from userobject within tab_1
mle_top mle_top
st_h1 st_h1
mle_bottom mle_bottom
end type
type tab_1 from tab within w_splitbarwin
tabpg_vertical tabpg_vertical
tabpg_horizontal tabpg_horizontal
end type
type cbx_live from checkbox within w_splitbarwin
end type
type cbx_color from checkbox within w_splitbarwin
end type
type st_min from statictext within w_splitbarwin
end type
type sle_min from singlelineedit within w_splitbarwin
end type
type cb_min from u_cb within w_splitbarwin
end type
type cb_close from u_cb within w_splitbarwin
end type
end forward

global type w_splitbarwin from w_main
integer x = 594
integer y = 300
integer width = 2551
integer height = 1800
string title = "PFC Example - Split Bar Settings"
st_intro st_intro
tab_1 tab_1
cbx_live cbx_live
cbx_color cbx_color
st_min st_min
sle_min sle_min
cb_min cb_min
cb_close cb_close
end type
global w_splitbarwin w_splitbarwin

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	Registers the controls on each side of the split bars.
//
//////////////////////////////////////////////////////////////////////////////
tab_1.tabpg_vertical.st_v1.of_Register(tab_1.tabpg_vertical.mle_left, tab_1.tabpg_vertical.st_v1.LEFT)
tab_1.tabpg_vertical.st_v1.of_Register(tab_1.tabpg_vertical.mle_right, tab_1.tabpg_vertical.st_v1.RIGHT)
tab_1.tabpg_horizontal.st_h1.of_Register(tab_1.tabpg_horizontal.mle_top, tab_1.tabpg_horizontal.st_h1.ABOVE)
tab_1.tabpg_horizontal.st_h1.of_Register(tab_1.tabpg_horizontal.mle_bottom, tab_1.tabpg_horizontal.st_h1.BELOW)
end event

on w_splitbarwin.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.tab_1=create tab_1
this.cbx_live=create cbx_live
this.cbx_color=create cbx_color
this.st_min=create st_min
this.sle_min=create sle_min
this.cb_min=create cb_min
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.tab_1
this.Control[iCurrent+3]=this.cbx_live
this.Control[iCurrent+4]=this.cbx_color
this.Control[iCurrent+5]=this.st_min
this.Control[iCurrent+6]=this.sle_min
this.Control[iCurrent+7]=this.cb_min
this.Control[iCurrent+8]=this.cb_close
end on

on w_splitbarwin.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.tab_1)
destroy(this.cbx_live)
destroy(this.cbx_color)
destroy(this.st_min)
destroy(this.sle_min)
destroy(this.cb_min)
destroy(this.cb_close)
end on

type st_intro from statictext within w_splitbarwin
integer x = 37
integer y = 32
integer width = 2459
integer height = 160
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "A split bar (u_st_splitbar) lets the user change how the space is divided between the controls on either side of it.  These split bars are on tab pages.  The settings below change both of them."
boolean focusrectangle = false
end type

type tab_1 from tab within w_splitbarwin
integer x = 37
integer y = 216
integer width = 2459
integer height = 1000
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long backcolor = 67108864
boolean raggedright = true
boolean focusonbuttondown = true
integer selectedtab = 1
tabpg_vertical tabpg_vertical
tabpg_horizontal tabpg_horizontal
end type

on tab_1.create
this.tabpg_vertical=create tabpg_vertical
this.tabpg_horizontal=create tabpg_horizontal
this.Control[]={this.tabpg_vertical,&
this.tabpg_horizontal}
end on

on tab_1.destroy
destroy(this.tabpg_vertical)
destroy(this.tabpg_horizontal)
end on

type tabpg_vertical from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 884
long backcolor = 67108864
string text = "Side by Side"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
mle_left mle_left
st_v1 st_v1
mle_right mle_right
end type

on tabpg_vertical.create
this.mle_left=create mle_left
this.st_v1=create st_v1
this.mle_right=create mle_right
this.Control[]={this.mle_left,&
this.st_v1,&
this.mle_right}
end on

on tabpg_vertical.destroy
destroy(this.mle_left)
destroy(this.st_v1)
destroy(this.mle_right)
end on

type mle_left from multilineedit within tabpg_vertical
integer x = 18
integer y = 18
integer width = 800
integer height = 848
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
string text = "Drag the bar on the right of this pane to change the widths of the two panes.  The split bar is on a tab page: it moves the controls registered with it, wherever they are."
boolean vscrollbar = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_v1 from u_st_splitbar within tabpg_vertical
integer x = 818
integer y = 18
integer width = 23
integer height = 848
end type

type mle_right from multilineedit within tabpg_vertical
integer x = 841
integer y = 18
integer width = 1563
integer height = 848
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
string text = "of_Register(control, LEFT or RIGHT) tells the vertical split bar which controls are on each side of it."
boolean vscrollbar = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
end type

type tabpg_horizontal from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 884
long backcolor = 67108864
string text = "One Above the Other"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
mle_top mle_top
st_h1 st_h1
mle_bottom mle_bottom
end type

on tabpg_horizontal.create
this.mle_top=create mle_top
this.st_h1=create st_h1
this.mle_bottom=create mle_bottom
this.Control[]={this.mle_top,&
this.st_h1,&
this.mle_bottom}
end on

on tabpg_horizontal.destroy
destroy(this.mle_top)
destroy(this.st_h1)
destroy(this.mle_bottom)
end on

type mle_top from multilineedit within tabpg_horizontal
integer x = 18
integer y = 18
integer width = 2386
integer height = 380
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
string text = "Drag the bar below this pane to change the heights of the two panes."
boolean vscrollbar = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_h1 from u_st_splitbar within tabpg_horizontal
integer x = 18
integer y = 398
integer width = 2386
integer height = 23
end type

type mle_bottom from multilineedit within tabpg_horizontal
integer x = 18
integer y = 421
integer width = 2386
integer height = 445
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
string text = "of_Register(control, ABOVE or BELOW) tells the horizontal split bar which controls are on each side of it."
boolean vscrollbar = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
end type

type cbx_live from checkbox within w_splitbarwin
integer x = 37
integer y = 1244
integer width = 2459
integer height = 72
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Live resize: move the panes while the bar is dragged, not only when it is dropped (of_SetLiveResize)"
end type

event clicked;tab_1.tabpg_vertical.st_v1.of_SetLiveResize(this.Checked)
tab_1.tabpg_horizontal.st_h1.of_SetLiveResize(this.Checked)
end event

type cbx_color from checkbox within w_splitbarwin
integer x = 37
integer y = 1324
integer width = 2459
integer height = 72
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Colored bars: blue, and red while dragged (of_SetBarColor, of_SetBarMoveColor)"
end type

event clicked;// The colors, or the defaults again
long	ll_color, ll_movecolor

If this.Checked Then
	ll_color = RGB(0, 120, 215)
	ll_movecolor = RGB(220, 0, 0)
Else
	ll_color = 78682240
	ll_movecolor = 8421504
End If
tab_1.tabpg_vertical.st_v1.of_SetBarColor(ll_color)
tab_1.tabpg_vertical.st_v1.of_SetBarMoveColor(ll_movecolor)
tab_1.tabpg_horizontal.st_h1.of_SetBarColor(ll_color)
tab_1.tabpg_horizontal.st_h1.of_SetBarMoveColor(ll_movecolor)
end event

type st_min from statictext within w_splitbarwin
integer x = 37
integer y = 1424
integer width = 1189
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Smallest pane size, in PB units (of_SetMinObjectSize):"
boolean focusrectangle = false
end type

type sle_min from singlelineedit within w_splitbarwin
integer x = 1244
integer y = 1412
integer width = 238
integer height = 84
integer taborder = 40
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
string text = "20"
borderstyle borderstyle = stylelowered!
end type

type cb_min from u_cb within w_splitbarwin
integer x = 1504
integer y = 1408
integer width = 380
integer taborder = 50
string text = "&Apply"
end type

event clicked;call super::clicked;If Not IsNumber(sle_min.Text) Then Return
tab_1.tabpg_vertical.st_v1.of_SetMinObjectSize(Integer(sle_min.Text))
tab_1.tabpg_horizontal.st_h1.of_SetMinObjectSize(Integer(sle_min.Text))
end event

type cb_close from u_cb within w_splitbarwin
integer x = 2121
integer y = 1560
integer taborder = 60
string text = "Close"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
