$PBExportHeader$w_master.srw
$PBExportComments$Extended for PFC Examples Application.
forward
global type w_master from pfc_w_master
end type
end forward

global type w_master from pfc_w_master
end type
global w_master w_master

type variables
end variables

forward prototypes
public function string of_getexampletitle (string as_classname)
end prototypes

public function string of_getexampletitle (string as_classname);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_GetExampleTitle
//
//	Access:			Public
//
//	Arguments:
//	as_classname	The class name of an example's window
//
//	Returns:			String
//						The example's title in the example catalog (exam.txt), "" if the
//						catalog has no example with that window, or "!" if the catalog can't
//						be read (the window then keeps its own title)
//
//////////////////////////////////////////////////////////////////////////////
n_cst_examplecatalog	lnv_catalog

Return lnv_catalog.of_GetTitle(as_classname)
end function

on w_master.create
call super::create
end on

on w_master.destroy
call super::destroy
end on

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//	Event:			open
//	Description:		Retrieves the example's title from the database.  Embedded SQL is
// 						passed to the SQL Spy, if valid.
//////////////////////////////////////////////////////////////////////////////
string	ls_title

If this.ClassName ( ) = "w_examplemain" Then Return

If ( Pos ( this.title, "PFC Example" ) > 0 ) Then	
	ls_title = of_GetExampleTitle ( this.ClassName ( ) )
	If ls_title <> '!' Then	
		this.title = ls_title
	End If
End If
of_SetPreference ( True )

If IsValid(inv_preference) Then
	If gnv_app.of_IsRegistryAvailable() Then
		inv_preference.of_Center ( ) 
	End If
End If
end event

event activate;call super::activate;//////////////////////////////////////////////////////////////////////////////
//	Event:			activate
//	Description:		Takes away the user's ability to customize the toolbar if the window
// 						is the application's main window.
//////////////////////////////////////////////////////////////////////////////
gnv_app.iapp_object.ToolbarUserControl = false

return 1
end event

event pfc_endtran;call super::pfc_endtran;//////////////////////////////////////////////////////////////////////////////
//	Event:			pfc_endtran
//	Arguments:		ai_update_results		The results of the PFC Save Process (of_Update()).
//	Returns:			integer, SUCCESS = 1, ERR = -1
//	Description:		The default transaction management for updateable examples.
//////////////////////////////////////////////////////////////////////////////
integer	li_rc

// Commit or rollback based on update
if ai_update_results = 1 then
	li_rc = sqlca.of_Commit()
	if li_rc >= 0 then
		return 1
	else
		MessageBox(this.title, "Commit failed.")
		return -1
	end if
else
	sqlca.of_Rollback()
	if sqlca.sqlcode < 0 then 
		MessageBox(this.title, "Rollback failed.")
		return -1
	end if
end if

return 1
end event

event pfc_begintran;call super::pfc_begintran;//////////////////////////////////////////////////////////////////////////////
//	Event:			pfc_begintran
//	Description:		Perform begin transaction processing.
//////////////////////////////////////////////////////////////////////////////
return sqlca.of_Begin()
end event

