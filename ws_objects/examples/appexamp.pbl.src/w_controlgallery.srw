$PBExportHeader$w_controlgallery.srw
$PBExportComments$Gallery of PFC's visual controls: date picker, month calendar, trackbars, web browser, picture hyperlink and OLE control
forward
global type w_controlgallery from w_main
end type
type st_intro from statictext within w_controlgallery
end type
type tab_1 from tab within w_controlgallery
end type
type tabpg_dates from userobject within tab_1
end type
type st_dates from statictext within tabpg_dates
end type
type st_dp from statictext within tabpg_dates
end type
type dp_1 from u_dp within tabpg_dates
end type
type mc_1 from u_mc within tabpg_dates
end type
type st_selected from statictext within tabpg_dates
end type
type tabpg_dates from userobject within tab_1
st_dates st_dates
st_dp st_dp
dp_1 dp_1
mc_1 mc_1
st_selected st_selected
end type
type tabpg_trackbars from userobject within tab_1
end type
type st_trackbars from statictext within tabpg_trackbars
end type
type htb_1 from u_htb within tabpg_trackbars
end type
type vtb_1 from u_vtb within tabpg_trackbars
end type
type st_sample from statictext within tabpg_trackbars
end type
type st_events from statictext within tabpg_trackbars
end type
type lb_events from listbox within tabpg_trackbars
end type
type tabpg_trackbars from userobject within tab_1
st_trackbars st_trackbars
htb_1 htb_1
vtb_1 vtb_1
st_sample st_sample
st_events st_events
lb_events lb_events
end type
type tabpg_web from userobject within tab_1
end type
type st_web from statictext within tabpg_web
end type
type st_url from statictext within tabpg_web
end type
type sle_url from singlelineedit within tabpg_web
end type
type cb_go from u_cb within tabpg_web
end type
type cb_back from u_cb within tabpg_web
end type
type cb_html from u_cb within tabpg_web
end type
type wb_1 from u_wb within tabpg_web
end type
type phl_1 from u_phl within tabpg_web
end type
type st_phl from statictext within tabpg_web
end type
type tabpg_web from userobject within tab_1
st_web st_web
st_url st_url
sle_url sle_url
cb_go cb_go
cb_back cb_back
cb_html cb_html
wb_1 wb_1
phl_1 phl_1
st_phl st_phl
end type
type tabpg_ole from userobject within tab_1
end type
type st_ole from statictext within tabpg_ole
end type
type cb_insert from u_cb within tabpg_ole
end type
type cb_file from u_cb within tabpg_ole
end type
type cb_clear from u_cb within tabpg_ole
end type
type tabpg_ole from userobject within tab_1
st_ole st_ole
cb_insert cb_insert
cb_file cb_file
cb_clear cb_clear
end type
type tab_1 from tab within w_controlgallery
tabpg_dates tabpg_dates
tabpg_trackbars tabpg_trackbars
tabpg_web tabpg_web
tabpg_ole tabpg_ole
end type
type cb_close from u_cb within w_controlgallery
end type
end forward

global type w_controlgallery from w_main
integer x = 594
integer y = 300
integer width = 2551
integer height = 1940
string title = "PFC Example - Controls Gallery"
st_intro st_intro
tab_1 tab_1
cb_close cb_close
end type
global w_controlgallery w_controlgallery

forward prototypes
protected function string of_movename (integer ai_type)
public function u_oc of_olecontrol ()
end prototypes

protected function string of_movename (integer ai_type);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_MoveName
//
//	Access:			Protected
//
//	Arguments:		ai_type	The kind of move pfc_positionchanged was triggered for
//
//	Returns:			string	A name for it
//
//////////////////////////////////////////////////////////////////////////////
// The trackbars use the same numbers (u_htb CST_LINE_LEFT and u_vtb CST_LINE_UP are both 1)
Choose Case ai_type
	Case tab_1.tabpg_trackbars.htb_1.CST_LINE_LEFT
		Return "a line back"
	Case tab_1.tabpg_trackbars.htb_1.CST_LINE_RIGHT
		Return "a line forward"
	Case tab_1.tabpg_trackbars.htb_1.CST_PAGE_LEFT
		Return "a page back"
	Case tab_1.tabpg_trackbars.htb_1.CST_PAGE_RIGHT
		Return "a page forward"
	Case tab_1.tabpg_trackbars.htb_1.CST_MOVED
		Return "moved"
End Choose
Return "type " + String(ai_type)
end function

public function u_oc of_olecontrol ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_OLEControl
//
//	Access:			Public
//
//	Arguments:		None
//
//	Returns:			u_oc	The OLE control opened on the tab page
//
//////////////////////////////////////////////////////////////////////////////
integer	li_i
u_oc	loc_none

For li_i = 1 To UpperBound(tab_1.tabpg_ole.Control)
	If tab_1.tabpg_ole.Control[li_i].TypeOf() = OLEControl! Then Return tab_1.tabpg_ole.Control[li_i]
Next
Return loc_none
end function

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	Starts the calendar on today, and the trackbars' sample.
//
//////////////////////////////////////////////////////////////////////////////
tab_1.tabpg_dates.mc_1.SetSelectedDate(Today())
tab_1.tabpg_dates.mc_1.event datechanged()
tab_1.tabpg_trackbars.st_sample.TextSize = - tab_1.tabpg_trackbars.htb_1.Position
tab_1.tabpg_web.cb_html.event clicked()
end event

on w_controlgallery.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.tab_1=create tab_1
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.tab_1
this.Control[iCurrent+3]=this.cb_close
end on

on w_controlgallery.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.tab_1)
destroy(this.cb_close)
end on

type st_intro from statictext within w_controlgallery
integer x = 37
integer y = 32
integer width = 2459
integer height = 200
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "PFC has a standard visual user object for each of PowerBuilder's newer controls, with PFC's common functions (of_GetParentWindow, and of_MessageBox with the language service) and MicroHelp support.  Some add more, as the tabs show."
boolean focusrectangle = false
end type

type tab_1 from tab within w_controlgallery
integer x = 37
integer y = 256
integer width = 2459
integer height = 1400
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
tabpg_dates tabpg_dates
tabpg_trackbars tabpg_trackbars
tabpg_web tabpg_web
tabpg_ole tabpg_ole
end type

on tab_1.create
this.tabpg_dates=create tabpg_dates
this.tabpg_trackbars=create tabpg_trackbars
this.tabpg_web=create tabpg_web
this.tabpg_ole=create tabpg_ole
this.Control[]={this.tabpg_dates,&
this.tabpg_trackbars,&
this.tabpg_web,&
this.tabpg_ole}
end on

on tab_1.destroy
destroy(this.tabpg_dates)
destroy(this.tabpg_trackbars)
destroy(this.tabpg_web)
destroy(this.tabpg_ole)
end on

type tabpg_dates from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1284
long backcolor = 67108864
string text = "Date Picker and Calendar"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_dates st_dates
st_dp st_dp
dp_1 dp_1
mc_1 mc_1
st_selected st_selected
end type

on tabpg_dates.create
this.st_dates=create st_dates
this.st_dp=create st_dp
this.dp_1=create dp_1
this.mc_1=create mc_1
this.st_selected=create st_selected
this.Control[]={this.st_dates,&
this.st_dp,&
this.dp_1,&
this.mc_1,&
this.st_selected}
end on

on tabpg_dates.destroy
destroy(this.st_dates)
destroy(this.st_dp)
destroy(this.dp_1)
destroy(this.mc_1)
destroy(this.st_selected)
end on

type st_dates from statictext within tabpg_dates
integer x = 32
integer y = 24
integer width = 2350
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "u_dp, a date picker, edits a date in a box with a drop-down calendar; u_mc, a month calendar, shows whole months and selects a date or a range of dates (drag across the days, or click one and shift-click another).  Here each one follows the other."
boolean focusrectangle = false
end type

type st_dp from statictext within tabpg_dates
integer x = 32
integer y = 252
integer width = 251
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Date:"
boolean focusrectangle = false
end type

type dp_1 from u_dp within tabpg_dates
integer x = 297
integer y = 240
integer width = 686
integer taborder = 10
end type

event valuechanged;call super::valuechanged;// Show the date on the calendar
mc_1.SetSelectedDate(Date(this.Value))
mc_1.event datechanged()
end event

type mc_1 from u_mc within tabpg_dates
integer x = 32
integer y = 380
integer taborder = 20
end type

event datechanged;call super::datechanged;// The date, or the range of dates, selected on the calendar
date	ld_start, ld_end

// GetSelectedRange gives the range; with one date selected, use GetSelectedDate
this.GetSelectedRange(ld_start, ld_end)
If IsNull(ld_start) Or ld_start <= Date("1900-01-01") Then
	If this.GetSelectedDate(ld_start) <> 1 Then Return
	ld_end = ld_start
End If
If ld_start = ld_end Then
	st_selected.Text = "Selected: " + DayName(ld_start) + ", " + String(ld_start, "mmmm d, yyyy")
Else
	st_selected.Text = "Selected: " + String(ld_start, "mmmm d") + " to " + String(ld_end, "mmmm d, yyyy") + &
		" (" + String(DaysAfter(ld_start, ld_end) + 1) + " days)"
End If
// The date picker shows the first selected date
dp_1.SetValue(ld_start, Time("00:00"))
end event

type st_selected from statictext within tabpg_dates
integer x = 1100
integer y = 400
integer width = 1282
integer height = 140
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
boolean focusrectangle = false
end type

type tabpg_trackbars from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1284
long backcolor = 67108864
string text = "Trackbars"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_trackbars st_trackbars
htb_1 htb_1
vtb_1 vtb_1
st_sample st_sample
st_events st_events
lb_events lb_events
end type

on tabpg_trackbars.create
this.st_trackbars=create st_trackbars
this.htb_1=create htb_1
this.vtb_1=create vtb_1
this.st_sample=create st_sample
this.st_events=create st_events
this.lb_events=create lb_events
this.Control[]={this.st_trackbars,&
this.htb_1,&
this.vtb_1,&
this.st_sample,&
this.st_events,&
this.lb_events}
end on

on tabpg_trackbars.destroy
destroy(this.st_trackbars)
destroy(this.htb_1)
destroy(this.vtb_1)
destroy(this.st_sample)
destroy(this.st_events)
destroy(this.lb_events)
end on

type st_trackbars from statictext within tabpg_trackbars
integer x = 32
integer y = 24
integer width = 2350
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "u_htb and u_vtb are a horizontal and a vertical trackbar.  PFC turns their scroll events into one, pfc_positionchanged, with the kind of move and the new position, and moves the slider with the mouse wheel.  The horizontal trackbar sets the size of the sample text, the vertical one its background."
boolean focusrectangle = false
end type

type htb_1 from u_htb within tabpg_trackbars
integer x = 32
integer y = 240
integer width = 1300
integer height = 120
integer taborder = 10
integer minposition = 6
integer maxposition = 36
integer position = 12
integer tickfrequency = 2
end type

event pfc_positionchanged;call super::pfc_positionchanged;// The font size of the sample text
st_sample.TextSize = - ai_scrollpos
lb_events.AddItem("Horizontal: " + of_MoveName(ai_type) + ", position " + String(ai_scrollpos))
lb_events.SetTop(lb_events.TotalItems())
end event

type vtb_1 from u_vtb within tabpg_trackbars
integer x = 1370
integer y = 240
integer width = 120
integer height = 996
integer taborder = 20
integer maxposition = 255
integer position = 255
integer tickfrequency = 16
end type

event pfc_positionchanged;call super::pfc_positionchanged;// The background of the sample text: from black (top) to white (bottom)
st_sample.BackColor = RGB(ai_scrollpos, ai_scrollpos, ai_scrollpos)
st_sample.TextColor = RGB(255 - ai_scrollpos, 255 - ai_scrollpos, 255 - ai_scrollpos)
lb_events.AddItem("Vertical: " + of_MoveName(ai_type) + ", position " + String(ai_scrollpos))
lb_events.SetTop(lb_events.TotalItems())
end event

type st_sample from statictext within tabpg_trackbars
integer x = 32
integer y = 400
integer width = 1300
integer height = 836
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Aa Bb Cc"
boolean border = true
borderstyle borderstyle = stylelowered!
alignment alignment = center!
boolean focusrectangle = false
end type

type st_events from statictext within tabpg_trackbars
integer x = 1527
integer y = 240
integer width = 855
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "pfc_positionchanged:"
boolean focusrectangle = false
end type

type lb_events from listbox within tabpg_trackbars
integer x = 1527
integer y = 316
integer width = 855
integer height = 920
integer taborder = 30
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

type tabpg_web from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1284
long backcolor = 67108864
string text = "Web Browser"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_web st_web
st_url st_url
sle_url sle_url
cb_go cb_go
cb_back cb_back
cb_html cb_html
wb_1 wb_1
phl_1 phl_1
st_phl st_phl
end type

on tabpg_web.create
this.st_web=create st_web
this.st_url=create st_url
this.sle_url=create sle_url
this.cb_go=create cb_go
this.cb_back=create cb_back
this.cb_html=create cb_html
this.wb_1=create wb_1
this.phl_1=create phl_1
this.st_phl=create st_phl
this.Control[]={this.st_web,&
this.st_url,&
this.sle_url,&
this.cb_go,&
this.cb_back,&
this.cb_html,&
this.wb_1,&
this.phl_1,&
this.st_phl}
end on

on tabpg_web.destroy
destroy(this.st_web)
destroy(this.st_url)
destroy(this.sle_url)
destroy(this.cb_go)
destroy(this.cb_back)
destroy(this.cb_html)
destroy(this.wb_1)
destroy(this.phl_1)
destroy(this.st_phl)
end on

type st_web from statictext within tabpg_web
integer x = 32
integer y = 24
integer width = 2350
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "u_wb is a web browser, which uses Microsoft Edge WebView2; it shows a web page, or HTML from the application.  u_phl is a picture hyperlink: clicking the picture opens its URL in the default browser."
boolean focusrectangle = false
end type

type st_url from statictext within tabpg_web
integer x = 32
integer y = 252
integer width = 251
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Address:"
boolean focusrectangle = false
end type

type sle_url from singlelineedit within tabpg_web
integer x = 297
integer y = 240
integer width = 1152
integer height = 84
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
string text = "https://github.com/OpenSourcePFCLibraries"
borderstyle borderstyle = stylelowered!
end type

type cb_go from u_cb within tabpg_web
integer x = 1477
integer y = 236
integer width = 238
integer taborder = 20
string text = "&Go"
end type

event clicked;call super::clicked;wb_1.Navigate(sle_url.Text)
end event

type cb_back from u_cb within tabpg_web
integer x = 1733
integer y = 236
integer width = 238
integer taborder = 30
string text = "&Back"
end type

event clicked;call super::clicked;wb_1.GoBack()
end event

type cb_html from u_cb within tabpg_web
integer x = 1989
integer y = 236
integer width = 393
integer taborder = 40
string text = "&Show HTML"
end type

event clicked;call super::clicked;// HTML from the application, not from a web site
wb_1.NavigateToString("<html><body style='font-family: Segoe UI, sans-serif'>" + &
	"<h2>HTML from the application</h2><p>NavigateToString shows HTML that the application " + &
	"builds, for example a report or help text.  Type a web address and click Go to show a page.</p></body></html>")
end event

type wb_1 from u_wb within tabpg_web
integer x = 32
integer y = 356
integer width = 2350
integer height = 736
integer taborder = 50
end type

type phl_1 from u_phl within tabpg_web
integer x = 32
integer y = 1120
integer width = 110
integer height = 96
string picturename = "Netdriv.bmp"
string url = "https://github.com/OpenSourcePFCLibraries"
end type

type st_phl from statictext within tabpg_web
integer x = 165
integer y = 1136
integer width = 2217
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Click the picture to open the PFC project on GitHub in your browser."
boolean focusrectangle = false
end type

type tabpg_ole from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1284
long backcolor = 67108864
string text = "OLE Control"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_ole st_ole
cb_insert cb_insert
cb_file cb_file
cb_clear cb_clear
end type

on tabpg_ole.create
this.st_ole=create st_ole
this.cb_insert=create cb_insert
this.cb_file=create cb_file
this.cb_clear=create cb_clear
this.Control[]={this.st_ole,&
this.cb_insert,&
this.cb_file,&
this.cb_clear}
end on

on tabpg_ole.destroy
destroy(this.st_ole)
destroy(this.cb_insert)
destroy(this.cb_file)
destroy(this.cb_clear)
end on

event constructor;// u_oc is opened at run time: an OLE control placed on a window in the painter
// keeps its contents in the window's binary data
u_oc	loc_object

this.OpenUserObject(loc_object, 32, 356)
loc_object.Resize(2350, 880)
end event

type st_ole from statictext within tabpg_ole
integer x = 32
integer y = 24
integer width = 2350
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "u_oc, an OLE control, holds a document of another application: insert a new object, or a file, then right-click the object for PFC's menu (m_oc) to cut, copy, edit or open it, or double-click it to edit it in place."
boolean focusrectangle = false
end type

type cb_insert from u_cb within tabpg_ole
integer x = 32
integer y = 236
integer width = 558
integer taborder = 10
string text = "&Insert Object..."
end type

event clicked;call super::clicked;// pfc_insertobject shows the Insert Object dialog box, and activates the new object
u_oc	loc_object

loc_object = of_OLEControl()
If IsValid(loc_object) Then loc_object.event pfc_insertobject()
end event

type cb_file from u_cb within tabpg_ole
integer x = 622
integer y = 236
integer width = 558
integer taborder = 20
string text = "Insert a &File..."
end type

event clicked;call super::clicked;// An object made from a file, by the application that the file type belongs to
u_oc	loc_object
string	ls_path, ls_file

loc_object = of_OLEControl()
If Not IsValid(loc_object) Then Return
If GetFileOpenName("Insert a File", ls_path, ls_file) <> 1 Then Return
If loc_object.InsertFile(ls_path) <> 0 Then
	MessageBox("Insert a File", "Unable to insert " + ls_file + " as an OLE object.")
End If
end event

type cb_clear from u_cb within tabpg_ole
integer x = 1212
integer y = 236
integer width = 558
integer taborder = 30
string text = "&Clear"
end type

event clicked;call super::clicked;u_oc	loc_object

loc_object = of_OLEControl()
If IsValid(loc_object) Then loc_object.event pfc_clear()
end event

type cb_close from u_cb within w_controlgallery
integer x = 2121
integer y = 1684
integer taborder = 20
string text = "Close"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
