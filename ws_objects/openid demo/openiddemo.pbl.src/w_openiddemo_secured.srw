$PBExportHeader$w_openiddemo_secured.srw
$PBExportComments$PFC OpenID Connect demo: a window secured by PFC security
forward
global type w_openiddemo_secured from w_main
end type
type st_intro from statictext within w_openiddemo_secured
end type
type cb_new from u_cb within w_openiddemo_secured
end type
type cb_approve from u_cb within w_openiddemo_secured
end type
type cb_delete from u_cb within w_openiddemo_secured
end type
type st_discount from statictext within w_openiddemo_secured
end type
type sle_discount from singlelineedit within w_openiddemo_secured
end type
type dw_orders from u_dw within w_openiddemo_secured
end type
type cb_close from u_cb within w_openiddemo_secured
end type
end forward

global type w_openiddemo_secured from w_main
integer x = 800
integer y = 400
integer width = 2263
integer height = 1540
string title = "Secured Window"
st_intro st_intro
cb_new cb_new
cb_approve cb_approve
cb_delete cb_delete
st_discount st_discount
sle_discount sle_discount
dw_orders dw_orders
cb_close cb_close
end type
global w_openiddemo_secured w_openiddemo_secured

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	Fills the orders and applies PFC security: the settings of the
//						user's groups, initialized by the main window (of_InitSecurity),
//						enable, disable or hide the controls and columns.
//
//////////////////////////////////////////////////////////////////////////////
long	ll_row
string	ls_customers[] = {"Northwind Traders", "Contoso", "Fabrikam"}
decimal	ldc_amounts[] = {1250.00, 480.50, 3999.99}

For ll_row = 1 To 3
	dw_orders.InsertRow(0)
	dw_orders.SetItem(ll_row, "order_id", 1000 + ll_row)
	dw_orders.SetItem(ll_row, "customer", ls_customers[ll_row])
	dw_orders.SetItem(ll_row, "amount", ldc_amounts[ll_row])
Next
dw_orders.ResetUpdate()

this.Title = "Secured Window - " + gnv_app.of_GetUserID()
st_intro.Text = "Signed in as " + gnv_app.of_GetUserID() + ".  PFC security enables, disables or hides this window's buttons, the discount and the order columns, as the security administrator sets them for the user's groups.  Controls without settings keep their state."

If IsValid(gnv_app.inv_security) Then gnv_app.inv_security.of_SetSecurity(this)
end event

on w_openiddemo_secured.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.cb_new=create cb_new
this.cb_approve=create cb_approve
this.cb_delete=create cb_delete
this.st_discount=create st_discount
this.sle_discount=create sle_discount
this.dw_orders=create dw_orders
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.cb_new
this.Control[iCurrent+3]=this.cb_approve
this.Control[iCurrent+4]=this.cb_delete
this.Control[iCurrent+5]=this.st_discount
this.Control[iCurrent+6]=this.sle_discount
this.Control[iCurrent+7]=this.dw_orders
this.Control[iCurrent+8]=this.cb_close
end on

on w_openiddemo_secured.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.cb_new)
destroy(this.cb_approve)
destroy(this.cb_delete)
destroy(this.st_discount)
destroy(this.sle_discount)
destroy(this.dw_orders)
destroy(this.cb_close)
end on

type st_intro from statictext within w_openiddemo_secured
integer x = 37
integer y = 32
integer width = 2167
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = ""
boolean focusrectangle = false
end type

type cb_new from u_cb within w_openiddemo_secured
integer x = 37
integer y = 260
integer width = 512
integer taborder = 10
string text = "&New Order"
end type

event clicked;call super::clicked;dw_orders.ScrollToRow(dw_orders.InsertRow(0))
end event

type cb_approve from u_cb within w_openiddemo_secured
integer x = 585
integer y = 260
integer width = 512
integer taborder = 20
string text = "&Approve"
end type

event clicked;call super::clicked;MessageBox(parent.Title, "The order is approved.")
end event

type cb_delete from u_cb within w_openiddemo_secured
integer x = 1133
integer y = 260
integer width = 512
integer taborder = 30
string text = "&Delete"
end type

event clicked;call super::clicked;If dw_orders.GetRow() > 0 Then dw_orders.DeleteRow(dw_orders.GetRow())
end event

type st_discount from statictext within w_openiddemo_secured
integer x = 37
integer y = 412
integer width = 300
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "D&iscount:"
boolean focusrectangle = false
end type

type sle_discount from singlelineedit within w_openiddemo_secured
integer x = 347
integer y = 400
integer width = 400
integer height = 84
integer taborder = 40
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type dw_orders from u_dw within w_openiddemo_secured
integer x = 37
integer y = 520
integer width = 2167
integer height = 760
integer taborder = 50
string dataobject = "d_openiddemo_orders"
boolean vscrollbar = true
boolean livescroll = true
end type

type cb_close from u_cb within w_openiddemo_secured
integer x = 1838
integer y = 1320
integer taborder = 60
string text = "Close"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
