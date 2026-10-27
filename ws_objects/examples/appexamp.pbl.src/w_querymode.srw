$PBExportHeader$w_querymode.srw
$PBExportComments$Example of the query mode service (n_cst_dwsrv_querymode)
forward
global type w_querymode from w_main
end type
type st_intro from statictext within w_querymode
end type
type cb_query from u_cb within w_querymode
end type
type cb_save from u_cb within w_querymode
end type
type cb_load from u_cb within w_querymode
end type
type cbx_somecolumns from checkbox within w_querymode
end type
type cbx_reset from checkbox within w_querymode
end type
type st_status from statictext within w_querymode
end type
type dw_1 from u_dw within w_querymode
end type
type cb_close from u_cb within w_querymode
end type
end forward

global type w_querymode from w_main
integer x = 594
integer y = 300
integer width = 2551
integer height = 1940
string title = "PFC Example - Query Mode Service"
st_intro st_intro
cb_query cb_query
cb_save cb_save
cb_load cb_load
cbx_somecolumns cbx_somecolumns
cbx_reset cbx_reset
st_status st_status
dw_1 dw_1
cb_close cb_close
end type
global w_querymode w_querymode

forward prototypes
protected subroutine of_showstate ()
protected subroutine of_setquerycolumns ()
end prototypes

protected subroutine of_showstate ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_ShowState
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Description:	Shows whether the DataWindow is in query mode, and sets the buttons
//						to match.
//
//////////////////////////////////////////////////////////////////////////////
If dw_1.inv_querymode.of_GetEnabled() Then
	cb_query.Text = "&Run Query"
	st_status.Text = "Query mode: type criteria in the columns, then Run Query."
Else
	cb_query.Text = "&Enter Query"
	st_status.Text = String(dw_1.RowCount()) + " employees"
End If
cb_save.Enabled = dw_1.inv_querymode.of_GetEnabled()
cbx_somecolumns.Enabled = Not dw_1.inv_querymode.of_GetEnabled()
end subroutine

protected subroutine of_setquerycolumns ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_SetQueryColumns
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Description:	Sets the columns that can have criteria: all of them, or only last
//						name, department, city and state (the others are protected while
//						the DataWindow is in query mode).
//
//////////////////////////////////////////////////////////////////////////////
string	ls_columns[]

If cbx_somecolumns.Checked Then
	ls_columns = {"emp_lname", "dept_id", "city", "state"}
End If
dw_1.inv_querymode.of_SetQueryCols(ls_columns)
end subroutine

on w_querymode.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.cb_query=create cb_query
this.cb_save=create cb_save
this.cb_load=create cb_load
this.cbx_somecolumns=create cbx_somecolumns
this.cbx_reset=create cbx_reset
this.st_status=create st_status
this.dw_1=create dw_1
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.cb_query
this.Control[iCurrent+3]=this.cb_save
this.Control[iCurrent+4]=this.cb_load
this.Control[iCurrent+5]=this.cbx_somecolumns
this.Control[iCurrent+6]=this.cbx_reset
this.Control[iCurrent+7]=this.st_status
this.Control[iCurrent+8]=this.dw_1
this.Control[iCurrent+9]=this.cb_close
end on

on w_querymode.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.cb_query)
destroy(this.cb_save)
destroy(this.cb_load)
destroy(this.cbx_somecolumns)
destroy(this.cbx_reset)
destroy(this.st_status)
destroy(this.dw_1)
destroy(this.cb_close)
end on

type st_intro from statictext within w_querymode
integer x = 37
integer y = 32
integer width = 2437
integer height = 228
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "The query mode service (n_cst_dwsrv_querymode) lets users search a DataWindow by typing criteria in its columns, such as >S for Last Name, CA for State or >200 for Department; criteria on one line are combined with AND, and each line is an OR.  In query mode, right-click a column for its operators and values.  Run Query retrieves the rows that match."
boolean focusrectangle = false
end type

type cb_query from u_cb within w_querymode
integer x = 37
integer y = 284
integer width = 448
integer taborder = 10
string text = "&Enter Query"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// Entering query mode clears the criteria (if Clear the Criteria is checked);
// leaving it retrieves with the criteria (of_SetRetrieveOnDisabled, on by default)
If Not dw_1.inv_querymode.of_GetEnabled() Then parent.of_SetQueryColumns()
dw_1.inv_querymode.of_SetEnabled(Not dw_1.inv_querymode.of_GetEnabled())
parent.of_ShowState()
end event

type cb_save from u_cb within w_querymode
integer x = 507
integer y = 284
integer width = 448
integer taborder = 20
boolean enabled = false
string text = "&Save Query..."
string facename = "Segoe UI"
end type

event clicked;call super::clicked;string	ls_path, ls_file

dw_1.inv_querymode.of_Save("Save Query", ls_path, ls_file, "qry", "Query Files (*.qry),*.qry")
end event

type cb_load from u_cb within w_querymode
integer x = 978
integer y = 284
integer width = 448
integer taborder = 30
string text = "&Load Query..."
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// of_Load puts the DataWindow in query mode with the saved criteria
string	ls_path, ls_file

If Not dw_1.inv_querymode.of_GetEnabled() Then parent.of_SetQueryColumns()
dw_1.inv_querymode.of_Load("Load Query", ls_path, ls_file, "qry", "Query Files (*.qry),*.qry")
parent.of_ShowState()
end event

type cbx_somecolumns from checkbox within w_querymode
integer x = 1463
integer y = 280
integer width = 1010
integer height = 72
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Only some columns (of_SetQueryCols)"
end type

type cbx_reset from checkbox within w_querymode
integer x = 1463
integer y = 352
integer width = 1010
integer height = 72
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Clear the criteria each time"
boolean checked = true
end type

event clicked;// Keep the criteria of the last query for the next one, or start afresh
dw_1.inv_querymode.of_SetResetCriteria(this.Checked)
end event

type st_status from statictext within w_querymode
integer x = 37
integer y = 448
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

type dw_1 from u_dw within w_querymode
string dataobject = "d_empall"
integer x = 37
integer y = 528
integer width = 2437
integer height = 1140
integer taborder = 40
boolean hscrollbar = true
end type

event constructor;call super::constructor;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			constructor
//
//	Description:	Starts the query mode service and retrieves all the employees.
//
//////////////////////////////////////////////////////////////////////////////
of_SetTransObject(sqlca)
of_SetQueryMode(True)
of_Retrieve()
parent.Post of_ShowState()
end event

event pfc_retrieve;call super::pfc_retrieve;Return this.Retrieve()
end event

event retrieveend;call super::retrieveend;parent.of_ShowState()
end event

type cb_close from u_cb within w_querymode
integer x = 2107
integer y = 1716
integer taborder = 50
string text = "Close"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
