$PBExportHeader$pfc_n_smtpclient.sru
$PBExportComments$PFC SMTPClient class
forward
global type pfc_n_smtpclient from smtpclient
end type
end forward

global type pfc_n_smtpclient from smtpclient
end type
global pfc_n_smtpclient pfc_n_smtpclient

type variables
Public:
// AuthType values
Constant Integer AUTH_AUTODETECT = 0
Constant Integer AUTH_GSSAPI = 1
Constant Integer AUTH_LOGIN = 2
Constant Integer AUTH_NTLM = 3
Constant Integer AUTH_PLAIN = 4
Constant Integer AUTH_XOAUTH2 = 5
// of_Send: no access token could be obtained (see inv_oauth2.of_GetError())
Constant Integer AUTHORIZATIONFAILED = -100

// OAuth 2.0 token service (of_SetOAuth2)
n_cst_oauth2	inv_oauth2

Protected:
boolean		ib_IsObsolete
// The scope of_Authorize chose (the application didn't set one)
string		is_defaultscope
end variables

forward prototypes
protected function integer of_messagebox (string as_id, string as_title, string as_text, icon ae_icon, button ae_button, integer ai_default)
protected function integer of_messagebox (string as_id, string as_title, string as_text, string as_parms[], icon ae_icon, button ae_button, integer ai_default)
public function integer of_setoauth2 (boolean ab_switch)
public function integer of_setoauth2 (string as_provider, string as_clientid, string as_clientsecret)
public function integer of_setoauth2 (string as_provider, string as_tenant, string as_clientid, string as_clientsecret)
public function integer of_authorize ()
public function integer of_authorize (string as_flow)
public function integer of_setaccesstoken (string as_accesstoken)
public function integer of_send ()
protected function string of_defaultscope (string as_flow)
end prototypes

protected function integer of_messagebox (string as_id, string as_title, string as_text, icon ae_icon, button ae_button, integer ai_default);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  			of_MessageBox
//
//	Access:  			protected
//
//	Arguments:
//	as_id			An ID for the Message.
//	as_title  	Text for title bar
//	as_text		Text for the actual message.
//	ae_icon 		The icon you want to display on the MessageBox.
//	ae_button	Set of CommandButtons you want to display on the MessageBox.
//	ai_default  The default button.
//
//	Returns:  integer
//	Return value of the MessageBox.
//
//	Description:
//	Display a PowerScript MessageBox.  
//	Allow PFC MessageBoxes to be manipulated prior to their actual display.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2019 R2   Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2019, All rights reserved.
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

// Language service: the message from the language file, if there is one
If IsValid(gnv_app) Then
	If IsValid(gnv_app.inv_language) Then gnv_app.inv_language.of_GetMessage(as_id, as_title, as_text)
End If

Return MessageBox(as_title, as_text, ae_icon, ae_button, ai_default)
end function

protected function integer of_messagebox (string as_id, string as_title, string as_text, string as_parms[], icon ae_icon, button ae_button, integer ai_default);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  			of_MessageBox
//
//	Access:  			protected
//
//	Arguments:
//	as_id			An ID for the Message.
//	as_title  	Text for title bar
//	as_text		Text for the actual message, in English, with placeholders (%s) for
//					the values in as_parms.
//	as_parms[]	Values for the placeholders.
//	ae_icon 		The icon you want to display on the MessageBox.
//	ae_button	Set of CommandButtons you want to display on the MessageBox.
//	ai_default  The default button.
//
//	Returns:  integer
//	Return value of the MessageBox.
//
//	Description:
//	Display a message that contains values.  With the language service, the message
//	comes from the language file (the entry as_id) when it has one; the values replace
//	the placeholders (see n_cst_string.of_Format).  The message is then displayed by
//	of_MessageBox(as_id, as_title, as_text, ae_icon, ae_button, ai_default).
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

n_cst_string	lnv_string

If IsValid(gnv_app) Then
	If IsValid(gnv_app.inv_language) Then
		gnv_app.inv_language.of_GetMessage(as_id, as_title, as_text, as_parms)
		Return of_MessageBox(as_id, as_title, as_text, ae_icon, ae_button, ai_default)
	End If
End If

Return of_MessageBox(as_id, as_title, lnv_string.of_Format(as_text, as_parms), ae_icon, ae_button, ai_default)
end function

public function integer of_setoauth2 (boolean ab_switch);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetOAuth2
//
//	Access:  public
//
//	Arguments:
//	ab_switch	True to start the OAuth 2.0 token service (inv_oauth2), False to stop it
//
//	Returns:  Integer.  1 = success, 0 = no action needed
//
//	Description:  Starts or stops the token service.  Set it up (inv_oauth2.of_SetProvider
//		or of_SetEndpoints, of_SetClient, and optionally of_SetFlow and of_SetScope), and
//		of_Authorize or of_Send gets the token.  See also of_SetOAuth2(string, string, string).
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

If ab_switch Then
	If IsValid(inv_oauth2) Then Return 0
	inv_oauth2 = Create n_cst_oauth2
	is_defaultscope = ""
	Return 1
End If

If Not IsValid(inv_oauth2) Then Return 0
Destroy inv_oauth2
Return 1
end function

public function integer of_setoauth2 (string as_provider, string as_clientid, string as_clientsecret);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetOAuth2
//
//	Access:  public
//
//	Arguments:
//	as_provider			n_cst_oauth2.MICROSOFT ("microsoft") or n_cst_oauth2.GOOGLE ("google")
//	as_clientid			the application's client ID
//	as_clientsecret	its client secret, or "" (Microsoft public clients)
//
//	Returns:  Integer.  1 = success, -1 = the provider is unknown
//
//	Description:  See of_SetOAuth2(string, string, string, string).  For Microsoft the
//		tenant is "common".
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

Return of_SetOAuth2(as_provider, "", as_clientid, as_clientsecret)
end function

public function integer of_setoauth2 (string as_provider, string as_tenant, string as_clientid, string as_clientsecret);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetOAuth2
//
//	Access:  public
//
//	Arguments:
//	as_provider			n_cst_oauth2.MICROSOFT ("microsoft") or n_cst_oauth2.GOOGLE ("google")
//	as_tenant			Microsoft: the tenant ID or domain ("" for "common"); not used for Google
//	as_clientid			the application's client ID
//	as_clientsecret	its client secret, or "" (Microsoft public clients)
//
//	Returns:  Integer.  1 = success, -1 = the provider is unknown
//
//	Description:  Starts the token service for a well-known identity provider (see
//		n_cst_oauth2.of_SetProvider), and, when Host is empty, sets the provider's SMTP
//		server: smtp.office365.com or smtp.gmail.com, port 587, with STARTTLS.  The flow is
//		the authorization code flow; change it with inv_oauth2.of_SetFlow.
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

of_SetOAuth2(True)
If inv_oauth2.of_SetProvider(as_provider, as_tenant) <> 1 Then Return -1
inv_oauth2.of_SetClient(as_clientid, as_clientsecret)

If IsNull(Host) Or Trim(Host) = "" Then
	Choose Case inv_oauth2.of_GetProvider()
		Case inv_oauth2.MICROSOFT
			Host = "smtp.office365.com"
		Case inv_oauth2.GOOGLE
			Host = "smtp.gmail.com"
	End Choose
	Port = 587
	EnableTLS = True
End If

Return 1
end function

public function integer of_authorize ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Authorize
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Integer.  See of_Authorize(string)
//
//	Description:  Gets an access token with the token service's flow (inv_oauth2.of_SetFlow).
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

If Not IsValid(inv_oauth2) Then Return -6
Return of_Authorize(inv_oauth2.of_GetFlow())
end function

public function integer of_authorize (string as_flow);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Authorize
//
//	Access:  public
//
//	Arguments:
//	as_flow		n_cst_oauth2.AUTHORIZATIONCODE, DEVICECODE or CLIENTCREDENTIALS
//
//	Returns:  Integer
//	 1 = the access token is set (AuthType is AUTH_XOAUTH2)
//	 0 = the user cancelled
//	-1 to -6 = no token: see n_cst_oauth2.of_Authorize(string) and inv_oauth2.of_GetError()
//
//	Description:  Gets a valid access token from the token service (signing the user in
//		only when needed; see n_cst_oauth2.of_Authorize) and uses it to authenticate with
//		XOAUTH2.  When the application hasn't set a scope, the scope for SMTP of the
//		provider is used.  UserName is the mailbox; when it is set, the sign-in page starts
//		with it, and when it isn't, the login hint is used.
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

string	ls_scope
integer	li_rc

If Not IsValid(inv_oauth2) Then Return -6

// The scope for SMTP, unless the application set one; it depends on the flow
If inv_oauth2.of_GetScope() = "" Or inv_oauth2.of_GetScope() = is_defaultscope Then
	ls_scope = of_DefaultScope(as_flow)
	If ls_scope <> "" Then
		inv_oauth2.of_SetScope(ls_scope)
		is_defaultscope = ls_scope
	End If
End If

If IsNull(UserName) Then UserName = ""
If UserName <> "" And inv_oauth2.of_GetLoginHint() = "" Then inv_oauth2.of_SetLoginHint(UserName)

li_rc = inv_oauth2.of_Authorize(as_flow)
If li_rc <> 1 Then Return li_rc

If UserName = "" Then UserName = inv_oauth2.of_GetLoginHint()
Return of_SetAccessToken(inv_oauth2.of_GetAccessToken())
end function

public function integer of_setaccesstoken (string as_accesstoken);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetAccessToken
//
//	Access:  public
//
//	Arguments:
//	as_accesstoken		an OAuth 2.0 access token for the mailbox UserName
//
//	Returns:  Integer.  1 = success, -1 = the token is empty
//
//	Description:  Authenticates with XOAUTH2 and this token, for a token the application
//		got itself.
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

If IsNull(as_accesstoken) Or as_accesstoken = "" Then Return -1

AuthType = AUTH_XOAUTH2
XOAuth2AccessToken = as_accesstoken
Return 1
end function

public function integer of_send ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Send
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Integer.  The return value of Send, or AUTHORIZATIONFAILED (-100) if the token
//		service is on and no access token could be obtained (inv_oauth2.of_GetError())
//
//	Description:  Sends the message.  With the token service, gets a valid access token
//		first (of_Authorize), so an object that sends several messages refreshes the
//		token when it expires.
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

If IsValid(inv_oauth2) Then
	If of_Authorize() <> 1 Then Return AUTHORIZATIONFAILED
End If

Return Send()
end function

protected function string of_defaultscope (string as_flow);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_DefaultScope
//
//	Access:  protected
//
//	Arguments:
//	as_flow		the flow
//
//	Returns:  String.  The scope for sending mail with SMTP for the token service's
//		identity provider, or "" for other providers
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

If IsNull(as_flow) Then as_flow = ""

Choose Case inv_oauth2.of_GetProvider()
	Case inv_oauth2.MICROSOFT
		// Application permissions are requested as <resource>/.default
		If Lower(Trim(as_flow)) = inv_oauth2.CLIENTCREDENTIALS Then Return "https://outlook.office365.com/.default"
		Return "https://outlook.office.com/SMTP.Send offline_access"
	Case inv_oauth2.GOOGLE
		Return "https://mail.google.com/"
End Choose

Return ""
end function

on pfc_n_smtpclient.create
call super::create
TriggerEvent( this, "constructor" )
end on

on pfc_n_smtpclient.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event destructor;If IsValid(inv_oauth2) Then Destroy inv_oauth2
end event
