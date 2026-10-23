$PBExportHeader$pfc_n_cst_oauth2.sru
$PBExportComments$PFC OAuth 2.0 token service
forward
global type pfc_n_cst_oauth2 from n_base
end type
end forward

global type pfc_n_cst_oauth2 from n_base
event type long pfc_openbrowser ( string as_url )
event type long pfc_devicecode ( string as_usercode, string as_verificationuri, string as_message )
end type
global pfc_n_cst_oauth2 pfc_n_cst_oauth2

type prototypes
// Cryptographically random bytes (BCRYPT_USE_SYSTEM_PREFERRED_RNG = 2)
Function long BCryptGenRandom (longptr al_algorithm, ref blob ablb_buffer, ulong aul_length, ulong aul_flags) Library "bcrypt.dll"
Subroutine oa_Sleep (ulong aul_milliseconds) Library "kernel32.dll" Alias For "Sleep"
end prototypes

type variables
Public:
// Identity providers with built-in endpoints (of_SetProvider)
Constant String MICROSOFT = "microsoft"
Constant String GOOGLE = "google"
// Flows (of_SetFlow, of_Authorize)
Constant String AUTHORIZATIONCODE = "code"
Constant String DEVICECODE = "device"
Constant String CLIENTCREDENTIALS = "client_credentials"

Protected:
// Settings
string	is_provider
string	is_authorizationendpoint
string	is_tokenendpoint
string	is_deviceendpoint
string	is_clientid
string	is_clientsecret
string	is_scope
string	is_loginhint
// Other parameters of the authorization request, for example "prompt=select_account"
string	is_parameters
string	is_flow = "code"
string	is_redirectpath = "/callback"
// How long to wait for the user to sign in, in seconds
long		il_timeout = 300
// A token that expires within this many seconds counts as expired (of_IsExpired)
long		il_margin = 60

// Results
string	is_accesstoken
string	is_refreshtoken
string	is_idtoken
string	is_tokentype
datetime	idt_expires
// The last error: its code (for example invalid_grant) and description
string	is_errorcode
string	is_error
// The last response of the identity provider
string	is_response

// Device code flow: the code the user enters, and where
string	is_usercode
string	is_verificationuri

boolean	ib_cancel
n_cst_redirectlistener	inv_listener
end variables

forward prototypes
public function integer of_setprovider (string as_provider)
public function integer of_setprovider (string as_provider, string as_tenant)
public function string of_getprovider ()
public subroutine of_setendpoints (string as_authorization, string as_token, string as_deviceauthorization)
public subroutine of_setclient (string as_clientid)
public subroutine of_setclient (string as_clientid, string as_clientsecret)
public function string of_getclientid ()
public subroutine of_setscope (string as_scope)
public function string of_getscope ()
public subroutine of_setloginhint (string as_loginhint)
public function string of_getloginhint ()
public subroutine of_setparameters (string as_parameters)
public function integer of_setflow (string as_flow)
public function string of_getflow ()
public function integer of_setredirectpath (string as_path)
public subroutine of_settimeout (long al_seconds)
public subroutine of_setrefreshtoken (string as_refreshtoken)
public function string of_getaccesstoken ()
public function string of_getrefreshtoken ()
public function string of_getidtoken ()
public function datetime of_getexpires ()
public function boolean of_isexpired ()
public function string of_geterror ()
public function string of_geterrorcode ()
public function string of_getresponse ()
public function string of_getusercode ()
public function string of_getverificationuri ()
public subroutine of_reset ()
public subroutine of_cancel ()
public function integer of_authorize ()
public function integer of_authorize (string as_flow)
public function integer of_authorizationcode ()
public function integer of_devicecode ()
public function integer of_clientcredentials ()
public function integer of_refresh ()
protected function integer of_post (string as_url, string as_body, ref long al_status, ref string as_response)
protected function integer of_tokenrequest (string as_body)
protected function integer of_parsetoken (string as_json)
protected subroutine of_seterror (string as_json, long al_status)
protected function integer of_notconfigured (string as_what)
protected function boolean of_pause (long al_milliseconds)
protected function string of_authorizationurl (string as_redirecturi, string as_state, string as_challenge)
public function string of_urlencode (string as_value)
public function string of_randomstring (integer ai_bytes)
public function string of_base64url (blob ablb_data)
public function string of_codechallenge (string as_verifier)
public function string of_jsonstring (string as_json, string as_key)
public function long of_jsonnumber (string as_json, string as_key)
protected function datetime of_addseconds (datetime adt_datetime, long al_seconds)
protected function string of_text (string as_id, string as_default, string as_parms[])
end prototypes

event type long pfc_openbrowser (string as_url);//////////////////////////////////////////////////////////////////////////////
//
//	Event:  pfc_OpenBrowser
//
//	Arguments:
//	as_url		the authorization request, or the device code flow's verification page
//
//	Returns:  Long.  1 if the page was opened, -1 if not
//
//	Description:  Opens the page in the user's default web browser.  Override it to show
//		the page somewhere else.
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

inet	linet

If GetContextService("Internet", linet) <> 1 Then Return -1
If linet.HyperlinkToURL(as_url) <> 1 Then Return -1
Return 1
end event

event type long pfc_devicecode (string as_usercode, string as_verificationuri, string as_message);//////////////////////////////////////////////////////////////////////////////
//
//	Event:  pfc_DeviceCode
//
//	Arguments:
//	as_usercode				the code the user enters
//	as_verificationuri	the page where the user enters it
//	as_message				the identity provider's instructions, if it sent any (Microsoft
//								Entra ID does, in the language of the request)
//
//	Returns:  Long.  1 to wait for the user to sign in, 0 to cancel
//
//	Description:  Device code flow (RFC 8628): tells the user to sign in.  By default the
//		code is copied to the clipboard, the page opens in the web browser and a message
//		tells the user what to do; Cancel cancels the sign-in.  Override it to show the
//		code in a window of the application, or on another device.
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

string	ls_parms[]

Clipboard(as_usercode)
this.event pfc_OpenBrowser(as_verificationuri)

ls_parms[1] = as_usercode
ls_parms[2] = as_verificationuri
If of_MessageBox("pfc_oauth2_devicecode", "Sign In", &
	"Enter the code %s in the web page that opened (%s) and sign in.~r~n~r~nThe code is on the clipboard.", &
	ls_parms, Information!, OKCancel!, 1) = 2 Then Return 0
Return 1
end event

public function integer of_setprovider (string as_provider);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetProvider
//
//	Access:  public
//
//	Arguments:
//	as_provider		MICROSOFT ("microsoft") or GOOGLE ("google")
//
//	Returns:  Integer.  1 if the endpoints were set, -1 if the provider is unknown
//
//	Description:  Sets the endpoints of a well-known identity provider.  For Microsoft
//		Entra ID, the tenant is "common" (work, school and personal accounts); see
//		of_SetProvider(string, string).
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

Return of_SetProvider(as_provider, "")
end function

public function integer of_setprovider (string as_provider, string as_tenant);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetProvider
//
//	Access:  public
//
//	Arguments:
//	as_provider		MICROSOFT ("microsoft") or GOOGLE ("google")
//	as_tenant		Microsoft Entra ID: the tenant (its ID or domain, or "common",
//						"organizations" or "consumers"); "" for "common".  Not used for Google.
//
//	Returns:  Integer.  1 if the endpoints were set, -1 if the provider is unknown
//
//	Description:  Sets the authorization, token and device authorization endpoints of a
//		well-known identity provider.  Other providers: see of_SetEndpoints.
//
//		Microsoft Entra ID: register the application as a public client ("Mobile and
//		desktop applications") with the redirect URI http://127.0.0.1 (the port doesn't
//		matter); the client credentials flow needs a client secret instead.
//
//		Google: create an OAuth client of the "Desktop app" type.  Google wants its client
//		secret in the token requests even then (it isn't secret in a desktop application).
//		The authorization request asks for a refresh token (access_type=offline).  Google's
//		device code flow allows only a few scopes, and not the one for Gmail.
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

string	ls_base

Choose Case Lower(Trim(as_provider))
	Case MICROSOFT
		If IsNull(as_tenant) Or Trim(as_tenant) = "" Then as_tenant = "common"
		ls_base = "https://login.microsoftonline.com/" + Trim(as_tenant) + "/oauth2/v2.0/"
		of_SetEndpoints(ls_base + "authorize", ls_base + "token", ls_base + "devicecode")
		is_provider = MICROSOFT
	Case GOOGLE
		of_SetEndpoints("https://accounts.google.com/o/oauth2/v2/auth", &
			"https://oauth2.googleapis.com/token", "https://oauth2.googleapis.com/device/code")
		If is_parameters = "" Then is_parameters = "access_type=offline"
		is_provider = GOOGLE
	Case Else
		Return -1
End Choose

Return 1
end function

public function string of_getprovider ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetProvider
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  MICROSOFT, GOOGLE, or "" when the endpoints were set with of_SetEndpoints
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

Return is_provider
end function

public subroutine of_setendpoints (string as_authorization, string as_token, string as_deviceauthorization);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetEndpoints
//
//	Access:  public
//
//	Arguments:
//	as_authorization			the authorization endpoint (authorization code flow)
//	as_token						the token endpoint (all flows)
//	as_deviceauthorization	the device authorization endpoint (device code flow)
//
//	Returns:  None
//
//	Description:  Sets the endpoints of the identity provider.  Leave out ("") the ones
//		the flows you use don't need.  Most providers publish them in their OpenID
//		configuration (.well-known/openid-configuration).
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

If IsNull(as_authorization) Then as_authorization = ""
If IsNull(as_token) Then as_token = ""
If IsNull(as_deviceauthorization) Then as_deviceauthorization = ""

is_authorizationendpoint = Trim(as_authorization)
is_tokenendpoint = Trim(as_token)
is_deviceendpoint = Trim(as_deviceauthorization)
is_provider = ""
end subroutine

public subroutine of_setclient (string as_clientid);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetClient
//
//	Access:  public
//
//	Arguments:
//	as_clientid		the application's client ID
//
//	Returns:  None
//
//	Description:  Sets the client ID of a public client (no client secret).
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

of_SetClient(as_clientid, "")
end subroutine

public subroutine of_setclient (string as_clientid, string as_clientsecret);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetClient
//
//	Access:  public
//
//	Arguments:
//	as_clientid			the application's client ID
//	as_clientsecret	its client secret, or "" for a public client
//
//	Returns:  None
//
//	Description:  Sets the application's registration with the identity provider.  The
//		client credentials flow needs the secret; when there is one, it goes in every
//		token request.  Don't put a secret in the source: read it from the registry or a
//		file that isn't distributed with the application.
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

If IsNull(as_clientid) Then as_clientid = ""
If IsNull(as_clientsecret) Then as_clientsecret = ""

is_clientid = Trim(as_clientid)
is_clientsecret = as_clientsecret
end subroutine

public function string of_getclientid ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetClientID
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The client ID
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

Return is_clientid
end function

public subroutine of_setscope (string as_scope);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetScope
//
//	Access:  public
//
//	Arguments:
//	as_scope		the scopes to request, separated by spaces, for example
//					"https://outlook.office.com/SMTP.Send offline_access"
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

If IsNull(as_scope) Then as_scope = ""
is_scope = Trim(as_scope)
end subroutine

public function string of_getscope ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetScope
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The scopes to request
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

Return is_scope
end function

public subroutine of_setloginhint (string as_loginhint);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetLoginHint
//
//	Access:  public
//
//	Arguments:
//	as_loginhint	the user's account (for example an email address), or ""
//
//	Returns:  None
//
//	Description:  Authorization code flow: the sign-in page starts with this account.
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

If IsNull(as_loginhint) Then as_loginhint = ""
is_loginhint = Trim(as_loginhint)
end subroutine

public function string of_getloginhint ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetLoginHint
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The login hint
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

Return is_loginhint
end function

public subroutine of_setparameters (string as_parameters);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetParameters
//
//	Access:  public
//
//	Arguments:
//	as_parameters	other parameters of the authorization request, URL encoded, for
//						example "prompt=select_account" or "access_type=offline&prompt=consent"
//
//	Returns:  None
//
//	Description:  Authorization code flow: parameters that only some identity providers
//		understand.  of_SetProvider(GOOGLE) sets "access_type=offline" when there are none.
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

If IsNull(as_parameters) Then as_parameters = ""
as_parameters = Trim(as_parameters)
If Left(as_parameters, 1) = "&" Then as_parameters = Mid(as_parameters, 2)
is_parameters = as_parameters
end subroutine

public function integer of_setflow (string as_flow);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetFlow
//
//	Access:  public
//
//	Arguments:
//	as_flow		AUTHORIZATIONCODE ("code", the default), DEVICECODE ("device") or
//					CLIENTCREDENTIALS ("client_credentials")
//
//	Returns:  Integer.  1 if the flow was set, -1 if it is unknown
//
//	Description:  The flow of_Authorize uses to get a token when there is no valid one
//		and none can be refreshed.
//		- AUTHORIZATIONCODE: the user signs in in the web browser (with PKCE; the redirect
//		  comes back to this computer, see n_cst_redirectlistener).
//		- DEVICECODE: the user signs in in a web browser, on this or another device, with
//		  a code the application shows (RFC 8628).  For computers without a browser.
//		- CLIENTCREDENTIALS: no user; the application signs in with its own secret.
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

If IsNull(as_flow) Then Return -1

Choose Case Lower(Trim(as_flow))
	Case AUTHORIZATIONCODE, DEVICECODE, CLIENTCREDENTIALS
		is_flow = Lower(Trim(as_flow))
		Return 1
End Choose

Return -1
end function

public function string of_getflow ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetFlow
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The flow of_Authorize uses
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

Return is_flow
end function

public function integer of_setredirectpath (string as_path);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetRedirectPath
//
//	Access:  public
//
//	Arguments:
//	as_path		the path of the redirect URI, for example "/callback" (the default)
//
//	Returns:  Integer.  1 if it was set, -1 if it doesn't start with "/"
//
//	Description:  Authorization code flow: the redirect URI is http://127.0.0.1:<port><path>,
//		with a port Windows chooses.  Register it with the identity provider.
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

If IsNull(as_path) Or Left(as_path, 1) <> "/" Then Return -1
is_redirectpath = as_path
Return 1
end function

public subroutine of_settimeout (long al_seconds);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetTimeout
//
//	Access:  public
//
//	Arguments:
//	al_seconds		how long to wait for the user to sign in (default 300)
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

If al_seconds > 0 Then il_timeout = al_seconds
end subroutine

public subroutine of_setrefreshtoken (string as_refreshtoken);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetRefreshToken
//
//	Access:  public
//
//	Arguments:
//	as_refreshtoken	a refresh token from an earlier session (of_GetRefreshToken)
//
//	Returns:  None
//
//	Description:  Lets of_Authorize get a new access token without asking the user to sign
//		in again.  The access token is cleared.  A refresh token is a password: if you keep
//		it, keep it encrypted for the user (for example with CrypterObject).
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

If IsNull(as_refreshtoken) Then as_refreshtoken = ""
is_refreshtoken = as_refreshtoken
is_accesstoken = ""
is_idtoken = ""
SetNull(idt_expires)
end subroutine

public function string of_getaccesstoken ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetAccessToken
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The access token, or "" if there is none.  See of_IsExpired.
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

Return is_accesstoken
end function

public function string of_getrefreshtoken ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetRefreshToken
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The refresh token, or "" if the identity provider didn't send one
//		(Microsoft Entra ID sends one for the offline_access scope; Google for access_type=offline)
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

Return is_refreshtoken
end function

public function string of_getidtoken ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetIDToken
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The ID token (for the openid scope), or ""
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

Return is_idtoken
end function

public function datetime of_getexpires ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetExpires
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  DateTime.  When the access token expires (local time), or null if it isn't known
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

Return idt_expires
end function

public function boolean of_isexpired ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_IsExpired
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Boolean.  True if there is no access token or it expires within a minute;
//		False if it is valid (or the identity provider didn't say when it expires)
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

datetime	ldt_now
long		ll_left

If is_accesstoken = "" Then Return True
If IsNull(idt_expires) Then Return False

ldt_now = DateTime(Today(), Now())
ll_left = DaysAfter(Date(ldt_now), Date(idt_expires)) * 86400 + SecondsAfter(Time(ldt_now), Time(idt_expires))
Return ll_left <= il_margin
end function

public function string of_geterror ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetError
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  Why the last request failed: the identity provider's description of
//		the error, or its error code, or ""
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

Return is_error
end function

public function string of_geterrorcode ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetErrorCode
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The identity provider's error code (RFC 6749, section 5.2, for
//		example invalid_grant), or ""
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

Return is_errorcode
end function

public function string of_getresponse ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetResponse
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The identity provider's last response (for diagnostics; it can contain tokens)
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

Return is_response
end function

public function string of_getusercode ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetUserCode
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  Device code flow: the code the user enters
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

Return is_usercode
end function

public function string of_getverificationuri ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetVerificationURI
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  Device code flow: the page where the user enters the code
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

Return is_verificationuri
end function

public subroutine of_reset ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Reset
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Forgets the tokens (signs out of the application, not of the identity provider).
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

is_accesstoken = ""
is_refreshtoken = ""
is_idtoken = ""
is_tokentype = ""
SetNull(idt_expires)
is_errorcode = ""
is_error = ""
is_response = ""
end subroutine

public subroutine of_cancel ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Cancel
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Stops waiting for the user to sign in, for example from a Cancel button:
//		of_AuthorizationCode or of_DeviceCode returns 0.
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

ib_cancel = True
If IsValid(inv_listener) Then inv_listener.of_Cancel()
end subroutine

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
//	Description:  Gets a valid access token with the flow set with of_SetFlow.
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

Return of_Authorize(is_flow)
end function

public function integer of_authorize (string as_flow);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Authorize
//
//	Access:  public
//
//	Arguments:
//	as_flow		AUTHORIZATIONCODE, DEVICECODE or CLIENTCREDENTIALS (see of_SetFlow)
//
//	Returns:  Integer
//	 1 = there is a valid access token (of_GetAccessToken)
//	 0 = the user cancelled
//	-1 = the identity provider refused (of_GetError)
//	-2 = the identity provider could not be reached
//	-3 = the browser could not be opened, or the redirect could not be received
//	-4 = the user didn't sign in in time (of_SetTimeout)
//	-5 = the identity provider's response is not valid
//	-6 = a setting the flow needs is missing (of_GetError says which), or the flow is unknown
//
//	Description:  Gets a valid access token, asking the user to sign in only when needed:
//		the token it has, if it hasn't expired; or a new one for the refresh token; or
//		one from the flow.  Call it before each use of the token.
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

If Not of_IsExpired() Then Return 1

If is_refreshtoken <> "" Then
	li_rc = of_Refresh()
	// When the identity provider can't be reached, signing in wouldn't work either
	If li_rc = 1 Or li_rc = -2 Then Return li_rc
End If

If IsNull(as_flow) Then as_flow = ""
Choose Case Lower(Trim(as_flow))
	Case AUTHORIZATIONCODE
		Return of_AuthorizationCode()
	Case DEVICECODE
		Return of_DeviceCode()
	Case CLIENTCREDENTIALS
		Return of_ClientCredentials()
End Choose

Return of_NotConfigured("flow")
end function

public function integer of_authorizationcode ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_AuthorizationCode
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Integer.  See of_Authorize(string)
//
//	Description:  Gets a token with the OAuth 2.0 authorization code flow with PKCE
//		(RFC 7636): the user signs in in the web browser (pfc_OpenBrowser), which supports
//		multi-factor authentication and single sign-on.  The redirect comes back to this
//		computer (n_cst_redirectlistener, RFC 8252).  The application stays responsive
//		while it waits; of_Cancel stops the wait.
//		Needs the client ID and the authorization and token endpoints.
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

string	ls_verifier, ls_state, ls_url, ls_redirecturi, ls_code, ls_none[]
integer	li_rc

is_errorcode = ""
is_error = ""
ib_cancel = False
If is_clientid = "" Then Return of_NotConfigured("client ID")
If is_authorizationendpoint = "" Then Return of_NotConfigured("authorization endpoint")
If is_tokenendpoint = "" Then Return of_NotConfigured("token endpoint")

// Listen before opening the browser, so the redirect can't arrive too early
If IsValid(inv_listener) Then Destroy inv_listener
inv_listener = Create n_cst_redirectlistener
If inv_listener.of_Start(is_redirectpath) <> 1 Then Return -3
inv_listener.of_SetPage( &
	of_Text("pfc_openidlogon_pagetitle", "Sign-in complete", ls_none), &
	of_Text("pfc_openidlogon_pagemessage", "You can close this window and return to the application.", ls_none))
ls_redirecturi = inv_listener.of_GetRedirectURI()

ls_verifier = of_RandomString(32)
ls_state = of_RandomString(16)
If ls_verifier = "" Or ls_state = "" Then
	inv_listener.of_Stop()
	Return -3
End If

ls_url = of_AuthorizationURL(ls_redirecturi, ls_state, of_CodeChallenge(ls_verifier))
If this.event pfc_OpenBrowser(ls_url) <> 1 Then
	inv_listener.of_Stop()
	Return -3
End If

li_rc = inv_listener.of_Wait(il_timeout)
If ib_cancel Then li_rc = 0
If li_rc <> 1 Then
	inv_listener.of_Stop()
	If ib_cancel Then Return 0
	If li_rc = 0 Then Return -4
	Return -3
End If

is_response = inv_listener.of_GetRequest()
If inv_listener.of_GetParameter("state") <> ls_state Then
	inv_listener.of_Stop()
	Return -5
End If
If inv_listener.of_GetParameter("error") <> "" Then
	is_errorcode = inv_listener.of_GetParameter("error")
	is_error = inv_listener.of_GetParameter("error_description")
	If is_error = "" Then is_error = is_errorcode
	inv_listener.of_Stop()
	Return -1
End If
ls_code = inv_listener.of_GetParameter("code")
inv_listener.of_Stop()

// Exchange the code, with the code verifier, for the tokens
SetPointer(HourGlass!)
Return of_TokenRequest("grant_type=authorization_code" + &
	"&code=" + of_UrlEncode(ls_code) + &
	"&redirect_uri=" + of_UrlEncode(ls_redirecturi) + &
	"&client_id=" + of_UrlEncode(is_clientid) + &
	"&code_verifier=" + of_UrlEncode(ls_verifier))
end function

public function integer of_devicecode ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_DeviceCode
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Integer.  See of_Authorize(string)
//
//	Description:  Gets a token with the OAuth 2.0 device authorization grant (RFC 8628):
//		the identity provider gives a code, pfc_DeviceCode tells the user to enter it on
//		the provider's page, and the token endpoint is polled until the user has signed in.
//		The application stays responsive while it waits; of_Cancel stops the wait.
//		Needs the client ID and the device authorization and token endpoints.
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

string	ls_response, ls_devicecode, ls_message
long		ll_status, ll_interval, ll_expires, ll_end
integer	li_rc

is_errorcode = ""
is_error = ""
is_usercode = ""
is_verificationuri = ""
ib_cancel = False
If is_clientid = "" Then Return of_NotConfigured("client ID")
If is_deviceendpoint = "" Then Return of_NotConfigured("device authorization endpoint")
If is_tokenendpoint = "" Then Return of_NotConfigured("token endpoint")

SetPointer(HourGlass!)
If of_Post(is_deviceendpoint, "client_id=" + of_UrlEncode(is_clientid) + &
	"&scope=" + of_UrlEncode(is_scope), ll_status, ls_response) <> 1 Then Return -2
is_response = ls_response
If ll_status <> 200 Then
	of_SetError(ls_response, ll_status)
	Return -1
End If

ls_devicecode = of_JsonString(ls_response, "device_code")
is_usercode = of_JsonString(ls_response, "user_code")
is_verificationuri = of_JsonString(ls_response, "verification_uri")
// Google's name for it
If is_verificationuri = "" Then is_verificationuri = of_JsonString(ls_response, "verification_url")
ls_message = of_JsonString(ls_response, "message")
ll_interval = of_JsonNumber(ls_response, "interval")
If ll_interval < 1 Then ll_interval = 5
ll_expires = of_JsonNumber(ls_response, "expires_in")
If ll_expires < 1 Or ll_expires > il_timeout Then ll_expires = il_timeout
If ls_devicecode = "" Or is_usercode = "" Or is_verificationuri = "" Then Return -5

If this.event pfc_DeviceCode(is_usercode, is_verificationuri, ls_message) <> 1 Then Return 0

ll_end = CPU() + ll_expires * 1000
Do
	If Not of_Pause(ll_interval * 1000) Then Return 0

	li_rc = of_TokenRequest("grant_type=" + of_UrlEncode("urn:ietf:params:oauth:grant-type:device_code") + &
		"&device_code=" + of_UrlEncode(ls_devicecode) + &
		"&client_id=" + of_UrlEncode(is_clientid))
	If li_rc <> -1 Then Return li_rc

	Choose Case is_errorcode
		Case "authorization_pending"
			// the user hasn't signed in yet
		Case "slow_down"
			ll_interval += 5
		Case Else
			// access_denied, expired_token, ...
			Return -1
	End Choose
Loop While CPU() < ll_end

is_errorcode = ""
is_error = ""
Return -4
end function

public function integer of_clientcredentials ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ClientCredentials
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Integer.  See of_Authorize(string)
//
//	Description:  Gets a token with the OAuth 2.0 client credentials grant: the application
//		signs in as itself, with its client secret; no user is involved.  For Microsoft
//		Entra ID the scope is "<resource>/.default", and the application needs application
//		permissions (for SMTP, also an Exchange Online service principal with access to the
//		mailbox).  Needs the client ID, the client secret and the token endpoint.
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

is_errorcode = ""
is_error = ""
If is_clientid = "" Then Return of_NotConfigured("client ID")
If is_clientsecret = "" Then Return of_NotConfigured("client secret")
If is_tokenendpoint = "" Then Return of_NotConfigured("token endpoint")

SetPointer(HourGlass!)
Return of_TokenRequest("grant_type=client_credentials" + &
	"&client_id=" + of_UrlEncode(is_clientid) + &
	"&scope=" + of_UrlEncode(is_scope))
end function

public function integer of_refresh ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Refresh
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Integer.  See of_Authorize(string); -6 if there is no refresh token
//
//	Description:  Gets a new access token for the refresh token, without the user.  If the
//		identity provider refuses it (it expired, or was revoked), the refresh token is
//		cleared, so that of_Authorize asks the user to sign in.
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

string	ls_body
integer	li_rc

is_errorcode = ""
is_error = ""
If is_refreshtoken = "" Then Return of_NotConfigured("refresh token")
If is_clientid = "" Then Return of_NotConfigured("client ID")
If is_tokenendpoint = "" Then Return of_NotConfigured("token endpoint")

ls_body = "grant_type=refresh_token" + &
	"&refresh_token=" + of_UrlEncode(is_refreshtoken) + &
	"&client_id=" + of_UrlEncode(is_clientid)
// Microsoft Entra ID wants the scope; Google refreshes the scopes of the grant
If is_scope <> "" And is_provider <> GOOGLE Then ls_body += "&scope=" + of_UrlEncode(is_scope)

SetPointer(HourGlass!)
li_rc = of_TokenRequest(ls_body)
If li_rc = -1 Then is_refreshtoken = ""
Return li_rc
end function

protected function integer of_post (string as_url, string as_body, ref long al_status, ref string as_response);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Post
//
//	Access:  protected
//
//	Arguments:
//	as_url			the endpoint
//	as_body			the form, URL encoded
//	al_status		(by reference) the HTTP status code of the response
//	as_response		(by reference) the response body
//
//	Returns:  Integer.  1 if there is a response, -1 if the endpoint could not be reached
//
//	Description:  Posts a form to the identity provider (with HTTPClient).
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

HTTPClient	lnv_httpclient
integer		li_rc

al_status = 0
as_response = ""

lnv_httpclient = Create HTTPClient
lnv_httpclient.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
lnv_httpclient.SetRequestHeader("Accept", "application/json")

If lnv_httpclient.SendRequest("POST", as_url, as_body) = 1 Then
	al_status = lnv_httpclient.GetResponseStatusCode()
	lnv_httpclient.GetResponseBody(as_response)
	li_rc = 1
Else
	li_rc = -1
End If

Destroy lnv_httpclient
Return li_rc
end function

protected function integer of_tokenrequest (string as_body);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_TokenRequest
//
//	Access:  protected
//
//	Arguments:
//	as_body		the token request's form (without the client secret)
//
//	Returns:  Integer
//	 1 = the tokens were received
//	-1 = the identity provider refused (of_GetErrorCode, of_GetError)
//	-2 = the token endpoint could not be reached
//	-5 = the response has no access token
//
//	Description:  Sends a request to the token endpoint, with the client secret when there is one.
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

string	ls_response
long		ll_status

If is_clientsecret <> "" Then as_body += "&client_secret=" + of_UrlEncode(is_clientsecret)

If of_Post(is_tokenendpoint, as_body, ll_status, ls_response) <> 1 Then Return -2
is_response = ls_response

If ll_status = 200 Then
	is_errorcode = ""
	is_error = ""
	Return of_ParseToken(ls_response)
End If

of_SetError(ls_response, ll_status)
Return -1
end function

protected function integer of_parsetoken (string as_json);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ParseToken
//
//	Access:  protected
//
//	Arguments:
//	as_json		a successful token response (RFC 6749, section 5.1)
//
//	Returns:  Integer.  1 if it has an access token, -5 if not
//
//	Description:  Keeps the tokens and when the access token expires.  A refresh response
//		without a refresh token keeps the one there was.
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

string	ls_token, ls_refresh
long		ll_expiresin

ls_token = of_JsonString(as_json, "access_token")
If ls_token = "" Then Return -5

is_accesstoken = ls_token
is_tokentype = of_JsonString(as_json, "token_type")
is_idtoken = of_JsonString(as_json, "id_token")
ls_refresh = of_JsonString(as_json, "refresh_token")
If ls_refresh <> "" Then is_refreshtoken = ls_refresh

ll_expiresin = of_JsonNumber(as_json, "expires_in")
If ll_expiresin > 0 Then
	idt_expires = of_AddSeconds(DateTime(Today(), Now()), ll_expiresin)
Else
	SetNull(idt_expires)
End If

Return 1
end function

protected subroutine of_seterror (string as_json, long al_status);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetError
//
//	Access:  protected
//
//	Arguments:
//	as_json		an error response (RFC 6749, section 5.2)
//	al_status	its HTTP status code
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

is_errorcode = of_JsonString(as_json, "error")
is_error = of_JsonString(as_json, "error_description")
If is_error = "" Then is_error = is_errorcode
If is_error = "" Then is_error = "HTTP " + String(al_status)
end subroutine

protected function integer of_notconfigured (string as_what);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_NotConfigured
//
//	Access:  protected
//
//	Arguments:
//	as_what		the missing setting
//
//	Returns:  Integer.  -6
//
//	Description:  The flow can't run: of_GetError says which setting is missing.
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

is_errorcode = ""
is_error = "Missing: " + as_what
Return -6
end function

protected function boolean of_pause (long al_milliseconds);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Pause
//
//	Access:  protected
//
//	Arguments:
//	al_milliseconds	how long to wait
//
//	Returns:  Boolean.  True after the wait, False if of_Cancel was called
//
//	Description:  Waits without blocking the application: PowerBuilder processes events
//		every 50 milliseconds, so a Cancel button can call of_Cancel.
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

long	ll_end

ll_end = CPU() + al_milliseconds
Do While CPU() < ll_end
	If ib_cancel Then Return False
	Yield()
	oa_Sleep(50)
Loop

Return Not ib_cancel
end function

protected function string of_authorizationurl (string as_redirecturi, string as_state, string as_challenge);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_AuthorizationURL
//
//	Access:  protected
//
//	Arguments:
//	as_redirecturi		the redirect URI (from n_cst_redirectlistener)
//	as_state				random value the response must return
//	as_challenge		the PKCE code challenge
//
//	Returns:  String.  The URL of the authorization request, to open in the browser
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

string	ls_url

ls_url = is_authorizationendpoint
If Pos(ls_url, "?") > 0 Then ls_url += "&" Else ls_url += "?"

ls_url += "response_type=code" + &
	"&client_id=" + of_UrlEncode(is_clientid) + &
	"&redirect_uri=" + of_UrlEncode(as_redirecturi) + &
	"&scope=" + of_UrlEncode(is_scope) + &
	"&state=" + of_UrlEncode(as_state) + &
	"&code_challenge=" + of_UrlEncode(as_challenge) + &
	"&code_challenge_method=S256"
If is_loginhint <> "" Then ls_url += "&login_hint=" + of_UrlEncode(is_loginhint)
If is_parameters <> "" Then ls_url += "&" + is_parameters

Return ls_url
end function

public function string of_urlencode (string as_value);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_UrlEncode
//
//	Access:  public
//
//	Arguments:
//	as_value		value to encode
//
//	Returns:  String.  The value URL encoded (UTF-8), for a query string or an
//		application/x-www-form-urlencoded body
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

CoderObject	lnv_coder
string		ls_encoded

If IsNull(as_value) Or as_value = "" Then Return ""

lnv_coder = Create CoderObject
ls_encoded = lnv_coder.UrlEncode(Blob(as_value, EncodingUTF8!))
Destroy lnv_coder

Return ls_encoded
end function

public function string of_randomstring (integer ai_bytes);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_RandomString
//
//	Access:  public
//
//	Arguments:
//	ai_bytes		number of random bytes
//
//	Returns:  String.  The bytes from the system's cryptographic random number generator,
//		in base64url (43 characters for 32 bytes), or "" if it fails
//
//	Description:  For the PKCE code verifier and the state.
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

blob	lblb_random

If ai_bytes < 1 Then Return ""
lblb_random = Blob(Space(ai_bytes), EncodingANSI!)
If BCryptGenRandom(0, lblb_random, ai_bytes, 2) <> 0 Then Return ""

Return of_Base64Url(lblb_random)
end function

public function string of_base64url (blob ablb_data);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Base64Url
//
//	Access:  public
//
//	Arguments:
//	ablb_data	bytes
//
//	Returns:  String.  The bytes in base64url without padding (RFC 4648, section 5)
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

CoderObject	lnv_coder
string		ls_text, ls_char, ls_result
long			ll_idx

lnv_coder = Create CoderObject
ls_text = lnv_coder.Base64Encode(ablb_data)
Destroy lnv_coder

For ll_idx = 1 To Len(ls_text)
	ls_char = Mid(ls_text, ll_idx, 1)
	Choose Case ls_char
		Case "+"
			ls_result += "-"
		Case "/"
			ls_result += "_"
		Case "=", "~r", "~n"
			// no padding, no line breaks
		Case Else
			ls_result += ls_char
	End Choose
Next

Return ls_result
end function

public function string of_codechallenge (string as_verifier);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_CodeChallenge
//
//	Access:  public
//
//	Arguments:
//	as_verifier		the PKCE code verifier
//
//	Returns:  String.  The code challenge for the S256 method: the base64url SHA-256 hash
//		of the verifier (RFC 7636, section 4.2)
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

CrypterObject	lnv_crypter
blob				lblb_hash

lnv_crypter = Create CrypterObject
lblb_hash = lnv_crypter.SHA(SHA256!, Blob(as_verifier, EncodingANSI!))
Destroy lnv_crypter

Return of_Base64Url(lblb_hash)
end function

public function string of_jsonstring (string as_json, string as_key);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_JSONString
//
//	Access:  public
//
//	Arguments:
//	as_json		JSON object
//	as_key		name of a top-level string value
//
//	Returns:  String.  The value, or "" if it is not there
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

JSONParser	lnv_json
long			ll_root, ll_idx, ll_count, ll_item
string		ls_value

If IsNull(as_json) Or Trim(as_json) = "" Then Return ""

lnv_json = Create JSONParser
If lnv_json.LoadString(as_json) = "" Then
	ll_root = lnv_json.GetRootItem()
	If lnv_json.GetItemType(ll_root) = JsonObjectItem! Then
		ll_count = lnv_json.GetChildCount(ll_root)
		For ll_idx = 1 To ll_count
			If lnv_json.GetChildKey(ll_root, ll_idx) = as_key Then
				ll_item = lnv_json.GetChildItem(ll_root, ll_idx)
				If lnv_json.GetItemType(ll_item) = JsonStringItem! Then ls_value = lnv_json.GetItemString(ll_item)
				Exit
			End If
		Next
	End If
End If
Destroy lnv_json

Return ls_value
end function

public function long of_jsonnumber (string as_json, string as_key);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_JSONNumber
//
//	Access:  public
//
//	Arguments:
//	as_json		JSON object
//	as_key		name of a top-level number (or a string with a number)
//
//	Returns:  Long.  The value, or 0 if it is not there
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

JSONParser	lnv_json
long			ll_root, ll_idx, ll_count, ll_item, ll_value
string		ls_value

If IsNull(as_json) Or Trim(as_json) = "" Then Return 0

lnv_json = Create JSONParser
If lnv_json.LoadString(as_json) = "" Then
	ll_root = lnv_json.GetRootItem()
	If lnv_json.GetItemType(ll_root) = JsonObjectItem! Then
		ll_count = lnv_json.GetChildCount(ll_root)
		For ll_idx = 1 To ll_count
			If lnv_json.GetChildKey(ll_root, ll_idx) = as_key Then
				ll_item = lnv_json.GetChildItem(ll_root, ll_idx)
				Choose Case lnv_json.GetItemType(ll_item)
					Case JsonNumberItem!
						ll_value = lnv_json.GetItemNumber(ll_item)
					Case JsonStringItem!
						// some providers send numbers as strings
						ls_value = lnv_json.GetItemString(ll_item)
						If IsNumber(ls_value) Then ll_value = Long(ls_value)
				End Choose
				Exit
			End If
		Next
	End If
End If
Destroy lnv_json

Return ll_value
end function

protected function datetime of_addseconds (datetime adt_datetime, long al_seconds);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_AddSeconds
//
//	Access:  protected
//
//	Arguments:
//	adt_datetime	a date and time
//	al_seconds		seconds to add (or subtract)
//
//	Returns:  DateTime.  The date and time that many seconds later
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

long	ll_seconds, ll_days

ll_seconds = SecondsAfter(Time("00:00:00"), Time(adt_datetime)) + al_seconds
// Int rounds down, also for times before midnight
ll_days = Int(ll_seconds / 86400)
ll_seconds = ll_seconds - ll_days * 86400

Return DateTime(RelativeDate(Date(adt_datetime), ll_days), RelativeTime(Time("00:00:00"), ll_seconds))
end function

protected function string of_text (string as_id, string as_default, string as_parms[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Text
//
//	Access:  protected
//
//	Arguments:
//	as_id			ID of the text in the language file
//	as_default	the text in English, with placeholders (%s) for the values in as_parms
//	as_parms[]	values for the placeholders
//
//	Returns:  String.  The text from the language service, or the English text
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
	If IsValid(gnv_app.inv_language) Then Return gnv_app.inv_language.of_GetText(as_id, as_default, as_parms)
End If
Return lnv_string.of_Format(as_default, as_parms)
end function

on pfc_n_cst_oauth2.create
call super::create
end on

on pfc_n_cst_oauth2.destroy
call super::destroy
end on

event constructor;call super::constructor;SetNull(idt_expires)
end event

event destructor;call super::destructor;If IsValid(inv_listener) Then Destroy inv_listener
end event
