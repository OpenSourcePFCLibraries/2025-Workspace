$PBExportHeader$w_gridserv.srw
$PBExportComments$Example of the grid service (n_cst_dwsrv_grid) and its Grid Layout dialog (w_grid)
forward
global type w_gridserv from w_main
end type
type st_intro from statictext within w_gridserv
end type
type cb_layout from u_cb within w_gridserv
end type
type cb_original from u_cb within w_gridserv
end type
type dw_1 from u_dw within w_gridserv
end type
type cb_close from u_cb within w_gridserv
end type
end forward

global type w_gridserv from w_main
integer x = 594
integer y = 300
integer width = 2551
integer height = 1940
string title = "PFC Example - Grid Service"
st_intro st_intro
cb_layout cb_layout
cb_original cb_original
dw_1 dw_1
cb_close cb_close
end type
global w_gridserv w_gridserv

on w_gridserv.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.cb_layout=create cb_layout
this.cb_original=create cb_original
this.dw_1=create dw_1
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.cb_layout
this.Control[iCurrent+3]=this.cb_original
this.Control[iCurrent+4]=this.dw_1
this.Control[iCurrent+5]=this.cb_close
end on

on w_gridserv.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.cb_layout)
destroy(this.cb_original)
destroy(this.dw_1)
destroy(this.cb_close)
end on

type st_intro from statictext within w_gridserv
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
string text = "The grid service (n_cst_dwsrv_grid) lets users choose which columns a grid DataWindow shows, in which order and how wide, in the Grid Layout dialog: click Grid Layout, or right-click the list and choose Grid Layout.  The layout is saved for each user when the window closes (through the application preference service) and restored the next time it opens."
boolean focusrectangle = false
end type

type cb_layout from u_cb within w_gridserv
integer x = 37
integer y = 284
integer width = 581
integer taborder = 10
string text = "&Grid Layout..."
string facename = "Segoe UI"
end type

event clicked;call super::clicked;dw_1.inv_grid.Event pfc_ShowDialog()
end event

type cb_original from u_cb within w_gridserv
integer x = 640
integer y = 284
integer width = 581
integer taborder = 20
string text = "&Original Layout"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// Back to the layout of the DataWindow object, as the dialog's own button does
dw_1.inv_grid.of_RestoreOriginalLayout()
dw_1.inv_grid.of_Apply()
end event

type dw_1 from u_dw within w_gridserv
string dataobject = "d_empall"
integer x = 37
integer y = 400
integer width = 2437
integer height = 1268
integer taborder = 30
boolean hscrollbar = true
end type

event constructor;call super::constructor;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			constructor
//
//	Description:	Starts the grid service, which restores the layout saved the last
//						time (u_dw saves it when it is destroyed), and retrieves the employees.
//
//////////////////////////////////////////////////////////////////////////////
of_SetTransObject(sqlca)
of_SetGrid(True)
inv_grid.of_SetDialogTitle("Grid Layout")
of_Retrieve()
end event

event pfc_retrieve;call super::pfc_retrieve;Return this.Retrieve()
end event

type cb_close from u_cb within w_gridserv
integer x = 2107
integer y = 1716
integer taborder = 40
string text = "Close"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
