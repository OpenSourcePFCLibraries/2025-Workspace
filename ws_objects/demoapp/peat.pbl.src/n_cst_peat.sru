$PBExportHeader$n_cst_peat.sru
$PBExportComments$PEAT Application Manager class
forward
global type n_cst_peat from n_cst_appmanager
end type
end forward

global type n_cst_peat from n_cst_appmanager
end type
global n_cst_peat n_cst_peat

type variables
Public:
// The folder of the application (its themes are in its theme folder)
string	is_appfolder
end variables

forward prototypes
public function integer of_refreshprojects ()
end prototypes

public function integer of_refreshprojects ();// This function will find the active sheet and refresh the projects listed there.
// This function is called whenever a change has been made to the current project,
// a new project added, or the current project deleted.

w_s_projectlist	w_active

w_active = this.of_getframe().GetActiveSheet()
IF IsValid(w_active) THEN
	Return w_s_projectlist.of_refresh()
END IF

Return 0
end function

on n_cst_peat.create
call super::create
end on

on n_cst_peat.destroy
call super::destroy
end on

event pfc_open;call super::pfc_open;
string	ls_inifile
string	ls_theme

// PFC texts in another language when lang\pfc.lng is present (see the localization repository)
this.of_SetLanguage(TRUE)

// The UI theme: Theme in the [Application] section of the INI file, Flat Design Grey by
// default (the themes are in the theme folder; None uses no theme).  of_ApplyTheme also gives
// the status bar the theme's colors.
is_appfolder = GetCurrentDirectory()
ls_theme = ProfileString(this.of_GetAppIniFile(), "Application", "Theme", "Flat Design Grey")
If ls_theme <> "" And Lower(ls_theme) <> "none" Then
	If DirectoryExists(is_appfolder + "\theme\" + ls_theme) Then this.of_ApplyTheme(is_appfolder + "\theme\" + ls_theme)
End If

// Display the Splash window
this.of_Splash(1)

// Initialize the various functionality of this service
this.of_SetTrRegistration(TRUE)
this.of_SetError(TRUE)

// Connect to database
ls_inifile = gnv_app.of_GetAppIniFile()
IF SQLCA.of_Init(ls_inifile, "Database") = -1 THEN
	this.inv_error.of_message(gnv_app.iapp_object.DisplayName, + &
			"Error initializing connection information, .INI file not found.")
ELSE
	IF SQLCA.of_Connect() = -1 THEN
		this.inv_error.of_message(gnv_app.iapp_object.DisplayName, + &
				"Error connecting to Database.", StopSign!, OK!)
	ELSE
		inv_error.of_SetPredefinedSource(SQLCA)
		Open(w_f_peat)
	END IF 
END IF
end event

event constructor;call super::constructor;
ContextInformation lcx_key
int li_major, li_minor
date ld_now

ld_now = Today ( )

/*  Get PB Version.    */
GetContextService ( "ContextInformation", lcx_key)
lcx_key.GetMajorVersion ( li_major )
lcx_key.GetMinorVersion ( li_minor )

// Set the default information needed for this application
iapp_object.DisplayName = "PEAT - Project Estimation and Actuals Tracker"
this.of_SetCopyright("Copyright (c) 2004-" + String ( Year ( ld_now ), "0000" ) + " Open Source PowerBuilder Foundation Class Libraries, All rights reserved.")
this.of_SetLogo("images\peat.png")
this.of_SetVersion("Version " + String ( li_major ) + "." + String ( li_minor ) + ".00")
this.of_SetAppIniFile("peat.ini")



end event

