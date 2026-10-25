$PBExportHeader$w_treeviewrecursive6.srw
$PBExportComments$Example of a recursive TreeView level (n_cst_tvsrv_levelsource.of_SetRecursive): who reports to whom
forward
global type w_treeviewrecursive6 from w_main
end type
type st_intro from statictext within w_treeviewrecursive6
end type
type tv_1 from u_tvs within w_treeviewrecursive6
end type
type st_selected from statictext within w_treeviewrecursive6
end type
type cb_expand from u_cb within w_treeviewrecursive6
end type
type cb_close from u_cb within w_treeviewrecursive6
end type
end forward

global type w_treeviewrecursive6 from w_main
integer x = 594
integer y = 300
integer width = 2240
integer height = 1800
string title = "PFC Example - Recursive Tree View"
st_intro st_intro
tv_1 tv_1
st_selected st_selected
cb_expand cb_expand
cb_close cb_close
end type
global w_treeviewrecursive6 w_treeviewrecursive6

type variables
Protected:
// All the employees who report to someone else, retrieved once; the level source
// filters them for each manager
n_ds	ids_staff
end variables

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	Registers the two levels.  Level 1 has the employees who are their
//						own managers.  Level 2, under each employee, has the people whose
//						manager_id is that employee's emp_id: the level source service filters
//						a DataStore of all of them, retrieved once.  Level 2 is recursive, so
//						every level under it is defined the same way.
//
//////////////////////////////////////////////////////////////////////////////
tv_1.of_SetLevelSource(True)

// A SQL data source is retrieved again for each item, with the item's values as the
// retrieval arguments; this one has no arguments
tv_1.inv_levelsource.of_Register(1, "emp_name", "", sqlca, &
	"SELECT emp_id, manager_id, emp_fname + ' ' + emp_lname AS emp_name FROM employee WHERE manager_id = emp_id", "")
tv_1.inv_levelsource.of_SetPictureColumn(1, "1")

// A DataStore data source is filtered for each item: manager_id = the emp_id of the item
ids_staff = Create n_ds
ids_staff.DataObject = "d_employeemanagers"
ids_staff.of_SetTransObject(sqlca)
ids_staff.Retrieve()
tv_1.inv_levelsource.of_Register(2, "emp_name", ":parent.1.emp_id", ids_staff, "manager_id")
tv_1.inv_levelsource.of_SetPictureColumn(2, "2")
tv_1.inv_levelsource.of_SetRecursive(2, True)

tv_1.event pfc_populate(0)
tv_1.SelectItem(tv_1.FindItem(RootTreeItem!, 0))
end event

event close;call super::close;If IsValid(ids_staff) Then Destroy ids_staff
end event

on w_treeviewrecursive6.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.tv_1=create tv_1
this.st_selected=create st_selected
this.cb_expand=create cb_expand
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.tv_1
this.Control[iCurrent+3]=this.st_selected
this.Control[iCurrent+4]=this.cb_expand
this.Control[iCurrent+5]=this.cb_close
end on

on w_treeviewrecursive6.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.tv_1)
destroy(this.st_selected)
destroy(this.cb_expand)
destroy(this.cb_close)
end on

type st_intro from statictext within w_treeviewrecursive6
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
string text = "A recursive level (of_SetRecursive) repeats under each of its items, as deep as the data goes, as folders do in Windows Explorer.  Here the employees are shown under their managers: expand an employee to see the people who report to them."
boolean focusrectangle = false
end type

type tv_1 from u_tvs within w_treeviewrecursive6
integer x = 37
integer y = 228
integer width = 1189
integer height = 1300
integer taborder = 10
boolean linesatroot = true
string picturename[] = {"custom076!","custom050!"}
end type

event pfc_retrieve;call super::pfc_retrieve;// The retrieval arguments of the level under al_parent
any	la_args[20]
integer	li_level

If IsValid(inv_levelsource) Then
	li_level = of_GetNextLevel(al_parent)
	inv_levelsource.of_GetArgs(al_parent, li_level, la_args)
End If

Return of_Retrieve(al_parent, la_args, ads_data)
end event

event selectionchanged;call super::selectionchanged;// The selected employee, from the level's data source, and the manager above
treeviewitem	ltvi_item, ltvi_manager
n_ds	lds_source
long	ll_row, ll_manager
string	ls_text

If newhandle <= 0 Then Return
this.GetItem(newhandle, ltvi_item)
inv_levelsource.of_GetDataSource(ltvi_item.Level, lds_source)
If inv_levelsource.of_GetDataRow(newhandle, lds_source, ll_row) <> 1 Then Return

ls_text = lds_source.GetItemString(ll_row, "emp_name") + "~r~nEmployee " + String(lds_source.GetItemNumber(ll_row, "emp_id")) + &
	", level " + String(ltvi_item.Level) + " of the tree"
ll_manager = this.FindItem(ParentTreeItem!, newhandle)
If ll_manager > 0 Then
	this.GetItem(ll_manager, ltvi_manager)
	ls_text += "~r~nReports to " + String(ltvi_manager.Label)
Else
	ls_text += "~r~nIs their own manager, at the top of the tree"
End If
st_selected.Text = ls_text
end event

type st_selected from statictext within w_treeviewrecursive6
integer x = 1271
integer y = 228
integer width = 896
integer height = 300
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

type cb_expand from u_cb within w_treeviewrecursive6
integer x = 1271
integer y = 560
integer width = 466
integer taborder = 20
string text = "&Expand All"
end type

event clicked;call super::clicked;// Expanding an item retrieves the level under it, down to the employees
// nobody reports to
long	ll_root

ll_root = tv_1.FindItem(RootTreeItem!, 0)
Do While ll_root > 0
	tv_1.ExpandAll(ll_root)
	ll_root = tv_1.FindItem(NextTreeItem!, ll_root)
Loop
end event

type cb_close from u_cb within w_treeviewrecursive6
integer x = 1792
integer y = 1568
integer taborder = 30
string text = "Close"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
