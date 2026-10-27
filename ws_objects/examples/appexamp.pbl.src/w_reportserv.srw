$PBExportHeader$w_reportserv.srw
$PBExportComments$Example of the report service (n_cst_dwsrv_report)
forward
global type w_reportserv from w_main
end type
type st_intro from statictext within w_reportserv
end type
type cb_title from u_cb within w_reportserv
end type
type cb_count from u_cb within w_reportserv
end type
type cb_line from u_cb within w_reportserv
end type
type cb_color from u_cb within w_reportserv
end type
type cb_zoomin from u_cb within w_reportserv
end type
type cb_zoomout from u_cb within w_reportserv
end type
type cb_undo from u_cb within w_reportserv
end type
type cb_print from u_cb within w_reportserv
end type
type st_status from statictext within w_reportserv
end type
type dw_1 from u_dw within w_reportserv
end type
type cb_close from u_cb within w_reportserv
end type
end forward

global type w_reportserv from w_main
integer x = 594
integer y = 300
integer width = 2551
integer height = 1940
string title = "PFC Example - Report Service"
st_intro st_intro
cb_title cb_title
cb_count cb_count
cb_line cb_line
cb_color cb_color
cb_zoomin cb_zoomin
cb_zoomout cb_zoomout
cb_undo cb_undo
cb_print cb_print
st_status st_status
dw_1 dw_1
cb_close cb_close
end type
global w_reportserv w_reportserv

forward prototypes
protected subroutine of_showresult (string as_action, string as_result)
end prototypes

protected subroutine of_showresult (string as_action, string as_result);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_ShowResult
//
//	Access:			Protected
//
//	Arguments:
//	as_action		What was done
//	as_result		The report service function's return value: "" when the Modify
//						worked, or its error text
//
//	Description:	Shows the outcome and how many changes Undo can take back.
//
//////////////////////////////////////////////////////////////////////////////
If as_result = "" Then
	st_status.Text = as_action + ".  Undo levels: " + String(dw_1.inv_report.of_GetUndoLevels())
Else
	st_status.Text = as_action + " failed: " + as_result
End If
end subroutine

on w_reportserv.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.cb_title=create cb_title
this.cb_count=create cb_count
this.cb_line=create cb_line
this.cb_color=create cb_color
this.cb_zoomin=create cb_zoomin
this.cb_zoomout=create cb_zoomout
this.cb_undo=create cb_undo
this.cb_print=create cb_print
this.st_status=create st_status
this.dw_1=create dw_1
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.cb_title
this.Control[iCurrent+3]=this.cb_count
this.Control[iCurrent+4]=this.cb_line
this.Control[iCurrent+5]=this.cb_color
this.Control[iCurrent+6]=this.cb_zoomin
this.Control[iCurrent+7]=this.cb_zoomout
this.Control[iCurrent+8]=this.cb_undo
this.Control[iCurrent+9]=this.cb_print
this.Control[iCurrent+10]=this.st_status
this.Control[iCurrent+11]=this.dw_1
this.Control[iCurrent+12]=this.cb_close
end on

on w_reportserv.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.cb_title)
destroy(this.cb_count)
destroy(this.cb_line)
destroy(this.cb_color)
destroy(this.cb_zoomin)
destroy(this.cb_zoomout)
destroy(this.cb_undo)
destroy(this.cb_print)
destroy(this.st_status)
destroy(this.dw_1)
destroy(this.cb_close)
end on

type st_intro from statictext within w_reportserv
integer x = 37
integer y = 32
integer width = 2437
integer height = 152
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "The report service (n_cst_dwsrv_report) changes a DataWindow at run time to make a report of it: it adds text, computed fields, lines and pictures, changes colors, fonts and borders, zooms, and prints.  Each change can be undone."
boolean focusrectangle = false
end type

type cb_title from u_cb within w_reportserv
integer x = 37
integer y = 208
integer width = 581
integer taborder = 10
string text = "Add a &Title"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// Make room at the top of the header (of_ShiftBand makes the band taller and moves its
// objects down), then center a title there: two changes, so two levels of Undo
string	ls_rc

ls_rc = dw_1.inv_report.of_ShiftBand("header", 0, 100)
If ls_rc = "" Then
	ls_rc = dw_1.inv_report.of_AddText("Customer List", "header", Center!, Top!, NoBorder!, True, False, False)
End If
parent.of_ShowResult("Title added (of_ShiftBand, of_AddText)", ls_rc)
end event

type cb_count from u_cb within w_reportserv
integer x = 640
integer y = 208
integer width = 581
integer taborder = 20
string text = "Add a &Row Count"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// A computed field in the summary band, made tall enough to show it (of_ShiftBand)
// (Text in the expression goes in double quotes: the service checks it with Evaluate('...').)
string	ls_rc

ls_rc = dw_1.inv_report.of_ShiftBand("summary", 0, 80)
If ls_rc = "" Then ls_rc = dw_1.inv_report.of_AddCompute("~"Customers: ~" + String(RowCount())", "summary", Left!, Top!, NoBorder!, True, False, False)
parent.of_ShowResult("Row count added (of_AddCompute)", ls_rc)
end event

type cb_line from u_cb within w_reportserv
integer x = 1243
integer y = 208
integer width = 581
integer taborder = 30
string text = "Add a &Line"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.of_ShowResult("Line added under the headers (of_AddLine)", &
	dw_1.inv_report.of_AddLine("header", Continuous!, 8, Bottom!, RGB(0, 0, 0), RGB(255, 255, 255)))
end event

type cb_color from u_cb within w_reportserv
integer x = 1847
integer y = 208
integer width = 626
integer taborder = 40
string text = "&Color the Headers"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// "*": every object in the header band
parent.of_ShowResult("Header colors changed (of_SetColor)", &
	dw_1.inv_report.of_SetColor(RGB(255, 255, 255), RGB(0, 84, 147), "*", "header"))
end event

type cb_zoomin from u_cb within w_reportserv
integer x = 37
integer y = 320
integer width = 581
integer taborder = 50
string text = "Zoom &In"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// Relative to the current zoom: 125% of it
parent.of_ShowResult("Zoomed in (of_SetRelativeZoom)", dw_1.inv_report.of_SetRelativeZoom(125))
end event

type cb_zoomout from u_cb within w_reportserv
integer x = 640
integer y = 320
integer width = 581
integer taborder = 60
string text = "Zoom &Out"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.of_ShowResult("Zoomed out (of_SetRelativeZoom)", dw_1.inv_report.of_SetRelativeZoom(80))
end event

type cb_undo from u_cb within w_reportserv
integer x = 1243
integer y = 320
integer width = 581
integer taborder = 70
string text = "&Undo"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;If dw_1.inv_report.of_GetUndoLevels() < 1 Then
	st_status.Text = "Nothing to undo"
	Return
End If
// One level; of_Undo() with no argument undoes every change
parent.of_ShowResult("Last change undone (of_Undo)", dw_1.inv_report.of_Undo(1))
end event

type cb_print from u_cb within w_reportserv
integer x = 1847
integer y = 320
integer width = 626
integer taborder = 80
string text = "&Print..."
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// Prints the report as it is now, with the Cancel dialog while it prints
parent.of_ShowResult("Printed (of_PrintReport)", dw_1.inv_report.of_PrintReport(True, True))
end event

type st_status from statictext within w_reportserv
integer x = 37
integer y = 440
integer width = 2437
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
boolean focusrectangle = false
end type

type dw_1 from u_dw within w_reportserv
string dataobject = "d_customerdetail"
integer x = 37
integer y = 528
integer width = 2437
integer height = 1140
integer taborder = 90
boolean hscrollbar = true
end type

event constructor;call super::constructor;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			constructor
//
//	Description:	Starts the report service and retrieves the customers.
//
//////////////////////////////////////////////////////////////////////////////
of_SetTransObject(sqlca)
of_SetReport(True)
of_Retrieve()
end event

event pfc_retrieve;call super::pfc_retrieve;Return this.Retrieve()
end event

type cb_close from u_cb within w_reportserv
integer x = 2107
integer y = 1716
integer taborder = 100
string text = "Close"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
