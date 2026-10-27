$PBExportHeader$w_securityserv.srw
$PBExportComments$Example of the security service (n_cst_security), with sample settings that are rolled back on close
forward
global type w_securityserv from w_main
end type
type st_intro from statictext within w_securityserv
end type
type gb_signin from groupbox within w_securityserv
end type
type rb_clerk from radiobutton within w_securityserv
end type
type rb_manager from radiobutton within w_securityserv
end type
type rb_auditor from radiobutton within w_securityserv
end type
type rb_provider from radiobutton within w_securityserv
end type
type cbx_appclerks from checkbox within w_securityserv
end type
type cbx_appmanagers from checkbox within w_securityserv
end type
type cbx_appguests from checkbox within w_securityserv
end type
type cbx_denydefault from checkbox within w_securityserv
end type
type cb_open from u_cb within w_securityserv
end type
type st_settings from statictext within w_securityserv
end type
type dw_settings from datawindow within w_securityserv
end type
type cb_close from u_cb within w_securityserv
end type
end forward

global type w_securityserv from w_main
integer x = 594
integer y = 300
integer width = 2551
integer height = 2080
string title = "PFC Example - Security Service"
st_intro st_intro
gb_signin gb_signin
rb_clerk rb_clerk
rb_manager rb_manager
rb_auditor rb_auditor
rb_provider rb_provider
cbx_appclerks cbx_appclerks
cbx_appmanagers cbx_appmanagers
cbx_appguests cbx_appguests
cbx_denydefault cbx_denydefault
cb_open cb_open
st_settings st_settings
dw_settings dw_settings
cb_close cb_close
end type
global w_securityserv w_securityserv

type variables
Protected:
// The sample application in the security database (only while this window is open)
constant string APP = "pfcexamp_security"
// The INI file section with the security database connection
constant string INI_SECTION = "Security"

// The security database, with the sample rows not committed
n_tr	itr_sec
// TRUE if this window started the security service (and stops it when it closes)
boolean	ib_startedservice
end variables

forward prototypes
protected function integer of_connect ()
protected function integer of_createsample ()
protected function boolean of_exec (string as_sql)
protected function integer of_showsettings ()
protected function integer of_signin (ref string as_who)
end prototypes

protected function integer of_connect ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_Connect
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Returns:			Integer
//						1 if connected, -1 if the INI file has no security database
//						connection or the connection fails
//
//	Description:	Connects to the PFC security database described in the [Security]
//						section of the application's INI file (examples.ini), with AutoCommit
//						off, so the sample rows can be rolled back.
//
//////////////////////////////////////////////////////////////////////////////
string	ls_ini

ls_ini = gnv_app.of_GetAppIniFile()
If ProfileString(ls_ini, INI_SECTION, "DBMS", "") = "" Then
	MessageBox(this.Title, "This example needs the PFC security database.  Add a [" + INI_SECTION + &
		"] section to " + ls_ini + " with its connection, the same entries as the [Database] " + &
		"section (DBMS, ServerName, LogId, LogPassword, DBParm).", Information!)
	Return -1
End If

itr_sec = Create n_tr
If itr_sec.of_Init(ls_ini, INI_SECTION) <> 1 Then
	MessageBox(this.Title, "The [" + INI_SECTION + "] section of " + ls_ini + " could not be read.", StopSign!)
	Return -1
End If
itr_sec.AutoCommit = False

Connect Using itr_sec;
If itr_sec.SQLCode <> 0 Then
	MessageBox(this.Title, "Unable to connect to the security database:~r~n" + itr_sec.SQLErrText, StopSign!)
	Return -1
End If
Return 1
end function

protected function boolean of_exec (string as_sql);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_Exec
//
//	Access:			Protected
//
//	Arguments:
//	as_sql			A SQL statement
//
//	Returns:			Boolean
//						TRUE if it ran
//
//////////////////////////////////////////////////////////////////////////////
Execute Immediate :as_sql Using itr_sec;
If itr_sec.SQLCode <> 0 Then
	MessageBox(this.Title, "Unable to create the sample settings:~r~n" + itr_sec.SQLErrText, StopSign!)
	Return False
End If
Return True
end function

protected function integer of_createsample ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_CreateSample
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Returns:			Integer
//						1 if the sample rows were inserted, -1 if not
//
//	Description:	Inserts a sample application, users, groups and settings for
//						w_securityorder.  They are never committed: the window rolls them
//						back when it closes, so the security database stays as it was.  The
//						Security Administrator defines the same rows for a real application.
//
//////////////////////////////////////////////////////////////////////////////
string	ls_groups[], ls_controls[], ls_types[], ls_settings[]
integer	li_i, li_j

If Not of_Exec("insert into security_apps (application, description) values ('" + APP + "', 'PFC Examples: Security Service')") Then Return -1

// Users (user_type 0) and groups (user_type 1); a lower priority takes precedence
If Not of_Exec("insert into security_users (name, description, priority, user_type) values ('exm_clerk', 'Sample clerk', 0, 0)") Then Return -1
If Not of_Exec("insert into security_users (name, description, priority, user_type) values ('exm_manager', 'Sample manager', 0, 0)") Then Return -1
If Not of_Exec("insert into security_users (name, description, priority, user_type) values ('exm_auditor', 'Sample auditor', 0, 0)") Then Return -1
ls_groups = {"exm_managers", "exm_clerks", "exm_auditors", "exm_guests"}
For li_i = 1 To UpperBound(ls_groups)
	If Not of_Exec("insert into security_users (name, description, priority, user_type) values ('" + &
		ls_groups[li_i] + "', 'Sample group', " + String(li_i) + ", 1)") Then Return -1
Next
If Not of_Exec("insert into security_groupings (group_name, user_name) values ('exm_clerks', 'exm_clerk')") Then Return -1
If Not of_Exec("insert into security_groupings (group_name, user_name) values ('exm_managers', 'exm_manager')") Then Return -1
If Not of_Exec("insert into security_groupings (group_name, user_name) values ('exm_auditors', 'exm_auditor')") Then Return -1

// The controls of w_securityorder (a control needs a template row before it can have settings)
ls_controls = {"cb_new", "cb_save", "cb_delete", "cb_approve", "cb_print", "cb_enableall", "cbx_apply", "cb_close"}
ls_types = {"CommandButton", "CommandButton", "CommandButton", "CommandButton", "CommandButton", "CommandButton", "CheckBox", "CommandButton"}
For li_i = 1 To UpperBound(ls_controls)
	If Not of_Exec("insert into security_template (application, [window], control, description, object_type) values ('" + &
		APP + "', 'w_securityorder', '" + ls_controls[li_i] + "', '" + ls_controls[li_i] + "', '" + ls_types[li_i] + "')") Then Return -1
Next

// Settings, as group~tcontrol~tstatus: E(nable), D(isable), I(nvisible).  cb_print has
// none, so only deny by default changes it.  Every group may close the window and try
// Enable All Buttons (that matters with deny by default).
ls_settings = {"exm_clerks~tcb_delete~tD", "exm_clerks~tcb_approve~tI", "exm_clerks~tcb_new~tE", &
	"exm_managers~tcb_new~tE", "exm_managers~tcb_delete~tE", "exm_managers~tcb_approve~tE", &
	"exm_auditors~tcb_new~tD", "exm_auditors~tcb_save~tD", "exm_auditors~tcb_delete~tD", "exm_auditors~tcb_approve~tI"}
For li_i = 1 To UpperBound(ls_groups)
	ls_settings[UpperBound(ls_settings) + 1] = ls_groups[li_i] + "~tcb_close~tE"
	ls_settings[UpperBound(ls_settings) + 1] = ls_groups[li_i] + "~tcb_enableall~tE"
	ls_settings[UpperBound(ls_settings) + 1] = ls_groups[li_i] + "~tcbx_apply~tE"
Next
For li_j = 1 To UpperBound(ls_settings)
	If Not of_Exec("insert into security_info (application, [window], control, user_name, status) values ('" + &
		APP + "', 'w_securityorder', '" + Mid(ls_settings[li_j], Pos(ls_settings[li_j], "~t") + 1, &
		LastPos(ls_settings[li_j], "~t") - Pos(ls_settings[li_j], "~t") - 1) + "', '" + &
		Left(ls_settings[li_j], Pos(ls_settings[li_j], "~t") - 1) + "', '" + Right(ls_settings[li_j], 1) + "')") Then Return -1
Next
Return 1
end function

protected function integer of_showsettings ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_ShowSettings
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Returns:			Integer
//						The number of settings shown, or -1 if they can't be read
//
//	Description:	Lists the sample settings, read through the same transaction (so the
//						uncommitted rows are there).
//
//////////////////////////////////////////////////////////////////////////////
string	ls_sql, ls_syntax, ls_errors

ls_sql = "select user_name, control, status from security_info where application = '" + APP + &
	"' order by user_name, control"
ls_syntax = itr_sec.SyntaxFromSQL(ls_sql, "style(type=grid)", ls_errors)
If Len(ls_errors) > 0 Then Return -1
If dw_settings.Create(ls_syntax, ls_errors) <> 1 Then Return -1
dw_settings.Modify("user_name_t.Text='Group' control_t.Text='Control' status_t.Text='Setting' user_name.Width=700 user_name_t.Width=700 control.Width=700 control_t.Width=700 status.Width=300 status_t.Width=300")
dw_settings.SetTransObject(itr_sec)
Return dw_settings.Retrieve()
end function

protected function integer of_signin (ref string as_who);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_SignIn
//
//	Access:			Protected
//
//	Arguments:
//	as_who			(by reference) who signed in, to show in w_securityorder
//
//	Returns:			Integer
//						The n_cst_security of_InitSecurity return value (1 = OK)
//
//	Description:	Initializes the security service for the chosen user.  The sample
//						users' groups come from the security database; a user from an
//						identity provider brings the provider's groups, which of_MapGroups
//						maps to the database's groups (and app-guests to none, so that user
//						falls back to the default group).
//
//////////////////////////////////////////////////////////////////////////////
string	ls_user, ls_provider[], ls_mapped[], ls_from[], ls_to[], ls_list
integer	li_i, li_rc

If rb_provider.Checked Then
	If cbx_appclerks.Checked Then ls_provider[UpperBound(ls_provider) + 1] = "app-clerks"
	If cbx_appmanagers.Checked Then ls_provider[UpperBound(ls_provider) + 1] = "app-managers"
	If cbx_appguests.Checked Then ls_provider[UpperBound(ls_provider) + 1] = "app-guests"
	// Usually kept in an INI file section (the of_MapGroups syntax that takes a file)
	ls_from = {"app-clerks", "app-managers", "app-guests"}
	ls_to = {"exm_clerks", "exm_managers", ""}
	gnv_app.inv_security.of_MapGroups(ls_provider, ls_from, ls_to, ls_mapped)

	For li_i = 1 To UpperBound(ls_mapped)
		If ls_list <> "" Then ls_list += ", "
		ls_list += ls_mapped[li_i]
	Next
	If ls_list = "" Then ls_list = "none: the default group, exm_guests"
	as_who = "Signed in as exm_external, from an identity provider.  Groups after of_MapGroups: " + ls_list + "."
	li_rc = gnv_app.inv_security.of_InitSecurity(itr_sec, APP, "exm_external", ls_mapped, "exm_guests")
Else
	If rb_manager.Checked Then
		ls_user = "exm_manager"
	ElseIf rb_auditor.Checked Then
		ls_user = "exm_auditor"
	Else
		ls_user = "exm_clerk"
	End If
	as_who = "Signed in as " + ls_user + ", whose group comes from the security database."
	li_rc = gnv_app.inv_security.of_InitSecurity(itr_sec, APP, ls_user, "")
End If

If cbx_denydefault.Checked Then as_who += "  Deny by default: what has no setting is disabled."
Return li_rc
end function

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	Connects to the security database, inserts the sample settings, and
//						starts the security service if the application doesn't use it.
//
//////////////////////////////////////////////////////////////////////////////
If of_Connect() <> 1 Or of_CreateSample() <> 1 Then
	cb_open.Enabled = False
	Return
End If

If Not IsValid(gnv_app.inv_security) Then
	gnv_app.of_SetSecurity(True)
	ib_startedservice = True
End If

of_ShowSettings()
end event

event close;call super::close;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			close
//
//	Description:	Rolls back the sample settings and stops the security service if this
//						window started it.
//
//////////////////////////////////////////////////////////////////////////////
If ib_startedservice Then gnv_app.of_SetSecurity(False)

If IsValid(itr_sec) Then
	If itr_sec.of_IsConnected() Then
		Rollback Using itr_sec;
		Disconnect Using itr_sec;
	End If
	Destroy itr_sec
End If
end event

on w_securityserv.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.gb_signin=create gb_signin
this.rb_clerk=create rb_clerk
this.rb_manager=create rb_manager
this.rb_auditor=create rb_auditor
this.rb_provider=create rb_provider
this.cbx_appclerks=create cbx_appclerks
this.cbx_appmanagers=create cbx_appmanagers
this.cbx_appguests=create cbx_appguests
this.cbx_denydefault=create cbx_denydefault
this.cb_open=create cb_open
this.st_settings=create st_settings
this.dw_settings=create dw_settings
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.rb_clerk
this.Control[iCurrent+3]=this.rb_manager
this.Control[iCurrent+4]=this.rb_auditor
this.Control[iCurrent+5]=this.rb_provider
this.Control[iCurrent+6]=this.cbx_appclerks
this.Control[iCurrent+7]=this.cbx_appmanagers
this.Control[iCurrent+8]=this.cbx_appguests
this.Control[iCurrent+9]=this.cbx_denydefault
this.Control[iCurrent+10]=this.cb_open
this.Control[iCurrent+11]=this.st_settings
this.Control[iCurrent+12]=this.dw_settings
this.Control[iCurrent+13]=this.cb_close
this.Control[iCurrent+14]=this.gb_signin
end on

on w_securityserv.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.gb_signin)
destroy(this.rb_clerk)
destroy(this.rb_manager)
destroy(this.rb_auditor)
destroy(this.rb_provider)
destroy(this.cbx_appclerks)
destroy(this.cbx_appmanagers)
destroy(this.cbx_appguests)
destroy(this.cbx_denydefault)
destroy(this.cb_open)
destroy(this.st_settings)
destroy(this.dw_settings)
destroy(this.cb_close)
end on

type st_intro from statictext within w_securityserv
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
string text = "The security service (n_cst_security) enables, disables or hides controls by the settings for the user and the user's groups in the PFC security database.  Choose who signs in and open the order window to see its buttons change.  The sample users, groups and settings below exist only while this window is open: they are never committed."
boolean focusrectangle = false
end type

type gb_signin from groupbox within w_securityserv
integer x = 37
integer y = 284
integer width = 2437
integer height = 584
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Sign in as"
end type

type rb_clerk from radiobutton within w_securityserv
integer x = 82
integer y = 360
integer width = 2350
integer height = 72
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "A &clerk (exm_clerk, in the exm_clerks group)"
boolean checked = true
end type

type rb_manager from radiobutton within w_securityserv
integer x = 82
integer y = 440
integer width = 2350
integer height = 72
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "A &manager (exm_manager, in the exm_managers group)"
end type

type rb_auditor from radiobutton within w_securityserv
integer x = 82
integer y = 520
integer width = 2350
integer height = 72
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "An a&uditor (exm_auditor, in the exm_auditors group)"
end type

type rb_provider from radiobutton within w_securityserv
integer x = 82
integer y = 600
integer width = 2350
integer height = 72
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "A user from an &identity provider (exm_external, not in the database), with these provider groups:"
end type

type cbx_appclerks from checkbox within w_securityserv
integer x = 165
integer y = 688
integer width = 580
integer height = 72
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "app-clerks"
boolean checked = true
end type

type cbx_appmanagers from checkbox within w_securityserv
integer x = 777
integer y = 688
integer width = 580
integer height = 72
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "app-managers"
end type

type cbx_appguests from checkbox within w_securityserv
integer x = 1390
integer y = 688
integer width = 1042
integer height = 72
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "app-guests (mapped to no group)"
end type

type cbx_denydefault from checkbox within w_securityserv
integer x = 37
integer y = 900
integer width = 2437
integer height = 72
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Deny by default: disable the controls that have no setting (of_SetDefaultStatus)"
end type

type cb_open from u_cb within w_securityserv
integer x = 37
integer y = 1000
integer width = 750
integer taborder = 10
string text = "&Open the Order Window"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;string	ls_who

If parent.of_SignIn(ls_who) <> 1 Then
	MessageBox(parent.Title, "The security service could not be initialized.", StopSign!)
	Return
End If

// The order window is a response window, so no other window can change while the
// default status is set; afterwards the rest of the application is left as designed.
If cbx_denydefault.Checked Then gnv_app.inv_security.of_SetDefaultStatus(gnv_app.inv_security.DISABLE)
OpenWithParm(w_securityorder, ls_who)
gnv_app.inv_security.of_SetDefaultStatus(gnv_app.inv_security.NOTSET)
end event

type st_settings from statictext within w_securityserv
integer x = 37
integer y = 1124
integer width = 2437
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "The sample settings for w_securityorder (E = enable, D = disable, I = invisible):"
boolean focusrectangle = false
end type

type dw_settings from datawindow within w_securityserv
integer x = 37
integer y = 1196
integer width = 2437
integer height = 620
integer taborder = 20
boolean vscrollbar = true
boolean livescroll = true
borderstyle borderstyle = stylelowered!
end type

type cb_close from u_cb within w_securityserv
integer x = 2107
integer y = 1860
integer taborder = 30
string text = "Close"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
