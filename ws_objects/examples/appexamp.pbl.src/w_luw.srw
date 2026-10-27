$PBExportHeader$w_luw.srw
$PBExportComments$Example of the logical unit of work service (n_cst_luw): saving a DataWindow and a DataStore in one transaction
forward
global type w_luw from w_main
end type
type st_intro from statictext within w_luw
end type
type st_emp from statictext within w_luw
end type
type dw_emp from u_dw within w_luw
end type
type st_depts from statictext within w_luw
end type
type dw_depts from u_dw within w_luw
end type
type cb_case from u_cb within w_luw
end type
type cb_pending from u_cb within w_luw
end type
type cb_save from u_cb within w_luw
end type
type cb_error from u_cb within w_luw
end type
type cb_discard from u_cb within w_luw
end type
type st_status from statictext within w_luw
end type
type cb_close from u_cb within w_luw
end type
end forward

global type w_luw from w_main
integer x = 594
integer y = 300
integer width = 2551
integer height = 1840
string title = "PFC Example - Logical Unit of Work"
st_intro st_intro
st_emp st_emp
dw_emp dw_emp
st_depts st_depts
dw_depts dw_depts
cb_case cb_case
cb_pending cb_pending
cb_save cb_save
cb_error cb_error
cb_discard cb_discard
st_status st_status
cb_close cb_close
end type
global w_luw w_luw

type variables
Protected:
// The departments, in a DataStore; dw_depts shows its rows (ShareData)
n_ds	ids_depts
end variables

forward prototypes
protected function integer of_save ()
protected function integer of_retrieve ()
end prototypes

protected function integer of_save ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_Save
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Returns:			Integer
//						The return code of n_cst_luw.of_Save: 1 if both were saved, 0 if
//						there was nothing to save, -1 or less if it failed
//
//	Description:	Saves the employees (a DataWindow) and the departments (a
//						DataStore) in one transaction: of_Save accepts the text, validates,
//						updates each one, and commits, or rolls back everything if an
//						update fails.
//
//////////////////////////////////////////////////////////////////////////////
n_cst_luw	lnv_luw
powerobject	lpo_save[]
integer	li_rc

lpo_save[1] = dw_emp
lpo_save[2] = ids_depts

lnv_luw = Create n_cst_luw
li_rc = lnv_luw.of_Save(lpo_save, sqlca)
Destroy lnv_luw
Return li_rc
end function

protected function integer of_retrieve ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_Retrieve
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Returns:			Integer	1
//
//	Description:	Reads the employees and the departments from the database again.
//
//////////////////////////////////////////////////////////////////////////////
dw_emp.event pfc_retrieve()
ids_depts.Retrieve()
Return 1
end function

event open;call super::open;ids_depts = Create n_ds
ids_depts.DataObject = "d_depts"
ids_depts.of_SetTransObject(sqlca)
ids_depts.ShareData(dw_depts)
of_Retrieve()
end event

event close;call super::close;If IsValid(ids_depts) Then
	ids_depts.ShareDataOff()
	Destroy ids_depts
End If
end event

event pfc_save;// The window's own save would save dw_emp, but not the DataStore;
// File > Save saves both, as the Save Both button does
Return of_Save()
end event

on w_luw.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.st_emp=create st_emp
this.dw_emp=create dw_emp
this.st_depts=create st_depts
this.dw_depts=create dw_depts
this.cb_case=create cb_case
this.cb_pending=create cb_pending
this.cb_save=create cb_save
this.cb_error=create cb_error
this.cb_discard=create cb_discard
this.st_status=create st_status
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.st_emp
this.Control[iCurrent+3]=this.dw_emp
this.Control[iCurrent+4]=this.st_depts
this.Control[iCurrent+5]=this.dw_depts
this.Control[iCurrent+6]=this.cb_case
this.Control[iCurrent+7]=this.cb_pending
this.Control[iCurrent+8]=this.cb_save
this.Control[iCurrent+9]=this.cb_error
this.Control[iCurrent+10]=this.cb_discard
this.Control[iCurrent+11]=this.st_status
this.Control[iCurrent+12]=this.cb_close
end on

on w_luw.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.st_emp)
destroy(this.dw_emp)
destroy(this.st_depts)
destroy(this.dw_depts)
destroy(this.cb_case)
destroy(this.cb_pending)
destroy(this.cb_save)
destroy(this.cb_error)
destroy(this.cb_discard)
destroy(this.st_status)
destroy(this.cb_close)
end on

type st_intro from statictext within w_luw
integer x = 37
integer y = 32
integer width = 2441
integer height = 216
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "The logical unit of work service (n_cst_luw) saves several DataWindows and DataStores in one transaction: it accepts the text, validates, updates each one and commits, or rolls back all of them if one fails.  Edit some employee names, change the department names (in a DataStore), then save both."
boolean focusrectangle = false
end type

type st_emp from statictext within w_luw
integer x = 37
integer y = 272
integer width = 1189
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Employees (a DataWindow; edit the names):"
boolean focusrectangle = false
end type

type dw_emp from u_dw within w_luw
integer x = 37
integer y = 344
integer width = 1189
integer height = 1000
integer taborder = 10
string dataobject = "d_empnamesupdateable"
end type

event constructor;call super::constructor;of_SetTransObject(sqlca)
end event

event pfc_retrieve;call super::pfc_retrieve;Return this.Retrieve()
end event

type st_depts from statictext within w_luw
integer x = 1289
integer y = 272
integer width = 1189
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Departments (a DataStore, shown here):"
boolean focusrectangle = false
end type

type dw_depts from u_dw within w_luw
integer x = 1289
integer y = 344
integer width = 1189
integer height = 580
integer taborder = 20
string dataobject = "d_depts"
boolean enabled = false
end type

type cb_case from u_cb within w_luw
integer x = 1289
integer y = 948
integer width = 1189
integer taborder = 30
string text = "Change the &Department Names in the DataStore"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// Switches the names between upper case and capitalized words, in the DataStore
n_cst_string	lnv_string
long	ll_row
string	ls_name

For ll_row = 1 To ids_depts.RowCount()
	ls_name = ids_depts.GetItemString(ll_row, "dept_name")
	If ls_name = Upper(ls_name) Then
		ids_depts.SetItem(ll_row, "dept_name", lnv_string.of_WordCap(ls_name))
	Else
		ids_depts.SetItem(ll_row, "dept_name", Upper(ls_name))
	End If
Next
st_status.Text = "The department names changed in the DataStore; they are not saved yet."
end event

type cb_pending from u_cb within w_luw
integer x = 1289
integer y = 1060
integer width = 1189
integer taborder = 40
string text = "Which Have &Changes?"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// of_UpdatesPending gives the objects that have changes to save
n_cst_luw	lnv_luw
powerobject	lpo_check[], lpo_pending[]
long	ll_count, ll_i
string	ls_names

dw_emp.AcceptText()
lpo_check[1] = dw_emp
lpo_check[2] = ids_depts

lnv_luw = Create n_cst_luw
ll_count = lnv_luw.of_UpdatesPending(lpo_check, lpo_pending)
Destroy lnv_luw

For ll_i = 1 To ll_count
	If lpo_pending[ll_i] = dw_emp Then
		ls_names += ", the employees (dw_emp)"
	Else
		ls_names += ", the departments (ids_depts)"
	End If
Next
If ll_count > 0 Then
	st_status.Text = "of_UpdatesPending: " + String(ll_count) + " to save" + ls_names
Else
	st_status.Text = "of_UpdatesPending: nothing to save"
End If
end event

type cb_save from u_cb within w_luw
integer x = 1289
integer y = 1172
integer width = 581
integer taborder = 50
string text = "&Save Both"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;Choose Case parent.of_Save()
	Case 1
		st_status.Text = "of_Save: the employees and the departments were saved, and committed."
	Case 0
		st_status.Text = "of_Save: nothing to save."
	Case Else
		st_status.Text = "of_Save failed; nothing was saved."
End Choose
end event

type cb_error from u_cb within w_luw
integer x = 1897
integer y = 1172
integer width = 581
integer taborder = 60
string text = "Save with an E&rror"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// Gives the second department the first one's key, so updating the departments
// fails after the employees are updated.  of_Save then rolls back the transaction:
// the employees' changes aren't saved either, and both still have their changes.
integer	li_rc
long		ll_dept

If ids_depts.RowCount() < 2 Then Return
ll_dept = ids_depts.GetItemNumber(2, "dept_id")
ids_depts.SetItem(2, "dept_id", ids_depts.GetItemNumber(1, "dept_id"))

li_rc = parent.of_Save()

// Put the key back, keeping the other changes
ids_depts.SetItem(2, "dept_id", ll_dept)
If li_rc < 0 Then
	st_status.Text = "of_Save returned " + String(li_rc) + ": the departments failed, so the transaction was rolled back, " + &
		"and the employees weren't saved either.  Their changes are still there to save."
Else
	st_status.Text = "of_Save returned " + String(li_rc) + "."
End If
end event

type cb_discard from u_cb within w_luw
integer x = 1289
integer y = 1284
integer width = 1189
integer taborder = 70
string text = "Discard the C&hanges"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.of_Retrieve()
st_status.Text = "The employees and the departments were read from the database again."
end event

type st_status from statictext within w_luw
integer x = 37
integer y = 1384
integer width = 2441
integer height = 180
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

type cb_close from u_cb within w_luw
integer x = 2103
integer y = 1644
integer taborder = 80
string text = "Close"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
