$PBExportHeader$w_smtpdemo.srw
$PBExportComments$Sends mail with n_smtpclient, signing in with OAuth 2.0 (n_cst_oauth2)
forward
global type w_smtpdemo from w_main
end type
type gb_provider from u_gb within w_smtpdemo
end type
type rb_microsoft from u_rb within w_smtpdemo
end type
type rb_google from u_rb within w_smtpdemo
end type
type st_tenant from u_st within w_smtpdemo
end type
type sle_tenant from u_sle within w_smtpdemo
end type
type st_clientid from u_st within w_smtpdemo
end type
type sle_clientid from u_sle within w_smtpdemo
end type
type st_secret from u_st within w_smtpdemo
end type
type sle_secret from u_sle within w_smtpdemo
end type
type gb_flow from u_gb within w_smtpdemo
end type
type rb_code from u_rb within w_smtpdemo
end type
type rb_device from u_rb within w_smtpdemo
end type
type rb_clientcredentials from u_rb within w_smtpdemo
end type
type gb_message from u_gb within w_smtpdemo
end type
type st_from from u_st within w_smtpdemo
end type
type sle_from from u_sle within w_smtpdemo
end type
type st_to from u_st within w_smtpdemo
end type
type sle_to from u_sle within w_smtpdemo
end type
type st_subject from u_st within w_smtpdemo
end type
type sle_subject from u_sle within w_smtpdemo
end type
type mle_body from u_mle within w_smtpdemo
end type
type gb_server from u_gb within w_smtpdemo
end type
type st_host from u_st within w_smtpdemo
end type
type sle_host from u_sle within w_smtpdemo
end type
type st_port from u_st within w_smtpdemo
end type
type sle_port from u_sle within w_smtpdemo
end type
type cbx_tls from u_cbx within w_smtpdemo
end type
type cbx_log from u_cbx within w_smtpdemo
end type
type mle_log from u_mle within w_smtpdemo
end type
type cb_token from u_cb within w_smtpdemo
end type
type cb_send from u_cb within w_smtpdemo
end type
type cb_signout from u_cb within w_smtpdemo
end type
type cb_cancel from u_cb within w_smtpdemo
end type
type cb_save from u_cb within w_smtpdemo
end type
type cb_close from u_cb within w_smtpdemo
end type
end forward

global type w_smtpdemo from w_main
integer width = 2629
integer height = 2620
string title = "PFC SMTP Client with OAuth 2.0"
boolean resizable = false
gb_provider gb_provider
rb_microsoft rb_microsoft
rb_google rb_google
st_tenant st_tenant
sle_tenant sle_tenant
st_clientid st_clientid
sle_clientid sle_clientid
st_secret st_secret
sle_secret sle_secret
gb_flow gb_flow
rb_code rb_code
rb_device rb_device
rb_clientcredentials rb_clientcredentials
gb_message gb_message
st_from st_from
sle_from sle_from
st_to st_to
sle_to sle_to
st_subject st_subject
sle_subject sle_subject
mle_body mle_body
gb_server gb_server
st_host st_host
sle_host sle_host
st_port st_port
sle_port sle_port
cbx_tls cbx_tls
cbx_log cbx_log
mle_log mle_log
cb_token cb_token
cb_send cb_send
cb_signout cb_signout
cb_cancel cb_cancel
cb_save cb_save
cb_close cb_close
end type
global w_smtpdemo w_smtpdemo

type variables
Protected:
// The settings are in the registry, so the demo can be shared without them:
// <REGKEY>\<provider>, values Tenant, ClientID, ClientSecret, Mailbox and Recipient
Constant String REGKEY = "HKEY_CURRENT_USER\Software\PFC\SMTP Demo"

// One client for the window: its token service keeps the token (and the refresh
// token) between messages
n_smtpclient	inv_smtp
// The identity provider settings inv_smtp was set up with
string	is_settings
end variables

forward prototypes
protected function string of_provider ()
protected function string of_flow ()
protected subroutine of_loadsettings ()
protected subroutine of_savesettings ()
protected function integer of_setup ()
protected function integer of_authorize ()
protected subroutine of_send ()
protected subroutine of_log (string as_text)
protected function string of_result (integer ai_rc)
protected subroutine of_setbusy (boolean ab_busy)
end prototypes

protected function string of_provider ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Provider
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  String.  The chosen identity provider: n_cst_oauth2.MICROSOFT or GOOGLE
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
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

If rb_google.checked Then Return "google"
Return "microsoft"
end function

protected function string of_flow ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Flow
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  String.  The chosen flow: n_cst_oauth2.AUTHORIZATIONCODE, DEVICECODE or CLIENTCREDENTIALS
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
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

If rb_device.checked Then Return "device"
If rb_clientcredentials.checked Then Return "client_credentials"
Return "code"
end function

protected subroutine of_loadsettings ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_LoadSettings
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Reads the chosen provider's settings from the registry (REGKEY), and
//		clears the server, so that the provider's SMTP server is used.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
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

string	ls_key, ls_value

ls_key = REGKEY + "\" + of_Provider()

ls_value = ""
RegistryGet(ls_key, "Tenant", RegString!, ls_value)
sle_tenant.text = ls_value
ls_value = ""
RegistryGet(ls_key, "ClientID", RegString!, ls_value)
sle_clientid.text = ls_value
ls_value = ""
RegistryGet(ls_key, "ClientSecret", RegString!, ls_value)
sle_secret.text = ls_value
ls_value = ""
RegistryGet(ls_key, "Mailbox", RegString!, ls_value)
sle_from.text = ls_value
ls_value = ""
RegistryGet(ls_key, "Recipient", RegString!, ls_value)
sle_to.text = ls_value

sle_tenant.enabled = (of_Provider() = "microsoft")
sle_host.text = ""
sle_port.text = ""
end subroutine

protected subroutine of_savesettings ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SaveSettings
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Writes the chosen provider's settings to the registry (REGKEY).  The
//		client secret is kept as it is typed: this is a demonstration.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
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

string	ls_key

ls_key = REGKEY + "\" + of_Provider()
RegistrySet(ls_key, "Tenant", RegString!, Trim(sle_tenant.text))
RegistrySet(ls_key, "ClientID", RegString!, Trim(sle_clientid.text))
RegistrySet(ls_key, "ClientSecret", RegString!, sle_secret.text)
RegistrySet(ls_key, "Mailbox", RegString!, Trim(sle_from.text))
RegistrySet(ls_key, "Recipient", RegString!, Trim(sle_to.text))
of_Log("Settings saved in " + ls_key)
end subroutine

protected function integer of_setup ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Setup
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  Integer.  1 if inv_smtp is ready, -1 if not
//
//	Description:  Sets up inv_smtp from the window.  When the identity provider settings
//		change, a new client (and token service) is created, so the old tokens are
//		forgotten; otherwise the token service keeps its tokens.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
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

string	ls_settings

If Trim(sle_clientid.text) = "" Then
	of_Log("Enter the client ID of the application registration.")
	Return -1
End If

ls_settings = of_Provider() + "|" + Trim(sle_tenant.text) + "|" + Trim(sle_clientid.text) + "|" + sle_secret.text
If Not IsValid(inv_smtp) Or ls_settings <> is_settings Then
	If IsValid(inv_smtp) Then Destroy inv_smtp
	inv_smtp = Create n_smtpclient
	// An empty Host gets the provider's SMTP server
	inv_smtp.Host = Trim(sle_host.text)
	If inv_smtp.of_SetOAuth2(of_Provider(), Trim(sle_tenant.text), Trim(sle_clientid.text), sle_secret.text) <> 1 Then
		of_Log("Unknown identity provider")
		Return -1
	End If
	is_settings = ls_settings
	If Trim(sle_host.text) = "" Then
		sle_host.text = inv_smtp.Host
		sle_port.text = String(inv_smtp.Port)
		cbx_tls.checked = inv_smtp.EnableTLS
	End If
End If

inv_smtp.Host = Trim(sle_host.text)
If IsNumber(sle_port.text) Then inv_smtp.Port = Long(sle_port.text)
inv_smtp.EnableTLS = cbx_tls.checked
inv_smtp.UserName = Trim(sle_from.text)
If cbx_log.checked Then inv_smtp.LogFile(GetCurrentDirectory() + "\smtpdemo.log")
inv_smtp.inv_oauth2.of_SetFlow(of_Flow())

Return 1
end function

protected function integer of_authorize ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Authorize
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  Integer.  1 if there is a valid access token, otherwise n_smtpclient.of_Authorize's code
//
//	Description:  Gets a token: the one the client has, a refreshed one, or a new one from
//		the chosen flow (the browser opens, or the device code is shown).
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
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

integer	li_rc

If of_Setup() <> 1 Then Return -6

If of_Provider() = "google" And of_Flow() = "client_credentials" Then
	of_Log("Google: Gmail has no client credentials flow (it needs a Workspace service account).")
	Return -6
End If

If inv_smtp.inv_oauth2.of_IsExpired() Then
	Choose Case of_Flow()
		Case "code"
			of_Log("Sign in in your web browser (Cancel stops waiting)...")
		Case "device"
			of_Log("Getting a device code...")
		Case Else
			of_Log("Getting a token for the application...")
	End Choose
End If

of_SetBusy(True)
li_rc = inv_smtp.of_Authorize(of_Flow())
of_SetBusy(False)

If li_rc = 1 Then
	If IsNull(inv_smtp.inv_oauth2.of_GetExpires()) Then
		of_Log("Token for " + inv_smtp.UserName + " (no expiry given)")
	Else
		of_Log("Token for " + inv_smtp.UserName + ", valid until " + &
			String(inv_smtp.inv_oauth2.of_GetExpires(), "yyyy-mm-dd hh:mm:ss"))
	End If
	If inv_smtp.inv_oauth2.of_GetRefreshToken() <> "" Then of_Log("  (with a refresh token: no sign-in needed next time)")
Else
	of_Log(of_Result(li_rc))
End If

Return li_rc
end function

protected subroutine of_send ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Send
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Sends the message.  of_Authorize first gets a valid token (signing the
//		user in only if there is none and it can't be refreshed).
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
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

integer	li_rc

If Trim(sle_from.text) = "" Or Trim(sle_to.text) = "" Then
	of_Log("Enter the mailbox to send from and a recipient.")
	Return
End If

If of_Authorize() <> 1 Then Return

// The same client sends each message: start with an empty one
inv_smtp.Message.Reset()
inv_smtp.Message.SetSender(Trim(sle_from.text))
inv_smtp.Message.AddRecipient(Trim(sle_to.text))
inv_smtp.Message.Subject = sle_subject.text
inv_smtp.Message.TextBody = mle_body.text

of_Log("Sending to " + Trim(sle_to.text) + " with " + inv_smtp.Host + ":" + String(inv_smtp.Port) + "...")
of_SetBusy(True)
li_rc = inv_smtp.Send()
of_SetBusy(False)

If li_rc = 1 Then
	of_Log("Sent.")
Else
	of_Log("Send returned " + String(li_rc) + ".  Check the mailbox's SMTP AUTH setting and the scope; " + &
		"'Log the SMTP session' writes the conversation to smtpdemo.log.")
End If
end subroutine

protected subroutine of_log (string as_text);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Log
//
//	Access:  protected
//
//	Arguments:
//	as_text		a line for the log
//
//	Returns:  None
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
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

If mle_log.text <> "" Then mle_log.text += "~r~n"
mle_log.text += String(Now(), "hh:mm:ss") + "  " + as_text
mle_log.Scroll(mle_log.LineCount())
end subroutine

protected function string of_result (integer ai_rc);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Result
//
//	Access:  protected
//
//	Arguments:
//	ai_rc		a return code of n_cst_oauth2.of_Authorize
//
//	Returns:  String.  What it means
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
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

string	ls_error

ls_error = inv_smtp.inv_oauth2.of_GetError()

Choose Case ai_rc
	Case 0
		Return "Cancelled."
	Case -1
		Return "The identity provider refused: " + ls_error
	Case -2
		Return "The identity provider could not be reached."
	Case -3
		Return "The browser could not be opened, or the redirect could not be received."
	Case -4
		Return "You didn't sign in in time."
	Case -5
		Return "The identity provider's response is not valid."
	Case -6
		Return ls_error
End Choose

Return "Error " + String(ai_rc)
end function

protected subroutine of_setbusy (boolean ab_busy);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetBusy
//
//	Access:  protected
//
//	Arguments:
//	ab_busy		True while waiting for the user or the server
//
//	Returns:  None
//
//	Description:  While the token service waits, only Cancel is enabled (it stops the wait).
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
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

cb_token.enabled = Not ab_busy
cb_send.enabled = Not ab_busy
cb_signout.enabled = Not ab_busy
cb_save.enabled = Not ab_busy
cb_close.enabled = Not ab_busy
cb_cancel.enabled = ab_busy
end subroutine

on w_smtpdemo.create
int iCurrent
call super::create
this.gb_provider=create gb_provider
this.rb_microsoft=create rb_microsoft
this.rb_google=create rb_google
this.st_tenant=create st_tenant
this.sle_tenant=create sle_tenant
this.st_clientid=create st_clientid
this.sle_clientid=create sle_clientid
this.st_secret=create st_secret
this.sle_secret=create sle_secret
this.gb_flow=create gb_flow
this.rb_code=create rb_code
this.rb_device=create rb_device
this.rb_clientcredentials=create rb_clientcredentials
this.gb_message=create gb_message
this.st_from=create st_from
this.sle_from=create sle_from
this.st_to=create st_to
this.sle_to=create sle_to
this.st_subject=create st_subject
this.sle_subject=create sle_subject
this.mle_body=create mle_body
this.gb_server=create gb_server
this.st_host=create st_host
this.sle_host=create sle_host
this.st_port=create st_port
this.sle_port=create sle_port
this.cbx_tls=create cbx_tls
this.cbx_log=create cbx_log
this.mle_log=create mle_log
this.cb_token=create cb_token
this.cb_send=create cb_send
this.cb_signout=create cb_signout
this.cb_cancel=create cb_cancel
this.cb_save=create cb_save
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.rb_microsoft
this.Control[iCurrent+2]=this.rb_google
this.Control[iCurrent+3]=this.st_tenant
this.Control[iCurrent+4]=this.sle_tenant
this.Control[iCurrent+5]=this.st_clientid
this.Control[iCurrent+6]=this.sle_clientid
this.Control[iCurrent+7]=this.st_secret
this.Control[iCurrent+8]=this.sle_secret
this.Control[iCurrent+9]=this.rb_code
this.Control[iCurrent+10]=this.rb_device
this.Control[iCurrent+11]=this.rb_clientcredentials
this.Control[iCurrent+12]=this.st_from
this.Control[iCurrent+13]=this.sle_from
this.Control[iCurrent+14]=this.st_to
this.Control[iCurrent+15]=this.sle_to
this.Control[iCurrent+16]=this.st_subject
this.Control[iCurrent+17]=this.sle_subject
this.Control[iCurrent+18]=this.mle_body
this.Control[iCurrent+19]=this.st_host
this.Control[iCurrent+20]=this.sle_host
this.Control[iCurrent+21]=this.st_port
this.Control[iCurrent+22]=this.sle_port
this.Control[iCurrent+23]=this.cbx_tls
this.Control[iCurrent+24]=this.cbx_log
this.Control[iCurrent+25]=this.mle_log
this.Control[iCurrent+26]=this.cb_token
this.Control[iCurrent+27]=this.cb_send
this.Control[iCurrent+28]=this.cb_signout
this.Control[iCurrent+29]=this.cb_cancel
this.Control[iCurrent+30]=this.cb_save
this.Control[iCurrent+31]=this.cb_close
this.Control[iCurrent+32]=this.gb_provider
this.Control[iCurrent+33]=this.gb_flow
this.Control[iCurrent+34]=this.gb_message
this.Control[iCurrent+35]=this.gb_server
end on

on w_smtpdemo.destroy
call super::destroy
destroy(this.gb_provider)
destroy(this.rb_microsoft)
destroy(this.rb_google)
destroy(this.st_tenant)
destroy(this.sle_tenant)
destroy(this.st_clientid)
destroy(this.sle_clientid)
destroy(this.st_secret)
destroy(this.sle_secret)
destroy(this.gb_flow)
destroy(this.rb_code)
destroy(this.rb_device)
destroy(this.rb_clientcredentials)
destroy(this.gb_message)
destroy(this.st_from)
destroy(this.sle_from)
destroy(this.st_to)
destroy(this.sle_to)
destroy(this.st_subject)
destroy(this.sle_subject)
destroy(this.mle_body)
destroy(this.gb_server)
destroy(this.st_host)
destroy(this.sle_host)
destroy(this.st_port)
destroy(this.sle_port)
destroy(this.cbx_tls)
destroy(this.cbx_log)
destroy(this.mle_log)
destroy(this.cb_token)
destroy(this.cb_send)
destroy(this.cb_signout)
destroy(this.cb_cancel)
destroy(this.cb_save)
destroy(this.cb_close)
end on

event open;call super::open;of_LoadSettings()
of_SetBusy(False)
of_Log("Register the application with the identity provider, enter its client ID (and secret), " + &
	"and the mailbox.  Save Settings keeps them in " + REGKEY + ".")
end event

event closequery;call super::closequery;// Don't close while the token service waits for the user: Cancel first
If Not cb_close.enabled Then Return 1
Return AncestorReturnValue
end event

event close;call super::close;If IsValid(inv_smtp) Then Destroy inv_smtp
end event

type gb_provider from u_gb within w_smtpdemo
integer x = 37
integer y = 24
integer width = 2533
integer height = 500
string text = "Identity provider"
end type

type rb_microsoft from u_rb within w_smtpdemo
integer x = 82
integer y = 96
integer width = 640
string text = "Microsoft Entra ID"
boolean checked = true
end type

event clicked;call super::clicked;of_LoadSettings()
end event

type rb_google from u_rb within w_smtpdemo
integer x = 750
integer y = 96
integer width = 400
string text = "Google"
end type

event clicked;call super::clicked;of_LoadSettings()
end event

type st_tenant from u_st within w_smtpdemo
integer x = 82
integer y = 204
integer width = 430
string text = "Tenant:"
end type

type sle_tenant from u_sle within w_smtpdemo
integer x = 530
integer y = 192
integer width = 1993
integer taborder = 10
end type

type st_clientid from u_st within w_smtpdemo
integer x = 82
integer y = 304
integer width = 430
string text = "Client ID:"
end type

type sle_clientid from u_sle within w_smtpdemo
integer x = 530
integer y = 292
integer width = 1993
integer taborder = 20
end type

type st_secret from u_st within w_smtpdemo
integer x = 82
integer y = 404
integer width = 430
string text = "Client secret:"
end type

type sle_secret from u_sle within w_smtpdemo
integer x = 530
integer y = 392
integer width = 1993
integer taborder = 30
boolean password = true
end type

type gb_flow from u_gb within w_smtpdemo
integer x = 37
integer y = 548
integer width = 2533
integer height = 176
string text = "Sign-in flow"
end type

type rb_code from u_rb within w_smtpdemo
integer x = 82
integer y = 620
integer width = 900
string text = "Authorization code (browser)"
boolean checked = true
end type

type rb_device from u_rb within w_smtpdemo
integer x = 1010
integer y = 620
integer width = 560
string text = "Device code"
end type

type rb_clientcredentials from u_rb within w_smtpdemo
integer x = 1600
integer y = 620
integer width = 900
string text = "Client credentials (no user)"
end type

type gb_message from u_gb within w_smtpdemo
integer x = 37
integer y = 748
integer width = 2533
integer height = 820
string text = "Message"
end type

type st_from from u_st within w_smtpdemo
integer x = 82
integer y = 832
integer width = 430
string text = "From (mailbox):"
end type

type sle_from from u_sle within w_smtpdemo
integer x = 530
integer y = 820
integer width = 1993
integer taborder = 40
end type

type st_to from u_st within w_smtpdemo
integer x = 82
integer y = 932
integer width = 430
string text = "To:"
end type

type sle_to from u_sle within w_smtpdemo
integer x = 530
integer y = 920
integer width = 1993
integer taborder = 50
end type

type st_subject from u_st within w_smtpdemo
integer x = 82
integer y = 1032
integer width = 430
string text = "Subject:"
end type

type sle_subject from u_sle within w_smtpdemo
integer x = 530
integer y = 1020
integer width = 1993
integer taborder = 60
string text = "PFC SMTP client test"
end type

type mle_body from u_mle within w_smtpdemo
integer x = 82
integer y = 1124
integer width = 2441
integer height = 412
integer taborder = 70
boolean vscrollbar = true
string text = "This message was sent with n_smtpclient and an OAuth 2.0 access token."
end type

type gb_server from u_gb within w_smtpdemo
integer x = 37
integer y = 1592
integer width = 2533
integer height = 176
string text = "SMTP server (empty: the provider's)"
end type

type st_host from u_st within w_smtpdemo
integer x = 82
integer y = 1676
integer width = 200
string text = "Host:"
end type

type sle_host from u_sle within w_smtpdemo
integer x = 290
integer y = 1664
integer width = 900
integer taborder = 80
end type

type st_port from u_st within w_smtpdemo
integer x = 1220
integer y = 1676
integer width = 160
string text = "Port:"
end type

type sle_port from u_sle within w_smtpdemo
integer x = 1390
integer y = 1664
integer width = 220
integer taborder = 90
end type

type cbx_tls from u_cbx within w_smtpdemo
integer x = 1650
integer y = 1672
integer width = 250
string text = "TLS"
boolean checked = true
end type

type cbx_log from u_cbx within w_smtpdemo
integer x = 1910
integer y = 1672
integer width = 640
string text = "Log the SMTP session"
end type

type mle_log from u_mle within w_smtpdemo
integer x = 37
integer y = 1796
integer width = 2533
integer height = 500
boolean vscrollbar = true
boolean autovscroll = true
boolean displayonly = true
end type

type cb_token from u_cb within w_smtpdemo
integer x = 37
integer y = 2324
integer width = 390
string text = "Get &Token"
end type

event clicked;call super::clicked;of_Authorize()
end event

type cb_send from u_cb within w_smtpdemo
integer x = 465
integer y = 2324
integer width = 390
string text = "&Send"
boolean default = true
end type

event clicked;call super::clicked;of_Send()
end event

type cb_signout from u_cb within w_smtpdemo
integer x = 893
integer y = 2324
integer width = 390
string text = "Sign &Out"
end type

event clicked;call super::clicked;// Forget the tokens: the next token needs a sign-in
If IsValid(inv_smtp) Then
	inv_smtp.inv_oauth2.of_Reset()
	of_Log("Signed out (tokens forgotten).")
End If
end event

type cb_cancel from u_cb within w_smtpdemo
integer x = 1321
integer y = 2324
integer width = 390
string text = "&Cancel"
end type

event clicked;call super::clicked;If IsValid(inv_smtp) Then inv_smtp.inv_oauth2.of_Cancel()
end event

type cb_save from u_cb within w_smtpdemo
integer x = 1749
integer y = 2324
integer width = 390
string text = "Save Settings"
end type

event clicked;call super::clicked;of_SaveSettings()
end event

type cb_close from u_cb within w_smtpdemo
integer x = 2177
integer y = 2324
integer width = 390
string text = "Close"
end type

event clicked;call super::clicked;Close(parent)
end event
