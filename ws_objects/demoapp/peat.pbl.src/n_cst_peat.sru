$PBExportHeader$n_cst_peat.sru
$PBExportComments$PEAT Application Manager class
forward
global type n_cst_peat from n_cst_appmanager
end type
end forward

global type n_cst_peat from n_cst_appmanager
end type
global n_cst_peat n_cst_peat

forward prototypes
public function integer of_refreshprojects ()
protected function integer of_opensecured (string as_securityinifile)
end prototypes

protected function integer of_opensecured (string as_securityinifile);// Opens the frame with OpenID Connect logon and PFC security, using the settings in
// as_securityinifile ([Security] connection and DefaultGroup, [OpenID], [GroupMap]).
// Returns 1 if the application is open, 0 if the user cancelled the logon, -1 on error.
Integer	li_rc
String	ls_groups[]
n_cst_openidattrib	lnv_openid

// Without the security database the application cannot be secured, so stop
gnv_trans_security = CREATE n_tr
IF gnv_trans_security.of_Init(as_securityinifile, "Security") = -1 THEN
	this.inv_error.of_message(gnv_app.iapp_object.DisplayName, + &
			"Error initializing security connection information, " + as_securityinifile + " not found.")
	Return -1
END IF

IF gnv_trans_security.of_Connect() = -1 THEN
	this.inv_error.of_message(gnv_app.iapp_object.DisplayName, + &
			"Error connecting to Security Database.", StopSign!, OK!)
	Return -1
END IF

Open(w_f_peat)

// Log on with the OpenID Connect provider
li_rc = this.of_OpenIDLogonDlg(lnv_openid, as_securityinifile, "OpenID")
IF li_rc <> 1 THEN
	Close(w_f_peat)
	Return li_rc
END IF

// Group membership comes from the identity provider; the security database supplies the settings.
// The [GroupMap] section maps the provider's group names to PFC security group names.
inv_security.of_MapGroups(lnv_openid.is_groups, as_securityinifile, "GroupMap", ls_groups)
li_rc = inv_security.of_InitSecurity(gnv_trans_security, "peat", this.of_GetUserID(), ls_groups, &
		ProfileString(as_securityinifile, "Security", "DefaultGroup", ""))
IF li_rc <> 1 THEN
	this.inv_error.of_message(gnv_app.iapp_object.DisplayName, + &
			"Security could not be initialized for " + this.of_GetUserID() + " (" + String(li_rc) + ").", StopSign!, OK!)
	Close(w_f_peat)
	Return -1
END IF

inv_security.of_SetSecurity(w_f_peat)

// w_f_peat leaves this to us when security is on, so it opens after security is set up
OpenSheet(w_s_projectlist, w_f_peat, 0, Layered!)

Return 1
end function

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
integer	li_return
string	ls_inifile
string	ls_securityinifile
boolean	lb_secured

// OpenID Connect logon and PFC security are optional.  They are only used when
// peat_security.ini (see peat_security.ini.example) is in the same folder as the INI file.
ls_securityinifile = gnv_app.of_GetAppIniFile()
ls_securityinifile = Left(ls_securityinifile, LastPos(ls_securityinifile, "\")) + "peat_security.ini"
lb_secured = FileExists(ls_securityinifile)

// Display the Splash window
If Not lb_secured Then this.of_Splash(1)

// Initialize the various functionality of this service
this.of_SetTrRegistration(TRUE)
this.of_SetError(TRUE)
If lb_secured Then this.of_SetSecurity(TRUE)

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
		If lb_secured Then
			If this.of_OpenSecured(ls_securityinifile) = 1 Then this.of_Splash(1)
		Else
			Open(w_f_peat)
		End If
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
this.of_SetLogo("peat.bmp")
this.of_SetVersion("Version " + String ( li_major ) + "." + String ( li_minor ) + ".00")
this.of_SetAppIniFile("peat.ini")



end event

