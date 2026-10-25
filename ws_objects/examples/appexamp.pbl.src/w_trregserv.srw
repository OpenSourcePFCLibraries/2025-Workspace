$PBExportHeader$w_trregserv.srw
$PBExportComments$Example of the transaction registration service (n_cst_trregistration)
forward
global type w_trregserv from w_main
end type
type st_intro from statictext within w_trregserv
end type
type cb_sqlca from u_cb within w_trregserv
end type
type cb_connect from u_cb within w_trregserv
end type
type st_name from statictext within w_trregserv
end type
type sle_name from singlelineedit within w_trregserv
end type
type cb_find from u_cb within w_trregserv
end type
type cb_destroy from u_cb within w_trregserv
end type
type st_list from statictext within w_trregserv
end type
type lb_registered from listbox within w_trregserv
end type
type st_status from statictext within w_trregserv
end type
type cb_close from u_cb within w_trregserv
end type
end forward

global type w_trregserv from w_main
integer x = 594
integer y = 400
integer width = 2240
integer height = 1420
string title = "PFC Example - Transaction Registration"
st_intro st_intro
cb_sqlca cb_sqlca
cb_connect cb_connect
st_name st_name
sle_name sle_name
cb_find cb_find
cb_destroy cb_destroy
st_list st_list
lb_registered lb_registered
st_status st_status
cb_close cb_close
end type
global w_trregserv w_trregserv

type variables
Protected:
// A second connection to the example database, named "Reports"
n_tr	itr_reports
// TRUE if this window registered SQLCA (and unregisters it when it closes)
boolean	ib_registeredsqlca
end variables

forward prototypes
protected subroutine of_showregistered ()
end prototypes

protected subroutine of_showregistered ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_ShowRegistered
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Description:	Lists the registered transactions (of_GetRegistered) and sets the
//						buttons to match.
//
//////////////////////////////////////////////////////////////////////////////
n_tr		ltr_registered[]
integer	li_count, li_i
string	ls_connected

lb_registered.Reset()
li_count = gnv_app.inv_trregistration.of_GetRegistered(ltr_registered)
For li_i = 1 To li_count
	If ltr_registered[li_i].of_IsConnected() Then
		ls_connected = "connected"
	Else
		ls_connected = "not connected"
	End If
	lb_registered.AddItem(ltr_registered[li_i].of_GetName() + "  (" + ltr_registered[li_i].DBMS + ", " + ls_connected + ")")
Next
st_list.Text = "Registered transactions (of_GetRegistered): " + String(gnv_app.inv_trregistration.of_GetCount())

If gnv_app.inv_trregistration.of_IsRegistered(sqlca) Then
	cb_sqlca.Text = "Unregister &SQLCA"
Else
	cb_sqlca.Text = "Register &SQLCA"
End If
cb_connect.Enabled = Not IsValid(itr_reports)
end subroutine

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	The Examples application starts the service (of_SetTrRegistration in
//						its application manager) and names SQLCA Main-Trans, but doesn't
//						register it.
//
//////////////////////////////////////////////////////////////////////////////
If Not IsValid(gnv_app.inv_trregistration) Then gnv_app.of_SetTrRegistration(True)
of_ShowRegistered()
end event

event close;call super::close;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			close
//
//	Description:	Leaves the registrations as they were: unregisters SQLCA if this
//						window registered it, and disconnects and destroys the Reports
//						transaction.
//
//////////////////////////////////////////////////////////////////////////////
If ib_registeredsqlca And gnv_app.inv_trregistration.of_IsRegistered(sqlca) Then
	gnv_app.inv_trregistration.of_Unregister(sqlca)
End If
If IsValid(itr_reports) Then
	gnv_app.inv_trregistration.of_Unregister(itr_reports)
	If itr_reports.of_IsConnected() Then itr_reports.of_DisConnect()
	Destroy itr_reports
End If
end event

on w_trregserv.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.cb_sqlca=create cb_sqlca
this.cb_connect=create cb_connect
this.st_name=create st_name
this.sle_name=create sle_name
this.cb_find=create cb_find
this.cb_destroy=create cb_destroy
this.st_list=create st_list
this.lb_registered=create lb_registered
this.st_status=create st_status
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.cb_sqlca
this.Control[iCurrent+3]=this.cb_connect
this.Control[iCurrent+4]=this.st_name
this.Control[iCurrent+5]=this.sle_name
this.Control[iCurrent+6]=this.cb_find
this.Control[iCurrent+7]=this.cb_destroy
this.Control[iCurrent+8]=this.st_list
this.Control[iCurrent+9]=this.lb_registered
this.Control[iCurrent+10]=this.st_status
this.Control[iCurrent+11]=this.cb_close
end on

on w_trregserv.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.cb_sqlca)
destroy(this.cb_connect)
destroy(this.st_name)
destroy(this.sle_name)
destroy(this.cb_find)
destroy(this.cb_destroy)
destroy(this.st_list)
destroy(this.lb_registered)
destroy(this.st_status)
destroy(this.cb_close)
end on

type st_intro from statictext within w_trregserv
integer x = 37
integer y = 32
integer width = 2130
integer height = 172
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "The transaction registration service (n_cst_trregistration, started with the application manager's of_SetTrRegistration) keeps track of an application's transaction objects (n_tr): code anywhere can find one by name, and the service can destroy them all, for example when the application closes."
boolean focusrectangle = false
end type

type cb_sqlca from u_cb within w_trregserv
integer x = 37
integer y = 228
integer width = 677
integer taborder = 10
string text = "Register &SQLCA"
end type

event clicked;call super::clicked;If gnv_app.inv_trregistration.of_IsRegistered(sqlca) Then
	gnv_app.inv_trregistration.of_Unregister(sqlca)
	ib_registeredsqlca = False
	st_status.Text = "SQLCA unregistered (of_Unregister)"
Else
	gnv_app.inv_trregistration.of_Register(sqlca)
	ib_registeredsqlca = True
	st_status.Text = "SQLCA registered (of_Register) under its name, " + sqlca.of_GetName()
End If
parent.of_ShowRegistered()
end event

type cb_connect from u_cb within w_trregserv
integer x = 736
integer y = 228
integer width = 1431
integer taborder = 20
string text = "&Connect and Register a Second Transaction, ~"Reports~""
end type

event clicked;call super::clicked;// Another connection to the example database, as an application might open for its
// reports, named so code can find it (of_SetName, of_GetByName)
itr_reports = Create n_tr
itr_reports.of_SetName("Reports")
If itr_reports.of_Init(gnv_app.of_GetAppIniFile(), "Database") <> 1 Or itr_reports.of_Connect() <> 0 Then
	st_status.Text = "Unable to connect: " + itr_reports.SQLErrText
	Destroy itr_reports
	Return
End If
gnv_app.inv_trregistration.of_Register(itr_reports)
st_status.Text = "Reports connected and registered"
parent.of_ShowRegistered()
end event

type st_name from statictext within w_trregserv
integer x = 37
integer y = 352
integer width = 197
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Name:"
boolean focusrectangle = false
end type

type sle_name from singlelineedit within w_trregserv
integer x = 247
integer y = 340
integer width = 466
integer height = 84
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
string text = "Reports"
borderstyle borderstyle = stylelowered!
end type

type cb_find from u_cb within w_trregserv
integer x = 736
integer y = 340
integer width = 677
integer taborder = 40
string text = "&Find by Name"
end type

event clicked;call super::clicked;n_tr	ltr_found
string	ls_connected

If gnv_app.inv_trregistration.of_GetByName(sle_name.Text, ltr_found) = 1 Then
	If ltr_found.of_IsConnected() Then ls_connected = "connected" Else ls_connected = "not connected"
	st_status.Text = "of_GetByName found " + ltr_found.of_GetName() + ": " + ltr_found.DBMS + &
		", server " + ltr_found.ServerName + ", " + ls_connected
Else
	st_status.Text = "No registered transaction is named " + sle_name.Text
End If
end event

type cb_destroy from u_cb within w_trregserv
integer x = 1435
integer y = 340
integer width = 731
integer taborder = 50
string text = "&Destroy All Registered"
end type

event clicked;call super::clicked;// of_Destroy unregisters and destroys every registered transaction, SQLCA too by
// default.  The other examples still use SQLCA, so it is kept here with
// of_SetAllowSQLCADestroy(FALSE) (and the setting is put back afterwards).
integer	li_destroyed
boolean	lb_allowsqlca

lb_allowsqlca = gnv_app.inv_trregistration.of_IsAllowSQLCADestroy()
gnv_app.inv_trregistration.of_SetAllowSQLCADestroy(False)
li_destroyed = gnv_app.inv_trregistration.of_Destroy()
gnv_app.inv_trregistration.of_SetAllowSQLCADestroy(lb_allowsqlca)
If gnv_app.inv_trregistration.of_IsRegistered(sqlca) Then
	st_status.Text = "of_Destroy destroyed " + String(li_destroyed) + " transaction(s); SQLCA is kept, still registered (of_SetAllowSQLCADestroy(FALSE))"
Else
	st_status.Text = "of_Destroy destroyed " + String(li_destroyed) + " transaction(s)"
End If
parent.of_ShowRegistered()
end event

type st_list from statictext within w_trregserv
integer x = 37
integer y = 464
integer width = 2130
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

type lb_registered from listbox within w_trregserv
integer x = 37
integer y = 536
integer width = 2130
integer height = 440
integer taborder = 60
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
boolean vscrollbar = true
borderstyle borderstyle = stylelowered!
end type

type st_status from statictext within w_trregserv
integer x = 37
integer y = 1000
integer width = 2130
integer height = 128
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

type cb_close from u_cb within w_trregserv
integer x = 1792
integer y = 1164
integer taborder = 70
string text = "Close"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
