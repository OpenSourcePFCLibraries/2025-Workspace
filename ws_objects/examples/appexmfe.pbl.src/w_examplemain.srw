$PBExportHeader$w_examplemain.srw
$PBExportComments$Sheet contains tree view listing the PFC examples.
forward
global type w_examplemain from w_frame
end type
type lv_1 from u_lvs within w_examplemain
end type
type st_1 from statictext within w_examplemain
end type
type st_2 from statictext within w_examplemain
end type
type tv_1 from u_tvs within w_examplemain
end type
type st_v1 from u_st_splitbar within w_examplemain
end type
end forward

global type w_examplemain from w_frame
integer x = 14
integer y = 4
integer width = 2587
integer height = 1552
string title = "PFC Examples Application"
string menuname = "m_examplemain"
boolean displaymenuasribbonbar = true
windowstate windowstate = maximized!
event ue_printtree ( )
event ue_statusbarclicked ( integer ai_xpos,  integer ai_ypos,  string as_name )
event ue_statusbarrbuttonup ( integer ai_xpos,  integer ai_ypos,  string as_name )
event type integer ue_notify ( string as_object,  string as_action )
lv_1 lv_1
st_1 st_1
st_2 st_2
tv_1 tv_1
st_v1 st_v1
end type
global w_examplemain w_examplemain

type variables
Public:
//integer              ii_exampleid
//integer              ii_rightclickedmode
//long                  il_selecteditemhandle
menu                im_debugservices
menu                im_sqlspyservices
menu                im_debuglogwindow
menu                im_sqlspywindow
menu                im_utilpref

n_cst_menu     inv_menu
n_cst_explorerattrib	inv_explorerattrib

Protected:
string	is_mrukey = "pfc examples"
string	is_mruexampleclassname // classname of the example opened by pfc_open
string	is_mruexampletitle	// title of the example opened
// The tree and list of examples, from the catalog files
n_cst_examplecatalog	inv_catalog
end variables

forward prototypes
public function integer of_openexample (window aw_window, n_cst_mruattrib anv_mruattrib)
public function integer of_layoutclient ()
public function integer of_setribbon (boolean ab_ribbon)
protected function integer of_controltop ()
protected subroutine of_movecontrols (integer ai_shift)
protected subroutine of_registercontrols ()
end prototypes

event ue_printtree;call super::ue_printtree;//////////////////////////////////////////////////////////////////////////////
//
//	Event:		ue_printtree
//
//	Arguments:	None
//
//	Returns:		None
//
//	Description:
//	Prints the tree view.
//
//////////////////////////////////////////////////////////////////////////////
//	
//	Revision History
//
//	Version
//	6.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License
 * 
 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

If IsValid(tv_1.inv_print) Then
	tv_1.inv_print.of_PrintTree()
End If
end event

event ue_statusbarclicked;choose case as_name
	case "debugsrv"
		im_debugservices.Event clicked()
	case "sqlspysrv"
		im_sqlspyservices.Event clicked()
	case "debuglogwin"
		im_debuglogwindow.Event clicked()
	case "sqlspywin"
		im_sqlspywindow.Event clicked()
end choose
end event

event ue_statusbarrbuttonup;integer	li_rc
integer	li_x
integer	li_y
m_utilityproperties	lm_popmenu

li_x = Pointerx()
li_y = Pointery()
lm_popmenu = create m_utilityproperties
if as_name = "debugsrv" or as_name = "sqlspysrv" &
	or as_name = "debuglogwin" or as_name = "sqlspywin" then
		lm_popmenu.m_table.PopMenu(li_x, li_y)
end if
end event

event ue_notify;//////////////////////////////////////////////////////////////////////////////
//
//	Event:		ue_notify
//
//	Arguments:	
//	as_object
//	as_action
//
//	Returns:		integer
//	SUCCESS = 1
//	ERROR = -1
//
//	Description:
//	Called by others to notify the mainwindow of events which affect it.
//////////////////////////////////////////////////////////////////////////////

string	ls_id
string	ls_bitmap

// Get the id.
ls_id = as_object

Choose Case ls_id
	Case 'debugsrv'		
		choose case as_action
			case "open"
				im_debugservices.text = "Stop Debug Services"
				ls_bitmap = 'dbsvc.bmp'
			case "close"
				im_debugservices.text = "Start Debug Services"

				ls_bitmap = 'dbsvcoff.bmp'		
		end choose

	Case 'sqlspysrv'
		choose case as_action
			case "open"
				im_sqlspyservices.text = "Stop SQL Spy Services"
				ls_bitmap = 'sspysvcs.bmp'
			case "close"
				im_sqlspyservices.text = "Start SQL Spy Services"
				ls_bitmap = 'sssvcoff.bmp'		
		end choose

	Case 'debuglogwin'
		choose case as_action
			case "open"
				im_debuglogwindow.text = "Close Debug Log Window"
				ls_bitmap = 'dblogwin.bmp'

			case "close"
				im_debuglogwindow.text = "Open Debug Log Window"
				ls_bitmap = 'dlgwnoff.bmp'
		end choose		
		
	Case 'sqlspywin'		
		choose case Lower(as_action)
			case "open"
				im_sqlspywindow.text = "Close SQL Spy Window"
				ls_bitmap = 'sspywin.bmp'		
			case "close"
				im_sqlspywindow.text = "Open SQL Spy Window"
				ls_bitmap = 'sswinoff.bmp'
		end choose
		
End Choose

If Len(ls_id) > 0 And Len(ls_bitmap) > 0 Then
	if IsValid(inv_statusbar) then
		inv_statusbar.of_Modify(ls_id, ls_bitmap)
	end if		
End If	

return 1
end event

public function integer of_openexample (window aw_window, n_cst_mruattrib anv_mruattrib);w_master			lw_window


OpenWithParm(lw_window, anv_mruattrib.is_menuitemkey, anv_mruattrib.is_classname)

Return 1
end function

public function integer of_layoutclient ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_LayoutClient
//
//	Access:			Public
//
//	Arguments:		None
//
//	Returns:			Integer
//						1
//
//	Description:	Keeps the MDI client area off the TreeView and ListView.  The examples
//						open as their own windows, never as sheets, so the client area is a
//						hidden strip of no height above the MicroHelp bar.  Without this, it
//						covers the controls of the frame (see "Sizing the client area" in
//						Application Techniques).
//
//////////////////////////////////////////////////////////////////////////////
If this.WindowState = Minimized! Then Return 0

mdi_1.Visible = False
mdi_1.Move(this.WorkSpaceX(), this.WorkSpaceY() + this.WorkSpaceHeight() - mdi_1.MicroHelpHeight)
mdi_1.Resize(this.WorkSpaceWidth(), 0)

Return 1
end function


public function integer of_setribbon (boolean ab_ribbon);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_SetRibbon
//
//	Access:			Public
//
//	Arguments:		ab_ribbon	True shows the menu as a ribbon, False as the menu bar
//									and toolbar
//
//	Returns:			Integer
//						1 if it changed, 0 if it was already so
//
//	Description:	Switches the ribbon on or off while the window is open: the tree and
//						list move below the ribbon, or up to the top, and are registered
//						with the resize service again at the window's current size.
//
//////////////////////////////////////////////////////////////////////////////
integer	li_top

If this.DisplayMenuAsRibbonBar = ab_ribbon Then Return 0

this.SetRedraw(False)
li_top = of_ControlTop()
inv_resize.of_UnRegister(tv_1)
inv_resize.of_UnRegister(lv_1)
inv_resize.of_UnRegister(st_1)
inv_resize.of_UnRegister(st_2)
inv_resize.of_UnRegister(st_v1)

this.DisplayMenuAsRibbonBar = ab_ribbon
of_MoveControls(of_ControlTop() - li_top)

inv_resize.of_SetOrigSize(this.WorkSpaceWidth(), this.WorkSpaceHeight())
of_RegisterControls()
this.SetRedraw(True)
Return 1
end function

protected function integer of_controltop ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_ControlTop
//
//	Access:			Protected
//
//	Returns:			Integer
//						Where the tree and list's captions start: below the ribbon, when
//						the menu is shown as one, otherwise where they were designed
//
//	Description:	The ribbon covers the top of the workspace.  It gets the font of the
//						tree and list, Segoe UI at 8 points: its own is much larger.
//
//////////////////////////////////////////////////////////////////////////////
If Not this.DisplayMenuAsRibbonBar Then Return 136

mdirbb_1.FaceName = "Segoe UI"
mdirbb_1.TextSize = -8
Return mdirbb_1.Y + mdirbb_1.Height + 8
end function

protected subroutine of_movecontrols (integer ai_shift);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_MoveControls
//
//	Access:			Protected
//
//	Arguments:		ai_shift	How far the controls move down (up when negative)
//
//	Description:	Moves the tree, the list, their captions and the split bar, and
//						makes the tree, list and split bar shorter (or taller) by as much,
//						so their bottoms stay where they are.
//
//////////////////////////////////////////////////////////////////////////////
If ai_shift = 0 Then Return

st_1.Y += ai_shift
st_2.Y += ai_shift
tv_1.Y += ai_shift
tv_1.Height -= ai_shift
lv_1.Y += ai_shift
lv_1.Height -= ai_shift
st_v1.Y += ai_shift
st_v1.Height -= ai_shift
end subroutine

protected subroutine of_registercontrols ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_RegisterControls
//
//	Access:			Protected
//
//	Description:	Registers the tree, the list, their captions and the split bar with
//						the resize service.
//
//////////////////////////////////////////////////////////////////////////////
inv_resize.of_Register(tv_1, 0, 0, 50, 100)
inv_resize.of_Register(lv_1, 50, 0, 50, 100)
inv_resize.of_Register(st_1, 50, 0, 50, 0)
inv_resize.of_Register(st_2, 0, 0, 50, 0)
inv_resize.of_Register(st_v1, 50, 0, 0, 100 )
end subroutine

on w_examplemain.create
int iCurrent
call super::create
if IsValid(this.MenuID) then destroy(this.MenuID)
if this.MenuName = "m_examplemain" then this.MenuID = create m_examplemain
this.lv_1=create lv_1
this.st_1=create st_1
this.st_2=create st_2
this.tv_1=create tv_1
this.st_v1=create st_v1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.lv_1
this.Control[iCurrent+2]=this.st_1
this.Control[iCurrent+3]=this.st_2
this.Control[iCurrent+4]=this.tv_1
this.Control[iCurrent+5]=this.st_v1
end on

on w_examplemain.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.lv_1)
destroy(this.st_1)
destroy(this.st_2)
destroy(this.tv_1)
destroy(this.st_v1)
end on

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:	open
//
//	Description:
//	Initialize the window and all of its controls.
//
//////////////////////////////////////////////////////////////////////////////
//	
//////////////////////////////////////////////////////////////////////////////

integer	li_rc
m_examplemain	lm_examplemenu

setpointer(hourglass!)

// Close query processing is not needed for this window.
ib_disableclosequery = true

// let the menu know what objects it needs
lm_examplemenu = this.menuid
lm_examplemenu.of_setwindow(this)
lm_examplemenu.of_setlistview(lv_1)
lm_examplemenu.of_settreeview(tv_1)
lm_examplemenu.of_GetListViewStyle()

// Initialize the utility menu references.
inv_menu.of_GetMenuReference(this.menuid, "m_debugservices", im_debugservices)
inv_menu.of_GetMenuReference(this.menuid, "m_sqlspyservices", im_sqlspyservices)
inv_menu.of_GetMenuReference(this.menuid, "m_sqlspy", im_sqlspywindow)
inv_menu.of_GetMenuReference(this.menuid, "m_debuglog", im_debuglogwindow)
inv_menu.of_GetMenuReference(this.menuid, "m_utilitypreferences", im_utilpref)

// Read the example catalog (exam.txt and examcat.txt)
if inv_catalog.of_Load() <> 1 then
	MessageBox(this.Title, "The example catalog (" + inv_catalog.EXAMPLES_FILE + " and " + &
		inv_catalog.CATEGORIES_FILE + ") couldn't be read.  They must be in the application's folder.", StopSign!)
	return
end if

// set up treeview datasource for level 1
li_rc = tv_1.inv_levelsource.of_Register(1, "category_name", "", inv_catalog.of_GetTreeSource(1), "")
// set the pictures for level 1 to a picture index on the control
tv_1.inv_levelsource.of_SetPictureColumn(1, "1")
tv_1.inv_levelsource.of_setselectedpicturecolumn(1, "1")

// set up treeview datasource for level 2
li_rc = tv_1.inv_levelsource.of_Register(2, "category_name", ":parent.1.category_id", inv_catalog.of_GetTreeSource(2), "category_parent_id")
// set the pictures for level 2 to a database column holding the control indexes
tv_1.inv_levelsource.of_setpicturecolumn(2, "picture_idx")
tv_1.inv_levelsource.of_setselectedpicturecolumn(2, "selected_picture_idx")

// set up treeview datasource for level 2
li_rc = tv_1.inv_levelsource.of_Register(3, "category_name", ":parent.1.category_id", inv_catalog.of_GetTreeSource(3), "category_parent_id")
// set the pictures for level 2 to a database column holding the control indexes
tv_1.inv_levelsource.of_setpicturecolumn(3, "picture_idx")
tv_1.inv_levelsource.of_setselectedpicturecolumn(3, "selected_picture_idx")
tv_1.inv_levelsource.of_setstatepicturecolumn(3, "state_picture_idx")
tv_1.inv_levelsource.of_setoverlaypicturecolumn(3, "overlay_picture_idx")
end event

event pfc_preopen;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  preopen
//
//	Description:
// Enable the status bar and register controls with the window's resize service
// prior to the opening of the window.
//
//////////////////////////////////////////////////////////////////////////////
//	
//////////////////////////////////////////////////////////////////////////////
// Register an id with MRU service.  All examples opened from this window will use this id
If isvalid(gnv_app.inv_mru) Then
	gnv_app.inv_mru.of_Register(is_mrukey)
End If

// Set the frame window with the application manager.
gnv_app.of_SetFrame(w_examplemain)
gnv_app.of_SetMicrohelp(true)

// Enable the Status Bar Services
of_SetStatusBar(true)
if IsValid(inv_statusbar) then
	inv_statusbar.of_SetBorderType(0)
	inv_statusbar.of_SetGapWidth(40)
	inv_statusbar.of_Register('debugsrv', 'bitmap', 'dbsvc.bmp', 80)
	inv_statusbar.of_Register('sqlspysrv', 'bitmap', 'sssvcoff.bmp', 80)
	inv_statusbar.of_Register('debuglogwin', 'bitmap', 'dlgwnoff.bmp', 80)
	inv_statusbar.of_Register('sqlspywin', 'bitmap', 'sswinoff.bmp', 80)
	if gnv_app.ienv_object.Win16 then
		inv_statusbar.of_SetGDI(true)
		inv_statusbar.of_SetUser(true)
	end if
	inv_statusbar.of_SetTimer(true)
	inv_statusbar.of_setbackgroundcolor(13421772)
end if

// The menu as a ribbon (RibbonView), unless RibbonBar=0 in the [Application] section of the
// INI file.  The ribbon covers the top of the workspace, so the controls move down below it,
// before they are registered with the resize service.
this.DisplayMenuAsRibbonBar = (ProfileString(gnv_app.of_GetAppIniFile(), "Application", "RibbonBar", "1") <> "0")
of_MoveControls(of_ControlTop() - st_v1.Y)

// Start the Resize Service.
of_SetResize(true)

// Set the minimum size of the window object.
inv_resize.of_SetMinSize(1477, 920)

// Register each control, specifying which style of behavior it should 
// follow when the window resizes.
of_RegisterControls()
end event

event pfc_postopen;call super::pfc_postopen;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  pfc_postopen
//
//	Arguments:  none
//
//	Returns:  none
//
//	Description:  Post Open functionality.
//
//////////////////////////////////////////////////////////////////////////////
//	
//////////////////////////////////////////////////////////////////////////////

integer	li_rc
long		ll_itemhandle, ll_leveltwoitemhandle

setpointer(hourglass!)

this.setredraw(false)

// Retrieve level one on the treeview.
li_rc = tv_1.event pfc_populate(0) 

// Populate the dual datasource for level one of the treeview.
ll_itemhandle = tv_1.inv_base.of_FindFirstItemLevel(1, 0)

// Populate level two of the treeview, and start the window with the first
// item on level two selected.
tv_1.SelectItem(ll_itemhandle)
tv_1.ExpandItem(ll_itemhandle)

this.SetRedraw(true)
end event

event pfc_open;w_master		lw_window
n_cst_mruattrib	lnv_mruattrib

SetPointer(hourglass!)

// see if the powerobject is what we are expecting
If IsValid(message.powerobjectparm) Then
	if lnv_mruattrib.classname() = message.powerobjectparm.classname() Then
		lnv_mruattrib = message.powerobjectparm
	Else
		Return
	End If
Else
	Return
End IF

// set up some mru information
is_mruexampleclassname = lnv_mruattrib.is_classname
is_mruexampletitle = lnv_mruattrib.is_menuitemname
this.event pfc_mrusave()

// open the selected window
OpenWithParm(lw_window, lnv_mruattrib.is_menuitemkey, lnv_mruattrib.is_classname)
end event

event pfc_mrurestore;call super::pfc_mrurestore;//////////////////////////////////////////////////////////////////////////////
//
//	Event:		pfc_mrurestore
//
//	Arguments:	none
//
//	Returns:		integer
//	SUCCESS = 1
//	ERROR = -1
//
//	Description:
//	Allow MRU service to restore settings
//
//////////////////////////////////////////////////////////////////////////////
//	
//////////////////////////////////////////////////////////////////////////////

// Allow MRU service to restore settings if necessary
If IsValid(gnv_app.inv_mru) Then
	Return gnv_app.inv_mru.of_Restore( is_mrukey , This ) 
End If

Return -1
end event

event pfc_premrusave;call super::pfc_premrusave;//////////////////////////////////////////////////////////////////////////////
// 
//	Event:		pfc_premrusave
//
//	Arguments:
//	anv_mruattrib	The MRU attrib object, passed by reference.
//
//	Returns:		integer
//	SUCCESS = 1
//	ERROR = -1
//
//	Description:
//	Initialize the passed in attribute object.  
//
//////////////////////////////////////////////////////////////////////////////
//	
//	Revision History
//
//	Version
//	6.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License
 * 
 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

string ls_classname
string ls_title

ls_classname = is_mruexampleclassname
ls_title = is_mruexampletitle

// Be sure that none of these values is set to an empty string.
if ls_classname = "" or ls_title = "" then
	return -1
else
	anv_mruattrib.is_id = is_mrukey
	anv_mruattrib.is_classname = ls_classname
	anv_mruattrib.is_menuitemname = ls_title
	anv_mruattrib.is_menuitemkey = ls_classname
	anv_mruattrib.is_menuitemmhelp = "Opens " + ls_title
end if

return 1
end event

event pfc_mruprocess;call super::pfc_mruprocess;//////////////////////////////////////////////////////////////////////////////
// 
//	Event:		pfc_mruprocess
//
//	Arguments:
//	ai_row	row in datastore that we need to pull information from
//
//	Returns:		integer
//	SUCCESS = 1
//	ERROR = -1
//
//	Description:
//	Perform the process needed when a user clicks on an MRU item in the menu.  
// The developer will have to extend/override this event depending on what is needed
// by the application.  
//
//////////////////////////////////////////////////////////////////////////////
//	
//////////////////////////////////////////////////////////////////////////////

n_cst_mruattrib	lnv_mruattrib

// check parameters
if IsNull(ai_row) or (ai_row < 1) then
	return -1
end if

if not IsValid(gnv_app.inv_mru) or IsNull(gnv_app.inv_mru) then
	return -1
end if

// Retrieve row from datastore.
gnv_app.inv_mru.of_GetItem(ai_row, lnv_mruattrib)

// SDI Process - open the selected MRU item
message.powerobjectparm = lnv_mruattrib
this.event pfc_open()

return 1
end event

event pfc_help;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  pfc_help
//
//	Arguments:  none
//
//	Returns:  integer
//	 1 = success
//	 0 = helpfile property of the application manager not specified
//	-1 = error
//
//	Description:
//	Show the help topic of the example or the category selected in the
//	tree, or the start of the help file.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	5.0   Initial version
//	2025	The ancestor shows the help file (a PDF file) with the help service
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License
 * 
 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

long		ll_handle, ll_row
any		la_none
treeviewitem	ltvi_item
n_ds		lds_source

// The topic of the example or the category selected in the tree (the example's is in the
// catalog; a category's is 100 + its category_id), or else the contents
ia_helptypeid = la_none
ll_handle = tv_1.FindItem(CurrentTreeItem!, 0)
If ll_handle > 0 And IsValid(tv_1.inv_levelsource) Then
	tv_1.GetItem(ll_handle, ltvi_item)
	If tv_1.inv_levelsource.of_GetDataRow(ll_handle, lds_source, ll_row) = 1 Then
		Choose Case ltvi_item.Level
			Case 2
				ia_helptypeid = 100 + lds_source.GetItemNumber(ll_row, "category_id")
			Case 3
				ia_helptypeid = inv_catalog.of_GetHelpContext(lds_source.GetItemNumber(ll_row, "example_id"))
		End Choose
	End If
End If
If ClassName(ia_helptypeid) = "long" Then
	If ia_helptypeid = 0 Then ia_helptypeid = la_none
End If

// The help service shows the topic (in pfcexamp.pdf, the named destination topic_<number>)
Return Super::Event pfc_help()
end event

type lv_1 from u_lvs within w_examplemain
event type integer ue_selectionchange ( n_cst_explorerattrib anv_explorerattrib )
integer x = 1280
integer y = 232
integer width = 1211
integer height = 968
integer taborder = 10
long backcolor = 1090519039
boolean autoarrange = true
string largepicturename[] = {"images\cat_root.svg","images\folder.svg","images\folder.svg","images\folder_open.svg","images\example.svg","images\run_example.svg","images\run_example.svg"}
string smallpicturename[] = {"images\cat_root.svg","images\folder.svg","images\folder.svg","images\folder_open.svg","images\example.svg","images\run_example.svg","images\run_example.svg"}
string statepicturename[] = {"images\example_new.svg","images\example_enhanced.svg"}
long statepicturemaskcolor = 16777215
string facename = "Segoe UI"
end type

event ue_selectionchange;call super::ue_selectionchange;//////////////////////////////////////////////////////////////////////////////
//
//	Event: 		ue_SelectionChange
//
//	Argument:	
//	anv_explorerattrib	Attribute object containing properties about what selection
//									is changing
//
//	Returns:		Integer
//  1 = success
// -1 = error
//
//	Description:	Receives notice that a selection is changing on the object this
//						control is associated with.  Process information accordingly
//
//////////////////////////////////////////////////////////////////////////////

// set internal attributes to be used in other places scripts/functions
inv_explorerattrib = anv_explorerattrib

// Delete all columns from the list view control.  This is done for the "detail" view.
inv_datasource.of_UnRegisterReportColumn()

this.event pfc_populate()

SetMicrohelp(String( this.totalitems() ) + " Object(s).")

Return 1
end event

event doubleclicked;//////////////////////////////////////////////////////////////////////////////
//
//	Event:
//	doubleclicked
//
//	Description:
//	Scrolls to the selected item's corresponding treeviewitem, or launches an
// example.
//
//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////

integer		 	li_level
long			 	ll_currenttvitem, ll_lvrow, ll_selectedtreehandle
string			ls_lvlabel, ls_windowname
listviewitem 	llvi_selectedlvitem
treeviewitem 	ltvi_newtreeitem, ltvi_startingtreeitem
n_ds			 	lds_lvdatastore
n_cst_mruattrib	lnv_mruattrib

// A double-click on the list's background, not on an item, does nothing
If index < 1 Then Return

// Get the listview item that was doubleclicked.
this.GetItem(index, llvi_selectedlvitem)
ls_lvlabel = llvi_selectedlvitem.label

// Determine which treeview item is currently selected and get it
ll_currenttvitem = tv_1.FindItem(currenttreeitem!, 0)
tv_1.GetItem(ll_currenttvitem, ltvi_startingtreeitem)

// Set a local variable to the level of the currently selected treeview item.
li_level = ltvi_startingtreeitem.level

// Determine if a runtime example was selected from the listview. 
// These will only be launching from level 3 of the tree
If li_level = 3 Then
	this.inv_datasource.of_GetDataRow(index, lds_lvdatastore, ll_lvrow)
	If ll_lvrow > 0 Then
		lnv_mruattrib.is_classname = lds_lvdatastore.GetItemString(ll_lvrow, "window")
		lnv_mruattrib.is_menuitemname = lds_lvdatastore.GetItemString(ll_lvrow, "title")
		lnv_mruattrib.is_menuitemkey = ""
		message.powerobjectparm = lnv_mruattrib
		parent.event pfc_open()
		return
	Else
		Messagebox("Database Error", "Cannot find the selected row for example.", stopsign!)
		Return
	End If
End If
	
// If the double clicked item was not a runtime example item...

// Determine if the currently selected treeview item has been expanded.  
// If it hasn't, expand it. (expanding also populates)
// This loads the treeview with the listview information
if ltvi_startingtreeitem.expanded = false then
	tv_1.ExpandItem(ll_currenttvitem)
end if

// Get the handle of the treeview item that corresponds to the list view item that was doubleclicked.
ll_selectedtreehandle = tv_1.inv_base.of_FindItem("label", ls_lvlabel, ll_currenttvitem,&
	(li_level + 1), true, true)

// Get the state information of the treeview item that corresponds to the list view item that was doubleclicked.
tv_1.GetItem(ll_selectedtreehandle, ltvi_newtreeitem)

// Select and Expand the selected treeview item.
if ltvi_newtreeitem.expanded = false then
	tv_1.SelectItem(ll_selectedtreehandle)
	tv_1.ExpandItem(ll_selectedtreehandle)
end if
end event

event rbuttonup;call super::rbuttonup;//////////////////////////////////////////////////////////////////////////////
//
//	Event:
//	rbuttonup
//
//	Description:
//	Scrolls to the selected item's corresponding treeviewitem, or launches an
// example.
//
//////////////////////////////////////////////////////////////////////////////
//	
//////////////////////////////////////////////////////////////////////////////
//m_examplemain	lm_menu
//
//lm_menu = parent.menuid
//lm_menu.of_SetListViewStyle(this)
end event

event constructor;//////////////////////////////////////////////////////////////////////////////
//
//	Event:	Constructor
//
//	Description:	Turn on the listview services
//
//////////////////////////////////////////////////////////////////////////////
//	
//////////////////////////////////////////////////////////////////////////////
integer	li_index

of_setbase(true)
of_setdatasource(true)
of_setsort(true)

// set the picturemask color to white because that is the background color of the bmp
this.statepicturemaskcolor = RGB(255, 255, 255) //White!
li_index = this.addstatepicture("images\example_new.svg")
end event

event pfc_populate;//////////////////////////////////////////////////////////////////////////////
//
//	Event:		pfc_populate
//
//	Arguments:	none
//
//	Returns:		Long
//			 # of items added to the listview
//			-1 = error
//
//	Description:
//	retrieves the datasource and uses it to load the listview with data
//
//////////////////////////////////////////////////////////////////////////////
//	
//	override ancestor script
//
//////////////////////////////////////////////////////////////////////////////
integer	li_rc
long		ll_level, ll_row, ll_key
string	ls_label
n_ds		lds_data

Setpointer(hourglass!)

// Set the listview source based on the treeview level information
ll_level = inv_explorerattrib.itvi_selecteditem.Level
ls_label = inv_explorerattrib.itvi_selecteditem.Label
ll_row = inv_explorerattrib.il_datastorerow
if ll_level = 3 then
	ll_key = inv_explorerattrib.ids_datastore.GetItemNumber(ll_row, "example_id")
else
	ll_key = inv_explorerattrib.ids_datastore.GetItemNumber(ll_row, "category_id")
end if

choose case ll_level
	case 1
		inv_datasource.of_Register("category_name", inv_catalog.of_GetListSource(ll_level, ll_key))
		inv_datasource.of_SetPictureColumn("picture_idx")
		inv_datasource.of_SetStatePictureColumn("overlay_picture_idx")
//		inv_datasource.of_SetOverlayPictureColumn("overlay_picture_idx")
	case 2
		inv_datasource.of_Register("category_name", inv_catalog.of_GetListSource(ll_level, ll_key))
		inv_datasource.of_SetPictureColumn("picture_idx")
		inv_datasource.of_SetStatePictureColumn("overlay_picture_idx")
//		inv_datasource.of_SetOverlayPictureColumn("overlay_picture_idx")
	case 3
		inv_datasource.of_Register("example", inv_catalog.of_GetListSource(ll_level, ll_key))
		inv_datasource.of_SetPictureColumn("7")
		inv_datasource.of_SetStatePictureColumn("overlay_picture_idx")
//		inv_datasource.of_SetOverlayPictureColumn("overlay_picture_idx")
end choose

// clear the listview
If this.DeleteItems() < 1 Then Return -1

// retrieve the data into the services datastore
If this.event pfc_retrieve(lds_data) < 0 Then Return -1

// add the retrieved rows to the listview
Return this.event pfc_addall(lds_data) 
end event

event pfc_retrieve;//////////////////////////////////////////////////////////////////////////////
//
//	Event:		pfc_Retrieve
//
//	Arguments:	
//	ads_data		The datastore holding the rows to add to the treeview as items
//
//	Returns:		long
//			 number of items returned by the retrieve
//			-1 = error
//
//	Description:
//	Return the number of rows placed in the data source
//
//	The data source is a DataStore from the example catalog, which already has the rows
//	(see pfc_populate), so there are no retrieval arguments.
//
//////////////////////////////////////////////////////////////////////////////
//
//	override ancestor script
//
//////////////////////////////////////////////////////////////////////////////
any					la_args[20]

Return of_retrieve(la_args, ads_data)
end event

type st_1 from statictext within w_examplemain
integer x = 1280
integer y = 140
integer width = 1211
integer height = 76
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 77633680
string text = "Contents of "
boolean border = true
borderstyle borderstyle = stylelowered!
boolean focusrectangle = false
end type

type st_2 from statictext within w_examplemain
integer x = 37
integer y = 140
integer width = 1211
integer height = 72
boolean bringtotop = true
integer textsize = -8
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 77633680
string text = "All Folders"
boolean border = true
borderstyle borderstyle = stylelowered!
boolean focusrectangle = false
end type

type tv_1 from u_tvs within w_examplemain
event type integer ue_selectionchange ( long al_oldhandle,  long al_newhandle )
integer x = 37
integer y = 232
integer width = 1211
integer height = 968
integer taborder = 20
long backcolor = 1090519039
boolean linesatroot = true
boolean hideselection = false
string picturename[] = {"images\cat_root.svg","images\folder.svg","images\folder.svg","images\folder_open.svg","images\example.svg","images\run_example.svg"}
string facename = "Segoe UI"
end type

event ue_selectionchange;call super::ue_selectionchange;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  ue_SelectionChange
//
//	Arguments:	
//	al_oldhandle	The handle of the item which was previously selected
//	al_newhandle	The handle of the item which is now selected
//
//	Returns:		Integer
//					 1 = success
//					 0 = no action
//					-1 = failure
//
//	Description:	Pass the selectionchanging event information to the associated
//						object so it knows selection is changing and what is happening

//
//////////////////////////////////////////////////////////////////////////////
//	
//////////////////////////////////////////////////////////////////////////////
Integer			li_rc
long				ll_row
treeviewitem	ltvi_selecteditem
n_ds				lds_datastore
n_cst_explorerattrib	lnv_explorerattrib

// Check Arguments
If (al_oldhandle < 0) or IsNull(al_oldhandle) Then Return -1
If (al_newhandle < 0) or IsNull(al_newhandle) then Return -1

//Get the state information for the selected treeview item.
If this.GetItem(al_newhandle, ltvi_selecteditem) < 1 Then Return -1

// get current datastore and row
If isvalid(inv_levelsource) then
	If inv_levelsource.of_GetDataRow(al_newhandle, lds_datastore, ll_row) < 1 Then Return -1
	If IsNull(ll_row) or IsNull(lds_datastore) or ll_row < 0 Then Return -1
	
	// populate the attribute object
	lnv_explorerattrib.itvi_selecteditem = ltvi_selecteditem
	lnv_explorerattrib.ids_datastore = lds_datastore
	lnv_explorerattrib.il_datastorerow = ll_row
	lnv_explorerattrib.il_selectedhandle = al_newhandle
Else
	Return -1
End If

// call the associated objects event
Return lv_1.event ue_selectionchange(lnv_explorerattrib)
end event

event selectionchanging;call super::selectionchanging;///////////////////////////////////////////////////////////////////////////////////////////
//
//	Event:  selectionchanging
//
//	Arguments:
//	oldhandle   the handle of the item that was selected until the selection was changed.
// newhandle	the handle of the item that is currently selected, now that the selection has changed.
//
//	Returns:  integer
//	 1 = success
//	-1 = error
//
//	Description:
//	This event populates the list view, then triggers the ItemPopulate event on the Treeview.
//
//////////////////////////////////////////////////////////////////////////////
//	
//////////////////////////////////////////////////////////////////////////////

treeviewitem 	ltvi_selecteditem

// Get the state information for the selected treeview item.
GetItem(newhandle, ltvi_selecteditem)

if ltvi_selecteditem.label <> "" then
	st_1.text = "Contents of " + "'" + ltvi_selecteditem.label + "'"
	parent.title = "PFC Code Examples Application - " + ltvi_selecteditem.label
end if
end event

event constructor;//////////////////////////////////////////////////////////////////////////////
//
//	Event:
//	constructor
//
//	Description:
//	Sets the overlay picture indexes to the overlay picture array.
//
//////////////////////////////////////////////////////////////////////////////
//	
//////////////////////////////////////////////////////////////////////////////
integer		li_index

of_setbase(true)
of_setprint(true)
of_setlevelsource(true)

// set the picturemask color to white because that is the background color of the bmp
this.picturemaskcolor = RGB(255, 255, 255) //White!
li_index = this.addpicture("images\example_new.svg")

// add the picture index to the first overplay picture array location
this.SetOverlayPicture(1, li_index)
end event

event pfc_populate;//////////////////////////////////////////////////////////////////////////////
//
//	Event:		pfc_Populate
//
//	Arguments:	
//	al_parent	The handle to the Treeview item to place retrieved data under
//
//	Returns:		Long
//			 # of items treeview was populated with
//			 0 if nothing was populated
//			-1 = error
//
//	Description:
//	retrieves the datasource and uses it to load the treeview with data
//
//////////////////////////////////////////////////////////////////////////////
//	
//	overriding ancestor script
//
//////////////////////////////////////////////////////////////////////////////
treeviewitem		ltvi_selecteditem
n_ds					lds_data

// check arguments
IF (al_parent < 0) or IsNull(al_parent) then Return -1

Setpointer(hourglass!)

if this.GetItem(al_parent, ltvi_selecteditem) <> 1 then 
	// if first time populating we want to continue to populate

	If al_parent <> 0 Then
		return -1
	End If
End If

// This tree view has 3 levels.  We do not need to populate the 
// level 2 children in the tree view.  (We will put level 3 in the list view however.)
if ltvi_selecteditem.level > 2 then
	return 0
end if

// retrieve the data into the services datastore
IF this.event pfc_retrieve(al_parent, lds_data) < 0 Then Return -1

// add the treeview data
Return this.event pfc_AddAll(al_parent, lds_data) 
end event

event pfc_retrieve;call super::pfc_retrieve;//////////////////////////////////////////////////////////////////////////////
//
//	Event:		pfc_Retrieve
//
//	Arguments:	
//	al_parent	The handle to the Treeview item to place retrieved data under
//	ads_data		The datastore holding the rows to add to the treeview as items
//						passed by reference
//
//	Returns:		long
//			 number of items returned by the retrieve
//			-1 = error
//
//	Description:
//	Return the number of rows placed in the data source.
//
//////////////////////////////////////////////////////////////////////////////
Any				la_args[20]
Integer			li_nextlevel

// Check Arguments
If (al_parent < 0) or IsNull(al_parent) Then Return -1

li_nextlevel = of_GetNextLevel(al_parent)
If li_nextlevel < 1 then Return -1

If isvalid(inv_levelsource) then
	// if populating the first level (parent = 0), retrieval arguments will not be returned
	// Extend the event to populate arguments for level 1
	inv_levelsource.of_getargs(al_Parent, li_nextLevel, la_Args)
End If

// The level source service filters the catalog's rows on the parent's category_id;
// the catalog already has only the examples for this platform (see the open event).

// retrieve the rows into the datasource
Return of_retrieve(al_parent, la_args, ads_data)
end event

event selectionchanged;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  SelectionChanged
//
//	Description:	Occurs when a treeview item is clicked and has changed.
//						Notify associated object that the selection has changed
//
//////////////////////////////////////////////////////////////////////////////
//	
//////////////////////////////////////////////////////////////////////////////

// call the event to notify associated object selection is changing
this.event ue_selectionchange(oldhandle, newhandle)
end event

type st_v1 from u_st_splitbar within w_examplemain
integer x = 1248
integer y = 136
integer width = 27
integer height = 1060
end type

event constructor;call super::constructor;//////////////////////////////////////////////////////////////////////////////
//
//	Event:
//	constructor
//
//	Description:
// Initialize the splitbar and register surrounding window controls.
//
//////////////////////////////////////////////////////////////////////////////
//	
//	Revision History
//
//	Version
//	6.0   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License
 * 
 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c) 
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

of_Register(tv_1, LEFT)
of_Register(lv_1, RIGHT)
of_Register(st_2, LEFT)
of_Register(st_1, RIGHT)
end event

