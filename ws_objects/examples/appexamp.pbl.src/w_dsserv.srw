$PBExportHeader$w_dsserv.srw
$PBExportComments$Example of the DataStore services (n_cst_dssrv, n_cst_dssrv_report, n_cst_dssrv_printpreview)
forward
global type w_dsserv from w_main
end type
type st_intro from statictext within w_dsserv
end type
type gb_base from groupbox within w_dsserv
end type
type cb_read from u_cb within w_dsserv
end type
type st_name from statictext within w_dsserv
end type
type sle_name from singlelineedit within w_dsserv
end type
type cb_filter from u_cb within w_dsserv
end type
type mle_values from multilineedit within w_dsserv
end type
type gb_report from groupbox within w_dsserv
end type
type cb_title from u_cb within w_dsserv
end type
type cb_pages from u_cb within w_dsserv
end type
type cb_print from u_cb within w_dsserv
end type
type st_report from statictext within w_dsserv
end type
type dw_view from datawindow within w_dsserv
end type
type cb_close from u_cb within w_dsserv
end type
end forward

global type w_dsserv from w_main
integer x = 594
integer y = 200
integer width = 2551
integer height = 2200
string title = "PFC Example - DataStore Services"
st_intro st_intro
gb_base gb_base
cb_read cb_read
st_name st_name
sle_name sle_name
cb_filter cb_filter
mle_values mle_values
gb_report gb_report
cb_title cb_title
cb_pages cb_pages
cb_print cb_print
st_report st_report
dw_view dw_view
cb_close cb_close
end type
global w_dsserv w_dsserv

type variables
Protected:
// The employees, for the base service
n_ds	ids_employees
// The customers, for the report and print preview services; dw_view shows them
n_ds	ids_customers
end variables

forward prototypes
protected subroutine of_showcustomers ()
end prototypes

protected subroutine of_showcustomers ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_ShowCustomers
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Description:	Shows the customers DataStore in dw_view as it is now: the same
//						DataWindow object, with the changes the services made to it, and the
//						same data (ShareData).
//
//////////////////////////////////////////////////////////////////////////////
string	ls_errors

If dw_view.Create(ids_customers.Describe("DataWindow.Syntax"), ls_errors) <> 1 Then
	st_report.Text = "The customers could not be shown: " + ls_errors
	Return
End If
ids_customers.ShareData(dw_view)
end subroutine

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	Creates the two DataStores with their services and retrieves them.
//
//////////////////////////////////////////////////////////////////////////////
ids_employees = Create n_ds
ids_employees.DataObject = "d_empall"
ids_employees.of_SetTransObject(sqlca)
ids_employees.of_SetBase(True)
ids_employees.of_SetParentWindow(this)
ids_employees.Retrieve()

ids_customers = Create n_ds
ids_customers.DataObject = "d_customerdetail"
ids_customers.of_SetTransObject(sqlca)
ids_customers.of_SetParentWindow(this)
ids_customers.of_SetReport(True)
ids_customers.of_SetPrintPreview(True)
ids_customers.Retrieve()

of_ShowCustomers()
mle_values.Text = String(ids_employees.RowCount()) + " employees in the DataStore.  Read Values shows the first five."
end event

event close;call super::close;If IsValid(ids_employees) Then Destroy ids_employees
If IsValid(ids_customers) Then Destroy ids_customers
end event

on w_dsserv.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.gb_base=create gb_base
this.cb_read=create cb_read
this.st_name=create st_name
this.sle_name=create sle_name
this.cb_filter=create cb_filter
this.mle_values=create mle_values
this.gb_report=create gb_report
this.cb_title=create cb_title
this.cb_pages=create cb_pages
this.cb_print=create cb_print
this.st_report=create st_report
this.dw_view=create dw_view
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.cb_read
this.Control[iCurrent+3]=this.st_name
this.Control[iCurrent+4]=this.sle_name
this.Control[iCurrent+5]=this.cb_filter
this.Control[iCurrent+6]=this.mle_values
this.Control[iCurrent+7]=this.cb_title
this.Control[iCurrent+8]=this.cb_pages
this.Control[iCurrent+9]=this.cb_print
this.Control[iCurrent+10]=this.st_report
this.Control[iCurrent+11]=this.dw_view
this.Control[iCurrent+12]=this.cb_close
this.Control[iCurrent+13]=this.gb_base
this.Control[iCurrent+14]=this.gb_report
end on

on w_dsserv.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.gb_base)
destroy(this.cb_read)
destroy(this.st_name)
destroy(this.sle_name)
destroy(this.cb_filter)
destroy(this.mle_values)
destroy(this.gb_report)
destroy(this.cb_title)
destroy(this.cb_pages)
destroy(this.cb_print)
destroy(this.st_report)
destroy(this.dw_view)
destroy(this.cb_close)
end on

type st_intro from statictext within w_dsserv
integer x = 37
integer y = 32
integer width = 2437
integer height = 152
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "PFC's DataStore, n_ds, has services of its own, like u_dw's: the base service (n_cst_dssrv) reads values as they are displayed and builds expressions, and the report and print preview services change and print a DataStore that is never shown."
boolean focusrectangle = false
end type

type gb_base from groupbox within w_dsserv
integer x = 37
integer y = 200
integer width = 2437
integer height = 760
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Base service (n_cst_dssrv), on the employees"
end type

type cb_read from u_cb within w_dsserv
integer x = 82
integer y = 276
integer width = 562
integer taborder = 10
string text = "&Read Values"
end type

event clicked;call super::clicked;// The stored value beside the value as it is displayed (of_GetItem: the display value
// of the status code table, the format of the salary), under the columns' header
// names (of_GetHeaderName)
string	ls_columns[], ls_text, ls_stored, ls_shown
long		ll_row
integer	li_col
n_cst_string	lnv_string

ls_columns = {"emp_lname", "status", "salary"}
For li_col = 1 To UpperBound(ls_columns)
	ls_text += lnv_string.of_PadRight(lnv_string.of_GlobalReplace(ids_employees.inv_base.of_GetHeaderName(ls_columns[li_col]), "~r~n", " "), 20)
Next
ls_text += "~r~n"
For ll_row = 1 To Min(5, ids_employees.RowCount())
	For li_col = 1 To UpperBound(ls_columns)
		ls_stored = String(ids_employees.inv_base.of_GetItemAny(ll_row, ls_columns[li_col]))
		ls_shown = ids_employees.inv_base.of_GetItem(ll_row, ls_columns[li_col])
		If ls_shown <> ls_stored Then ls_stored += " (" + ls_shown + ")"
		ls_text += lnv_string.of_PadRight(ls_stored, 20)
	Next
	ls_text += "~r~n"
Next
mle_values.Text = "Stored values (displayed values in parentheses):~r~n~r~n" + ls_text
end event

type st_name from statictext within w_dsserv
integer x = 677
integer y = 288
integer width = 247
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Last name:"
boolean focusrectangle = false
end type

type sle_name from singlelineedit within w_dsserv
integer x = 937
integer y = 276
integer width = 581
integer height = 84
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
string text = "O'Brien"
borderstyle borderstyle = stylelowered!
end type

type cb_filter from u_cb within w_dsserv
integer x = 1541
integer y = 276
integer width = 888
integer taborder = 30
string text = "Build a &Filter Expression"
end type

event clicked;call super::clicked;// of_BuildExpression quotes the value for an expression, so a name with a quote
// (O'Brien) or a tilde gives a valid filter; the DataStore is filtered with it
string	ls_expression, ls_text
long		ll_rows

ls_expression = String(ids_employees.inv_base.of_BuildExpression(1, "emp_lname", "=", sle_name.Text))
ls_text = "of_BuildExpression: " + ls_expression + "~r~n"
If ids_employees.SetFilter(ls_expression) = 1 Then
	ids_employees.Filter()
	ll_rows = ids_employees.RowCount()
	ls_text += "Filtered: " + String(ll_rows) + " employees with that last name"
	ids_employees.SetFilter("")
	ids_employees.Filter()
Else
	ls_text += "The filter could not be set"
End If
mle_values.Text = ls_text
end event

type mle_values from multilineedit within w_dsserv
integer x = 82
integer y = 384
integer width = 2347
integer height = 540
integer taborder = 40
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "Courier New"
long textcolor = 33554432
boolean vscrollbar = true
boolean hscrollbar = true
boolean displayonly = true
borderstyle borderstyle = stylelowered!
end type

type gb_report from groupbox within w_dsserv
integer x = 37
integer y = 984
integer width = 2437
integer height = 272
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Report and print preview services (n_cst_dssrv_report, n_cst_dssrv_printpreview), on the customers"
end type

type cb_title from u_cb within w_dsserv
integer x = 82
integer y = 1060
integer width = 562
integer taborder = 50
string text = "Add a &Title"
end type

event clicked;call super::clicked;// The report service changes the DataStore; dw_view then shows it as it is now
string	ls_rc

ls_rc = ids_customers.inv_report.of_ShiftBand("header", 0, 100)
If ls_rc = "" Then ls_rc = ids_customers.inv_report.of_AddText("Customer List", "header", Center!, Top!, NoBorder!, True, False, False)
If ls_rc = "" Then
	st_report.Text = "Title added to the DataStore (of_ShiftBand, of_AddText)"
Else
	st_report.Text = "Adding the title failed: " + ls_rc
End If
parent.of_ShowCustomers()
end event

type cb_pages from u_cb within w_dsserv
integer x = 667
integer y = 1060
integer width = 562
integer taborder = 60
string text = "&Count Pages"
end type

event clicked;call super::clicked;// The print preview service puts the DataStore in preview mode to count its pages
integer	li_pages

ids_customers.inv_printpreview.of_SetEnabled(True)
li_pages = ids_customers.inv_printpreview.of_PageCount()
ids_customers.inv_printpreview.of_SetEnabled(False)
st_report.Text = "The customer list prints on " + String(li_pages) + " page(s) (of_PageCount)"
end event

type cb_print from u_cb within w_dsserv
integer x = 1253
integer y = 1060
integer width = 562
integer taborder = 70
string text = "&Print..."
end type

event clicked;call super::clicked;string	ls_rc

ls_rc = ids_customers.inv_report.of_PrintReport(True, True)
If ls_rc = "" Then
	st_report.Text = "Printed (of_PrintReport)"
Else
	st_report.Text = "Printing failed: " + ls_rc
End If
end event

type st_report from statictext within w_dsserv
integer x = 82
integer y = 1172
integer width = 2347
integer height = 64
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

type dw_view from datawindow within w_dsserv
integer x = 37
integer y = 1280
integer width = 2437
integer height = 700
integer taborder = 80
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

type cb_close from u_cb within w_dsserv
integer x = 2107
integer y = 2012
integer taborder = 90
string text = "Close"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
