$PBExportHeader$pfcscanner_n_cst_securityscanner.sru
$PBExportComments$PFC Security Scanner service
forward
global type pfcscanner_n_cst_securityscanner from nonvisualobject
end type
end forward

global type pfcscanner_n_cst_securityscanner from nonvisualobject
end type
global pfcscanner_n_cst_securityscanner pfcscanner_n_cst_securityscanner

type variables
pfcscanner_n_ds 				ids_info
pfcscanner_n_ds 				ids_apps
pfcscanner_n_ds 				ids_updates
pfcscanner_n_cst_string 	inv_string
pfcscanner_n_cst_sourcelibrary	inv_source
boolean							ib_ownsource
string 							is_app
string 							is_keyword = 'microhelp'
string 							is_separator = ';'
boolean 							ib_initscanning = false
transaction						itr_trans
end variables

forward prototypes
public function integer of_scandatawindow (string as_dataobjectname, string as_library)
public function integer of_initscanprocess (transaction a_trans, string as_app, string as_lib_list[])
public function integer of_initscanprocess (transaction a_trans, string as_app, pfcscanner_n_cst_sourcelibrary anv_source)
protected function string of_getdesc (string as_text, string as_tag)
protected function string of_getmenudesc (string as_text)
protected function string of_gettag (string as_tag)
protected function integer of_scandataobject (string as_dataobject, string as_dwname, string as_object)
protected function integer of_setsyntax (string as_dataobject, datastore ads_datastore)
public function integer of_update ()
protected function integer of_addobject (string as_app, string as_winname, string as_object, string as_objecttype, string as_desc)
protected function long of_scancontrols (string as_object, pfcscanner_n_cst_classinfo anv_class, string as_within, string as_prefix, boolean ab_menu)
public function integer of_scanobject (string as_object, string as_library)
end prototypes

public function integer of_scandatawindow (string as_dataobjectname, string as_library);//////////////////////////////////////////////////////////////////////////////
//	Function: 		of_ScanDatawindow
//	Description:  	Scans the datawindow object and captures the information about each column
//						called from the scan window for an individual dw selection
//////////////////////////////////////////////////////////////////////////////
// get known columns
If ids_updates.Retrieve ( is_app, as_dataobjectname )   < 0 Then Return -2

Return of_ScanDataObject ( as_dataobjectname, as_dataobjectname, "" ) 
end function

public function integer of_initscanprocess (transaction a_trans, string as_app, string as_lib_list[]);//////////////////////////////////////////////////////////////////////////////
//	Function:  		of_InitScanProcess
//	Description:  	Initialize the database connection, application and library
//               		search path. Used when scanning applications
//						as_lib_list: folders of object source or .pbl files (see
//						pfcscanner_n_cst_sourcelibrary.of_SetLibraries)
//////////////////////////////////////////////////////////////////////////////
pfcscanner_n_cst_sourcelibrary	lnv_source

lnv_source = Create pfcscanner_n_cst_sourcelibrary
If lnv_source.of_SetLibraries ( as_lib_list ) < 0 Then
	Destroy lnv_source
	Return -1
End If

If of_InitScanProcess ( a_trans, as_app, lnv_source ) < 0 Then
	Destroy lnv_source
	Return -1
End If
ib_ownsource = True

Return 1
end function

public function integer of_initscanprocess (transaction a_trans, string as_app, pfcscanner_n_cst_sourcelibrary anv_source);//////////////////////////////////////////////////////////////////////////////
//	Function:  		of_InitScanProcess
//	Description:  	Initialize the database connection, application and the
//						libraries' objects (anv_source, which the caller keeps).
//						Used when scanning applications
//////////////////////////////////////////////////////////////////////////////
SetPointer ( HourGlass! )

If Not IsValid ( anv_source ) Then Return -1
If a_trans.dbHandle ( ) = 0 Then Return -1

ids_updates.DataObject = "d_pfcsecurity_templateupdate"
ids_apps.DataObject = "d_pfcsecurity_applookup"

ids_updates.SetTransObject ( a_trans )
ids_apps.SetTransObject ( a_trans )

is_app = Lower ( as_app )
If ib_ownsource And IsValid ( inv_source ) Then Destroy inv_source
inv_source = anv_source
ib_ownsource = False
If ids_apps.Retrieve ( is_app )  = 0 Then // if the application does not exist in the database, add it
	ids_apps.ImportString ( is_app + "~t" + is_app )
End If

ib_initscanning = True
itr_trans = a_trans

Return 1
end function

protected function string of_getdesc (string as_text, string as_tag);//////////////////////////////////////////////////////////////////////////////
//	Function:	of_GetDesc
//	Description:  Return additional information about an object.
//				     Look for attributes in the following order
//				     1. Text, if there is no text attribute or it is empty then look for
//				     2. Tag
//////////////////////////////////////////////////////////////////////////////
If Trim ( as_text ) <> "" Then Return as_text
If as_tag <> "" Then Return of_GetTag ( as_tag )
Return ""
end function

protected function string of_getmenudesc (string as_text);//////////////////////////////////////////////////////////////////////////////
//	Function:				of_GetMenuDesc
//	Description:  		Return a menu item's text without its accelerator (&) and
//							its shortcut (after a tab): &Open~tCtrl+O is Open.
//							&& is an ampersand.
//////////////////////////////////////////////////////////////////////////////
long ll_pos

ll_pos = Pos ( as_text, "~t" )
If ll_pos > 0 Then as_text = Left ( as_text, ll_pos - 1 )

as_text = inv_string.of_GlobalReplace ( as_text, "&&", "~~a" )
as_text = inv_string.of_GlobalReplace ( as_text, "&", "" )
as_text = inv_string.of_GlobalReplace ( as_text, "~~a", "&" )

Return Trim ( as_text )
end function

protected function string of_gettag (string as_tag);//////////////////////////////////////////////////////////////////////////////
//	Function:				of_GetTag
//	Description: 		Parses the passed string. If the string is empty it returns an empty string
//							if the string contains a keyword that matches what is in ics_keyword 
//							(default is 'microhelp', default separator is ';') then the value for the keyword is returned
//							if none of the aboove is true then the original string is returned
//////////////////////////////////////////////////////////////////////////////
string ls_value

SetPointer ( HourGlass! )

// check arguments
If as_tag = "" Then Return ""

ls_value = inv_string.of_GetKeyValue ( as_tag, is_keyword, is_separator ) 
If ls_value = "" Then ls_value = as_tag

Return ls_value
end function

protected function integer of_scandataobject (string as_dataobject, string as_dwname, string as_object);//////////////////////////////////////////////////////////////////////////////
//	Function:				of_ScanDataObject
//	Description:  		Scans the datawindow object and captures the information about each column
//////////////////////////////////////////////////////////////////////////////
string ls_dwname, ls_query, ls_token, ls_ans, ls_name
int li_colcnt=0, li_posi

SetPointer ( HourGlass! )

ls_dwname = as_object 
If Len ( as_object )  > 0 Then ls_dwname += "."

If of_SetSyntax ( as_dwname, ids_info )  < 0 Then Return -1

ls_query = ids_info.Describe ( "Datawindow.Objects" ) 
ls_query = Lower ( ls_query ) 

// strip apart the tab seperated string
Do While Len ( ls_query )  > 0  
	li_posi = Pos ( ls_query, "~t" ) 
	If li_posi = 0 Then 
		// no more tabs so take what's left of the string
		li_posi = Len ( ls_query ) 
	Else
		li_posi = li_posi - 1
	End If
	
	ls_token = Left ( ls_query, li_posi )  // grab off the token
	ls_query = Mid ( ls_query, li_posi + 2 )  // skip past the tab 
	If Len ( ls_token )  > 0 Then 
		ls_ans = ids_info.Describe ( ls_token + ".Type " ) 
		ls_ans = Lower ( ls_ans ) 
		If Pos ( ls_ans, "column" )  > 0 Then // is it a column?
			ls_name = ls_dwname + ls_token
			If Not IsNull ( ls_name )  And Len ( Trim ( ls_name ) )  > 0 Then 
				// get the descriptive info
				ls_ans =ids_info.Describe ( ls_token + ".dbName " )  + " : " + &
					ids_info.Describe ( ls_token + ".ColType" )  
					of_addobject ( is_app, as_dataobject, ls_name, "Column", ls_ans )   
				li_colcnt++
			End If
		End If
	End If
Loop

Return li_colcnt
end function

protected function integer of_setsyntax (string as_dataobject, datastore ads_datastore);//////////////////////////////////////////////////////////////////////////////
//	Function:  		of_setsyntax
//	Description:  	Create the syntax in as_dataobject and place it in ads_datastore.
//						The syntax is the DataWindow object's source, from its
//						source file or exported from its library
//////////////////////////////////////////////////////////////////////////////
string ls_syntax, ls_errors

SetPointer ( HourGlass! )

If IsNull ( as_dataobject ) Then Return -1
If Len ( trim ( as_dataobject ) ) = 0 Then Return -1
If IsNull ( ads_datastore )  Then Return -1
If Not IsValid ( ads_datastore )  Then Return -1
If Not IsValid ( inv_source ) Then Return -1

ls_syntax = inv_source.of_GetSyntax ( as_dataobject )
If Len ( ls_syntax )  = 0 Then Return -1

ads_datastore.Create ( ls_syntax, ls_errors )
If Len ( ls_errors )  > 0 Then Return -1

Return 1
end function

public function integer of_update ();//////////////////////////////////////////////////////////////////////////////
//	Function:	of_update
//	Description:  Save the changes. Delete rows that belong to controls that no longer exist
//////////////////////////////////////////////////////////////////////////////
integer 	li_rc
long 		ll_rowcnt, ll_modcount

SetPointer ( HourGlass! )

li_rc = ids_apps.Update ( True, False ) 
If li_rc >= 0 Then 
	li_rc = ids_updates.Update ( True, False ) 
End If

If li_rc < 1 Then
	RollBack Using itr_trans;
	If itr_trans.sqlcode <> 0 Then Return -2
	Return -1
Else
	Commit Using itr_trans;
	If itr_trans.SQLCode <> 0 Then Return -2
	ids_apps.ResetUpdate ( )
	ids_updates.ResetUpdate ( )
	Return 1
End If
end function

protected function integer of_addobject (string as_app, string as_winname, string as_object, string as_objecttype, string as_desc);//////////////////////////////////////////////////////////////////////////////
//	Function:	of_addobject
//////////////////////////////////////////////////////////////////////////////
integer li_rc
long ll_row
string ls_importstring

SetPointer ( HourGlass! )

// remove potential CRLF pairs
as_desc = Left ( inv_string.of_RemoveNonPrint ( as_desc ), 254 )

ll_row = ids_updates.Find ( "application='" + as_app + "' and window = '" + as_winname + "' and control = '" + &
								   as_object + "'", 1, ids_updates.RowCount ( ) ) 
									
If ll_row > 0 Then 
	ids_updates.object.object_type.Current[ll_row] = as_objecttype
	ids_updates.object.description.Current[ll_row] = as_desc
Else
	ls_importstring = as_app + "~t" + as_winname + "~t" + as_object + "~t" + as_objecttype + "~t" + as_desc
	li_rc = ids_updates.ImportString ( ls_importstring )  
	If li_rc < 0 Then
		MessageBox ( "Security Scanner","Error on importstring. Error code = " + String ( li_rc ) + ". Attempted to import the following string ~r~n" + ls_importstring ) 
	End If
End If

Return li_rc
end function

protected function long of_scancontrols (string as_object, pfcscanner_n_cst_classinfo anv_class, string as_within, string as_prefix, boolean ab_menu);//////////////////////////////////////////////////////////////////////////////
//	Function:			of_ScanControls
//	Description:  	Recursively scan the controls of a class that are within
//						as_within ("" for those on the class itself), with the
//						names the security service gives them at run time:
//						 - controls on tab pages and user objects are named
//						   with their parents, such as tab_1.tabpage_1.cb_ok;
//						 - menu items have their own names, such as m_open.
//						A control of a user object class (u_tab_x, u_cst_x) also has
//						the controls of that class.  A DataWindow control's columns are
//						named dw_1.column.
//	Returns:			The number of controls recorded
//////////////////////////////////////////////////////////////////////////////
long		ll_i, ll_count
string	ls_name, ls_type, ls_from, ls_dataobject
pfcscanner_n_cst_classinfo	lnv_class

SetPointer ( HourGlass! )

If Not IsValid ( anv_class ) Then Return 0

For ll_i = 1 To anv_class.il_count
	If anv_class.is_nwithin[ll_i] <> as_within Then Continue

	ls_from = anv_class.is_nfrom[ll_i]
	If ab_menu Then
		ls_name = anv_class.is_nname[ll_i]
		of_AddObject ( is_app, as_object, ls_name, "menuitem", of_GetMenuDesc ( anv_class.is_ntext[ll_i] ) )
		ll_count++
		ll_count += of_ScanControls ( as_object, anv_class, anv_class.is_nname[ll_i], "", True )
		Continue
	End If

	ls_type = inv_source.of_GetSystemType ( ls_from )
	// the security service doesn't secure the MDI client
	If ls_type = "mdiclient" Then Continue
	If ls_type = "" Then ls_type = ls_from

	ls_name = as_prefix + anv_class.is_nname[ll_i]
	of_AddObject ( is_app, as_object, ls_name, ls_type, of_GetDesc ( anv_class.is_ntext[ll_i], anv_class.is_ntag[ll_i] ) )
	ll_count++

	// the controls on it, declared by this class (such as a tab's pages) ...
	ll_count += of_ScanControls ( as_object, anv_class, anv_class.is_nname[ll_i], ls_name + ".", False )

	// ... and by its own class, with what that class inherits
	ls_dataobject = anv_class.is_ndataobject[ll_i]
	If Pos ( ls_from, "`" ) = 0 Then
		lnv_class = inv_source.of_GetClass ( ls_from )
		If IsValid ( lnv_class ) Then
			ll_count += of_ScanControls ( as_object, lnv_class, "", ls_name + ".", False )
			If ls_dataobject = "" Then ls_dataobject = lnv_class.is_dataobject
		End If
	End If

	If ls_type = "datawindow" And ls_dataobject <> "" Then
		ll_count += Max ( of_ScanDataObject ( as_object, ls_dataobject, ls_name ), 0 )
	End If
Next

Return ll_count
end function

public function integer of_scanobject (string as_object, string as_library);//////////////////////////////////////////////////////////////////////////////
//	Function:			of_scanobject
//	Description:  	Capture information about the controls and other classes on the object.
//						The object is read from its source, with the controls it
//						inherits from its ancestors.  A window also has its menu's items.
//	Returns:			The number of controls recorded, 0 for a nonvisual object,
//						-1 if the object can't be read
//////////////////////////////////////////////////////////////////////////////
long		ll_r, ll_rows
string	ls_type, ls_menu
pfcscanner_n_cst_classinfo	lnv_class, lnv_menu

SetPointer ( HourGlass! )

// check arguments
If IsNull ( as_object ) Or Len ( trim ( as_object ) ) = 0 Then Return -1
If Not IsValid ( inv_source ) Then Return -1
as_object = Lower ( Trim ( as_object ) )

ls_type = inv_source.of_GetObjectType ( as_object )
If ls_type = "" Then Return -1
If ls_type = "datawindow" Then Return of_ScanDataWindow ( as_object, as_library )
If Not inv_source.of_IsVisual ( as_object ) Then Return 0

// load the object being scanned from its source
lnv_class = inv_source.of_GetClass ( as_object )
If Not IsValid ( lnv_class ) Then Return -1

// get known controls
ll_rows = ids_updates.Retrieve ( is_app, as_object )

//  Delete all the objects since we are scanning again
For ll_r = 1 to ll_rows
	ids_updates.DeleteRow ( 0 )
Next
ids_updates.Update ( )

// scan the object for controls to be secured - recursively
of_ScanControls ( as_object, lnv_class, "", "", ls_type = "menu" )

If ls_type = "window" Then
	//  the window's menu, and its items
	ls_menu = lnv_class.is_menuname
	If Len ( ls_menu ) > 0 Then
		of_AddObject ( is_app, as_object, ls_menu, "menuitem", "Top Level Menu Object" )
		lnv_menu = inv_source.of_GetClass ( ls_menu )
		If IsValid ( lnv_menu ) Then of_ScanControls ( as_object, lnv_menu, "", "", True )
	End If
ElseIf ids_updates.RowCount ( ) = 0 Then
	// does not have any controls so record the object itself
	of_AddObject ( is_app, as_object, as_object, inv_source.of_GetSystemType ( as_object ), &
						of_GetDesc ( lnv_class.is_text, lnv_class.is_tag ) )
End If

Return ids_updates.RowCount ( )
end function

on pfcscanner_n_cst_securityscanner.create
call super::create
TriggerEvent( this, "constructor" )
end on

on pfcscanner_n_cst_securityscanner.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event constructor;//////////////////////////////////////////////////////////////////////////////
//	Event:  			Constructor
//	Description:  	Create all needed  datastore objects
//////////////////////////////////////////////////////////////////////////////
ids_updates = create pfcscanner_n_ds

ids_apps = create pfcscanner_n_ds

ids_info = create pfcscanner_n_ds
end event

event destructor;//////////////////////////////////////////////////////////////////////////////
//	Event:  			Destructor
//	Description:  	Destroy all created datastore objects
//////////////////////////////////////////////////////////////////////////////
If IsValid ( ids_updates ) Then Destroy ids_updates
If IsValid ( ids_info ) Then Destroy ids_info
If IsValid ( ids_apps ) Then Destroy ids_apps
If ib_ownsource And IsValid ( inv_source ) Then Destroy inv_source
end event

