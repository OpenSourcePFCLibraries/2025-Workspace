$PBExportHeader$pfc_w_openid_logon.srw
$PBExportComments$PFC OpenID Connect logon window
forward
global type pfc_w_openid_logon from w_response
end type
type st_help from u_st within pfc_w_openid_logon
end type
type cb_ok from u_cb within pfc_w_openid_logon
end type
type cb_cancel from u_cb within pfc_w_openid_logon
end type
type sle_userid from u_sle within pfc_w_openid_logon
end type
type sle_password from u_sle within pfc_w_openid_logon
end type
type st_2 from u_st within pfc_w_openid_logon
end type
type st_3 from u_st within pfc_w_openid_logon
end type
type rb_oauthclient from u_rb within pfc_w_openid_logon
end type
type rb_httpclient from u_rb within pfc_w_openid_logon
end type
end forward

global type pfc_w_openid_logon from w_response
integer width = 2249
integer height = 620
string title = "Logon"
long backcolor = 80263328
st_help st_help
cb_ok cb_ok
cb_cancel cb_cancel
sle_userid sle_userid
sle_password sle_password
st_2 st_2
st_3 st_3
rb_oauthclient rb_oauthclient
rb_httpclient rb_httpclient
event pfc_signin ( )
end type
global pfc_w_openid_logon pfc_w_openid_logon

type variables
Protected:
n_cst_openidattrib	inv_openidattrib
// Authorization code flow: the redirect listener, whether it is waiting for the browser,
// whether the user cancelled, and the identity provider's error, if any
n_cst_redirectlistener	inv_listener
// PKCE, random strings, URL encoding and JSON (of_OAuth2)
n_cst_oauth2	inv_oauth2
boolean	ib_waiting
boolean	ib_cancelled
string	is_error
end variables

forward prototypes
protected function integer of_login_httpclient (string as_userid, string as_password)
protected function integer of_login_oauthclient (string as_userid, string as_password)
protected function integer of_loaduserinfo (string as_accesstoken)
protected function string of_urlencode (string as_value)
protected function string of_jsonstring (string as_json, string as_key)
protected function integer of_getgroups (string as_json, string as_claim, ref string as_groups[])
protected function string of_decodeidtoken (string as_idtoken)
protected function integer of_loadidtokengroups (string as_idtoken)
protected function string of_randomstring (integer ai_bytes)
protected function string of_base64url (blob ablb_data)
protected function string of_codechallenge (string as_verifier)
protected function string of_authorizationurl (string as_redirecturi, string as_state, string as_nonce, string as_challenge)
protected function integer of_login_code ()
protected function integer of_exchange_httpclient (string as_code, string as_verifier, string as_redirecturi)
protected function integer of_exchange_oauthclient (string as_code, string as_verifier, string as_redirecturi)
protected function string of_getuserid ()
protected function string of_text (string as_id, string as_default, string as_parms[])
protected subroutine of_setflow ()
protected function integer of_openbrowser (string as_url)
protected function n_cst_oauth2 of_oauth2 ()
end prototypes

protected function integer of_login_httpclient (string as_userid, string as_password);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Login_HTTPClient
//
//	Access:  protected
//
//	Arguments:
//	as_userid		user ID
//	as_password		password (for Authentik, the user's app password)
//
//	Returns:  Integer
//	 1 = logged on; the access token is in inv_openidattrib.is_accesstoken, and the
//		  ID token (if the provider returned one) in is_idtoken
//	-1 = the identity provider refused the logon
//	-2 = the identity provider could not be reached
//
//	Description:  Requests a token with the OAuth 2.0 password grant, using HTTPClient.
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
Long			ll_rc
Integer		li_status, li_rc
String		ls_body, ls_response

lnv_httpclient = Create HTTPClient
lnv_httpclient.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
lnv_httpclient.SetRequestHeader("Accept", "application/json")

// Form values must be URL encoded, or characters such as & + % = in a password break the request
ls_body = "grant_type=password" + &
	"&client_id=" + of_UrlEncode(inv_openidattrib.is_clientid) + &
	"&username=" + of_UrlEncode(as_userid) + &
	"&password=" + of_UrlEncode(as_password) + &
	"&scope=" + of_UrlEncode(inv_openidattrib.is_scope)

ll_rc = lnv_httpclient.SendRequest("POST", inv_openidattrib.is_tokenendpoint, ls_body)
If ll_rc = 1 Then
	li_status = lnv_httpclient.GetResponseStatusCode()
	lnv_httpclient.GetResponseBody(ls_response)
	If li_status = 200 Then
		If inv_openidattrib.ib_showresponses Then MessageBox("Token response (200)", ls_response)
		inv_openidattrib.is_accesstoken = of_JsonString(ls_response, "access_token")
		// Present when the openid scope was requested
		inv_openidattrib.is_idtoken = of_JsonString(ls_response, "id_token")
		li_rc = 1
	Else
		If inv_openidattrib.ib_showresponses Then MessageBox("Token response (" + String(li_status) + ")", ls_response)
		li_rc = -1
	End If
Else
	li_rc = -2
End If

Destroy lnv_httpclient
Return li_rc
end function

protected function integer of_login_oauthclient (string as_userid, string as_password);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Login_OAuthClient
//
//	Access:  protected
//
//	Arguments:
//	as_userid		user ID
//	as_password		password (for Authentik, the user's app password)
//
//	Returns:  Integer
//	 1 = logged on; the access token is in inv_openidattrib.is_accesstoken, and the
//		  ID token (if the provider returned one) in is_idtoken
//	-1 = the identity provider refused the logon
//	-2 = the identity provider could not be reached
//
//	Description:  Requests a token with the OAuth 2.0 password grant, using OAuthClient.
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

OAuthClient		lnv_oauthclient
TokenRequest	lnv_tokenrequest
TokenResponse	lnv_tokenresponse
Long				ll_rc
Integer			li_rc
String			ls_body

lnv_oauthclient = Create OAuthClient

lnv_tokenrequest.TokenLocation = inv_openidattrib.is_tokenendpoint
lnv_tokenrequest.Method = "POST"
lnv_tokenrequest.ClearParams()
lnv_tokenrequest.AppendParam("grant_type", "password")
lnv_tokenrequest.AppendParam("client_id", inv_openidattrib.is_clientid)
lnv_tokenrequest.AppendParam("username", as_userid)
lnv_tokenrequest.AppendParam("password", as_password)
lnv_tokenrequest.AppendParam("scope", inv_openidattrib.is_scope)
lnv_tokenrequest.ClearHeaders()
lnv_tokenrequest.SetHeader("Content-Type", "application/x-www-form-urlencoded")

ll_rc = lnv_oauthclient.AccessToken(lnv_tokenrequest, lnv_tokenresponse)

// AccessToken returns 1 when the request completes, even if the identity provider
// refuses the logon, so the status code decides whether the logon succeeded
If ll_rc = 1 Then
	If lnv_tokenresponse.GetStatusCode() = 200 Then
		inv_openidattrib.is_accesstoken = lnv_tokenresponse.GetAccessToken()
		// Present when the openid scope was requested
		lnv_tokenresponse.GetBody(ls_body)
		inv_openidattrib.is_idtoken = of_JsonString(ls_body, "id_token")
		If inv_openidattrib.ib_showresponses Then MessageBox("Access token", inv_openidattrib.is_accesstoken)
		li_rc = 1
	Else
		lnv_tokenresponse.GetBody(ls_body)
		If inv_openidattrib.ib_showresponses Then MessageBox("Token response (" + String(lnv_tokenresponse.GetStatusCode()) + ")", ls_body)
		li_rc = -1
	End If
Else
	li_rc = -2
End If

Destroy lnv_oauthclient
Return li_rc
end function

protected function integer of_loaduserinfo (string as_accesstoken);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_LoadUserInfo
//
//	Access:  protected
//
//	Arguments:
//	as_accesstoken	access token from the token endpoint
//
//	Returns:  Integer
//	 1 = success; inv_openidattrib.is_userinfo and is_groups are set
//	-1 = the request failed
//
//	Description:  Reads the user's claims from the userinfo endpoint and keeps the groups
//		claim (inv_openidattrib.is_groupsclaim, "groups" by default; Authentik returns it with
//		the profile scope).  Some providers, such as Microsoft Entra ID, don't return groups
//		from the userinfo endpoint; pfc_default then reads them from the ID token.
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
Long			ll_rc, ll_idx
Integer		li_status, li_rc = -1
String		ls_response, ls_groups[], ls_empty[], ls_list

inv_openidattrib.is_userinfo = ""
inv_openidattrib.is_groups = ls_empty
If IsNull(as_accesstoken) Or Len(as_accesstoken) = 0 Then Return -1

lnv_httpclient = Create HTTPClient
lnv_httpclient.SetRequestHeader("Authorization", "Bearer " + as_accesstoken)
lnv_httpclient.SetRequestHeader("Accept", "application/json")
ll_rc = lnv_httpclient.SendRequest("GET", inv_openidattrib.is_userinfoendpoint)

If ll_rc = 1 Then
	li_status = lnv_httpclient.GetResponseStatusCode()
	lnv_httpclient.GetResponseBody(ls_response)
	If li_status = 200 Then
		// A response without the claim has no groups; -1 means it isn't JSON
		If of_GetGroups(ls_response, inv_openidattrib.is_groupsclaim, ls_groups) >= 0 Then
			inv_openidattrib.is_userinfo = ls_response
			inv_openidattrib.is_groups = ls_groups
			li_rc = 1
		End If
		For ll_idx = 1 To UpperBound(ls_groups)
			If ll_idx > 1 Then ls_list += ", "
			ls_list += ls_groups[ll_idx]
		Next
		If inv_openidattrib.ib_showresponses Then MessageBox("UserInfo response (200)", ls_response + "~r~n~r~nGroups: " + ls_list)
	Else
		If inv_openidattrib.ib_showresponses Then MessageBox("UserInfo response (" + String(li_status) + ")", ls_response)
	End If
End If

Destroy lnv_httpclient
Return li_rc
end function

protected function string of_urlencode (string as_value);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_UrlEncode
//
//	Access:  protected
//
//	Arguments:
//	as_value		value to encode
//
//	Returns:  String.  The value URL encoded (UTF-8), for an application/x-www-form-urlencoded body
//
//	Description:  Uses n_cst_oauth2, which has the code.
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

Return of_OAuth2().of_UrlEncode(as_value)
end function

protected function string of_jsonstring (string as_json, string as_key);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_JSONString
//
//	Access:  protected
//
//	Arguments:
//	as_json		JSON object
//	as_key		name of a top-level string value
//
//	Returns:  String.  The value, or "" if it is not there
//
//	Description:  Uses n_cst_oauth2, which has the code.
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

Return of_OAuth2().of_JSONString(as_json, as_key)
end function

protected function integer of_getgroups (string as_json, string as_claim, ref string as_groups[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetGroups
//
//	Access:  protected
//
//	Arguments:
//	as_json		JSON object (a userinfo response or the claims of an ID token)
//	as_claim		name of the top-level claim with the groups, for example "groups" or "roles"
//	as_groups[]	(by ref) the groups
//
//	Returns:  Integer.  The number of groups (0 if the claim isn't there), or -1 if as_json
//		isn't a JSON object
//
//	Description:  Reads a groups claim, which is an array of strings or, with some
//		providers when there is only one group, a single string.
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
Long			ll_root, ll_idx, ll_count, ll_claim, ll_item
Integer		li_count = -1
String		ls_empty[]

as_groups = ls_empty
If IsNull(as_json) Or Left(Trim(as_json), 1) <> "{" Then Return -1

lnv_json = Create JSONParser
If lnv_json.LoadString(as_json) = "" Then
	li_count = 0
	ll_root = lnv_json.GetRootItem()
	ll_count = lnv_json.GetChildCount(ll_root)
	For ll_idx = 1 To ll_count
		If lnv_json.GetChildKey(ll_root, ll_idx) = as_claim Then
			ll_claim = lnv_json.GetChildItem(ll_root, ll_idx)
			Choose Case lnv_json.GetItemType(ll_claim)
				Case JsonArrayItem!
					For ll_item = 1 To lnv_json.GetChildCount(ll_claim)
						If lnv_json.GetItemType(lnv_json.GetChildItem(ll_claim, ll_item)) = JsonStringItem! Then
							li_count++
							as_groups[li_count] = lnv_json.GetItemString(lnv_json.GetChildItem(ll_claim, ll_item))
						End If
					Next
				Case JsonStringItem!
					li_count = 1
					as_groups[1] = lnv_json.GetItemString(ll_claim)
			End Choose
			Exit
		End If
	Next
End If
Destroy lnv_json

Return li_count
end function

protected function string of_decodeidtoken (string as_idtoken);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_DecodeIDToken
//
//	Access:  protected
//
//	Arguments:
//	as_idtoken	ID token (a JSON Web Token: header.payload.signature)
//
//	Returns:  String.  The token's claims (the decoded payload, a JSON object), or "" if
//		as_idtoken isn't a JSON Web Token
//
//	Description:  Decodes the claims of an ID token.  The signature isn't checked: the
//		token is only used when it comes directly from the token endpoint, where the
//		connection to the identity provider authenticates it (OpenID Connect Core 1.0,
//		section 3.1.3.7).  Use HTTPS for the token endpoint.
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
Blob			lblb_payload
Long			ll_first, ll_second, ll_pos
String		ls_payload

If IsNull(as_idtoken) Then Return ""

ll_first = Pos(as_idtoken, ".")
If ll_first = 0 Then Return ""
ll_second = Pos(as_idtoken, ".", ll_first + 1)
If ll_second = 0 Then Return ""

// The payload is base64url without padding: turn it into base64
ls_payload = Mid(as_idtoken, ll_first + 1, ll_second - ll_first - 1)
If Len(ls_payload) = 0 Then Return ""
For ll_pos = 1 To Len(ls_payload)
	Choose Case Mid(ls_payload, ll_pos, 1)
		Case "-"
			ls_payload = Replace(ls_payload, ll_pos, 1, "+")
		Case "_"
			ls_payload = Replace(ls_payload, ll_pos, 1, "/")
	End Choose
Next
Do While Mod(Len(ls_payload), 4) <> 0
	ls_payload += "="
Loop

lnv_coder = Create CoderObject
lblb_payload = lnv_coder.Base64Decode(ls_payload)
Destroy lnv_coder

If IsNull(lblb_payload) Or Len(lblb_payload) = 0 Then Return ""
ls_payload = String(lblb_payload, EncodingUTF8!)
If Left(Trim(ls_payload), 1) <> "{" Then Return ""

Return ls_payload
end function

protected function integer of_loadidtokengroups (string as_idtoken);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_LoadIDTokenGroups
//
//	Access:  protected
//
//	Arguments:
//	as_idtoken	ID token from the token endpoint
//
//	Returns:  Integer.  The number of groups (in inv_openidattrib.is_groups), or -1 if
//		there is no ID token, it can't be decoded, or it wasn't issued to this application
//
//	Description:  Reads the groups claim (inv_openidattrib.is_groupsclaim) from the ID
//		token, for providers that don't return it from the userinfo endpoint, such as
//		Microsoft Entra ID.  The token's audience ("aud") must be the client ID.
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

String		ls_claims, ls_audience[], ls_groups[], ls_list
Integer		li_count, li_idx
Boolean		lb_audience

If IsNull(as_idtoken) Or Len(as_idtoken) = 0 Then Return -1

ls_claims = of_DecodeIDToken(as_idtoken)
If ls_claims = "" Then Return -1

// The audience is the client ID, as a string or in an array
For li_idx = 1 To of_GetGroups(ls_claims, "aud", ls_audience)
	If ls_audience[li_idx] = inv_openidattrib.is_clientid Then lb_audience = True
Next
If Not lb_audience Then
	If inv_openidattrib.ib_showresponses Then MessageBox("ID token", "The ID token wasn't issued to client " + &
		inv_openidattrib.is_clientid + ", so its groups aren't used.~r~n~r~n" + ls_claims)
	Return -1
End If

li_count = of_GetGroups(ls_claims, inv_openidattrib.is_groupsclaim, ls_groups)
If li_count > 0 Then inv_openidattrib.is_groups = ls_groups

If inv_openidattrib.ib_showresponses Then
	For li_idx = 1 To li_count
		If li_idx > 1 Then ls_list += ", "
		ls_list += ls_groups[li_idx]
	Next
	MessageBox("ID token claims", ls_claims + "~r~n~r~nGroups (" + inv_openidattrib.is_groupsclaim + "): " + ls_list)
End If

Return li_count
end function

protected function string of_randomstring (integer ai_bytes);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_RandomString
//
//	Access:  protected
//
//	Arguments:
//	ai_bytes		number of random bytes
//
//	Returns:  String.  The bytes from the system's cryptographic random number generator,
//		in base64url (43 characters for 32 bytes), or "" if it fails
//
//	Description:  For the PKCE code verifier, the state and the nonce.  Uses
//		n_cst_oauth2, which has the code.
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

Return of_OAuth2().of_RandomString(ai_bytes)
end function

protected function string of_base64url (blob ablb_data);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Base64Url
//
//	Access:  protected
//
//	Arguments:
//	ablb_data	bytes
//
//	Returns:  String.  The bytes in base64url without padding (RFC 4648, section 5)
//
//	Description:  Uses n_cst_oauth2, which has the code.
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

Return of_OAuth2().of_Base64Url(ablb_data)
end function

protected function string of_codechallenge (string as_verifier);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_CodeChallenge
//
//	Access:  protected
//
//	Arguments:
//	as_verifier		the PKCE code verifier
//
//	Returns:  String.  The code challenge for the S256 method: the base64url SHA-256 hash
//		of the verifier (RFC 7636, section 4.2)
//
//	Description:  Uses n_cst_oauth2, which has the code.
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

Return of_OAuth2().of_CodeChallenge(as_verifier)
end function

protected function string of_authorizationurl (string as_redirecturi, string as_state, string as_nonce, string as_challenge);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_AuthorizationURL
//
//	Access:  protected
//
//	Arguments:
//	as_redirecturi		the redirect URI (from n_cst_redirectlistener)
//	as_state				random value the response must return
//	as_nonce				random value the ID token must contain
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

ls_url = inv_openidattrib.is_authorizationendpoint
If Pos(ls_url, "?") > 0 Then ls_url += "&" Else ls_url += "?"

ls_url += "response_type=code" + &
	"&client_id=" + of_UrlEncode(inv_openidattrib.is_clientid) + &
	"&redirect_uri=" + of_UrlEncode(as_redirecturi) + &
	"&scope=" + of_UrlEncode(inv_openidattrib.is_scope) + &
	"&state=" + of_UrlEncode(as_state) + &
	"&nonce=" + of_UrlEncode(as_nonce) + &
	"&code_challenge=" + of_UrlEncode(as_challenge) + &
	"&code_challenge_method=S256"
If Len(inv_openidattrib.is_userid) > 0 Then ls_url += "&login_hint=" + of_UrlEncode(inv_openidattrib.is_userid)

Return ls_url
end function

protected function integer of_login_code ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Login_Code
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  Integer
//	 1 = signed in; the access token (and ID token) are in inv_openidattrib
//	 0 = the user cancelled
//	-1 = the identity provider refused the sign-in (is_error has its reason)
//	-2 = the identity provider could not be reached
//	-3 = the browser could not be opened, or the redirect could not be received
//	-4 = the user didn't sign in in time (inv_openidattrib.il_timeout)
//	-5 = the response is not valid (its state, or the ID token's nonce, doesn't match)
//
//	Description:  Signs the user in with the OAuth 2.0 authorization code flow with PKCE
//		(RFC 7636), in the user's web browser, which supports multi-factor authentication
//		and single sign-on.  The redirect is received on the loopback interface
//		(n_cst_redirectlistener, RFC 8252).  The window stays responsive while it waits;
//		Cancel stops the wait.
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

string	ls_verifier, ls_state, ls_nonce, ls_url, ls_code, ls_redirecturi, ls_claims, ls_none[]
integer	li_rc

is_error = ""
ib_cancelled = False

// Listen before opening the browser, so the redirect can't arrive too early
If IsValid(inv_listener) Then Destroy inv_listener
inv_listener = Create n_cst_redirectlistener
If inv_listener.of_Start(inv_openidattrib.is_redirectpath) <> 1 Then Return -3
inv_listener.of_SetPage( &
	of_Text("pfc_openidlogon_pagetitle", "Sign-in complete", ls_none), &
	of_Text("pfc_openidlogon_pagemessage", "You can close this window and return to the application.", ls_none))
ls_redirecturi = inv_listener.of_GetRedirectURI()

ls_verifier = of_RandomString(32)
ls_state = of_RandomString(16)
ls_nonce = of_RandomString(16)
If ls_verifier = "" Or ls_state = "" Or ls_nonce = "" Then Return -3

ls_url = of_AuthorizationURL(ls_redirecturi, ls_state, ls_nonce, of_CodeChallenge(ls_verifier))
If inv_openidattrib.ib_showresponses Then MessageBox("Authorization request", ls_url)
If of_OpenBrowser(ls_url) <> 1 Then Return -3

// Wait for the user to sign in in the browser
st_help.text = of_Text("pfc_openidlogon_waiting", "Waiting for you to sign in in your web browser...", ls_none)
cb_ok.enabled = False
ib_waiting = True
li_rc = inv_listener.of_Wait(inv_openidattrib.il_timeout)
ib_waiting = False
cb_ok.enabled = True
If inv_openidattrib.ib_showresponses And li_rc = 1 Then MessageBox("Redirect", inv_listener.of_GetRequest())

If ib_cancelled Then Return 0
If li_rc = 0 Then Return -4
If li_rc < 0 Then Return -3

If inv_listener.of_GetParameter("state") <> ls_state Then Return -5
If inv_listener.of_GetParameter("error") <> "" Then
	is_error = inv_listener.of_GetParameter("error_description")
	If is_error = "" Then is_error = inv_listener.of_GetParameter("error")
	Return -1
End If
ls_code = inv_listener.of_GetParameter("code")
inv_listener.of_Stop()

// Exchange the code, with the code verifier, for the tokens
SetPointer(HourGlass!)
If rb_httpclient.checked Then
	li_rc = of_Exchange_HTTPClient(ls_code, ls_verifier, ls_redirecturi)
Else
	li_rc = of_Exchange_OAuthClient(ls_code, ls_verifier, ls_redirecturi)
End If
If li_rc <> 1 Then Return li_rc

// The ID token must be the one for this request
If Len(inv_openidattrib.is_idtoken) > 0 Then
	ls_claims = of_DecodeIDToken(inv_openidattrib.is_idtoken)
	If of_JsonString(ls_claims, "nonce") <> ls_nonce Then Return -5
End If

Return 1
end function

protected function integer of_exchange_httpclient (string as_code, string as_verifier, string as_redirecturi);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Exchange_HTTPClient
//
//	Access:  protected
//
//	Arguments:
//	as_code			the authorization code from the redirect
//	as_verifier		the PKCE code verifier
//	as_redirecturi	the redirect URI sent with the authorization request
//
//	Returns:  Integer
//	 1 = the tokens are in inv_openidattrib (is_accesstoken, is_idtoken)
//	-1 = the identity provider refused (is_error has its reason)
//	-2 = the identity provider could not be reached
//
//	Description:  Exchanges the authorization code for the tokens, using HTTPClient.
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
long			ll_rc
integer		li_status, li_rc
string		ls_body, ls_response

lnv_httpclient = Create HTTPClient
lnv_httpclient.SetRequestHeader("Content-Type", "application/x-www-form-urlencoded")
lnv_httpclient.SetRequestHeader("Accept", "application/json")

ls_body = "grant_type=authorization_code" + &
	"&code=" + of_UrlEncode(as_code) + &
	"&redirect_uri=" + of_UrlEncode(as_redirecturi) + &
	"&client_id=" + of_UrlEncode(inv_openidattrib.is_clientid) + &
	"&code_verifier=" + of_UrlEncode(as_verifier)

ll_rc = lnv_httpclient.SendRequest("POST", inv_openidattrib.is_tokenendpoint, ls_body)
If ll_rc = 1 Then
	li_status = lnv_httpclient.GetResponseStatusCode()
	lnv_httpclient.GetResponseBody(ls_response)
	If inv_openidattrib.ib_showresponses Then MessageBox("Token response (" + String(li_status) + ")", ls_response)
	If li_status = 200 Then
		inv_openidattrib.is_accesstoken = of_JsonString(ls_response, "access_token")
		inv_openidattrib.is_idtoken = of_JsonString(ls_response, "id_token")
		li_rc = 1
	Else
		is_error = of_JsonString(ls_response, "error_description")
		If is_error = "" Then is_error = of_JsonString(ls_response, "error")
		li_rc = -1
	End If
Else
	li_rc = -2
End If

Destroy lnv_httpclient
Return li_rc
end function

protected function integer of_exchange_oauthclient (string as_code, string as_verifier, string as_redirecturi);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Exchange_OAuthClient
//
//	Access:  protected
//
//	Arguments:
//	as_code			the authorization code from the redirect
//	as_verifier		the PKCE code verifier
//	as_redirecturi	the redirect URI sent with the authorization request
//
//	Returns:  Integer
//	 1 = the tokens are in inv_openidattrib (is_accesstoken, is_idtoken)
//	-1 = the identity provider refused (is_error has its reason)
//	-2 = the identity provider could not be reached
//
//	Description:  Exchanges the authorization code for the tokens, using OAuthClient.
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

OAuthClient		lnv_oauthclient
TokenRequest	lnv_tokenrequest
TokenResponse	lnv_tokenresponse
long				ll_rc
integer			li_rc
string			ls_body

lnv_oauthclient = Create OAuthClient

lnv_tokenrequest.TokenLocation = inv_openidattrib.is_tokenendpoint
lnv_tokenrequest.Method = "POST"
lnv_tokenrequest.ClearParams()
lnv_tokenrequest.AppendParam("grant_type", "authorization_code")
lnv_tokenrequest.AppendParam("code", as_code)
lnv_tokenrequest.AppendParam("redirect_uri", as_redirecturi)
lnv_tokenrequest.AppendParam("client_id", inv_openidattrib.is_clientid)
lnv_tokenrequest.AppendParam("code_verifier", as_verifier)
lnv_tokenrequest.ClearHeaders()
lnv_tokenrequest.SetHeader("Content-Type", "application/x-www-form-urlencoded")

ll_rc = lnv_oauthclient.AccessToken(lnv_tokenrequest, lnv_tokenresponse)
If ll_rc = 1 Then
	lnv_tokenresponse.GetBody(ls_body)
	If inv_openidattrib.ib_showresponses Then MessageBox("Token response (" + String(lnv_tokenresponse.GetStatusCode()) + ")", ls_body)
	If lnv_tokenresponse.GetStatusCode() = 200 Then
		inv_openidattrib.is_accesstoken = lnv_tokenresponse.GetAccessToken()
		inv_openidattrib.is_idtoken = of_JsonString(ls_body, "id_token")
		li_rc = 1
	Else
		is_error = of_JsonString(ls_body, "error_description")
		If is_error = "" Then is_error = of_JsonString(ls_body, "error")
		li_rc = -1
	End If
Else
	li_rc = -2
End If

Destroy lnv_oauthclient
Return li_rc
end function

protected function string of_getuserid ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetUserID
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  String.  The user ID of the user who signed in, from the userinfo response or
//		the ID token: preferred_username, or else email, or else sub
//
//	Description:  In the authorization code flow, the user signs in in the browser, so the
//		window doesn't know the user ID.
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

string	ls_sources[], ls_claims[]
integer	li_source, li_claim
string	ls_value

ls_sources[1] = inv_openidattrib.is_userinfo
ls_sources[2] = of_DecodeIDToken(inv_openidattrib.is_idtoken)
ls_claims[1] = "preferred_username"
ls_claims[2] = "email"
ls_claims[3] = "sub"

For li_claim = 1 To UpperBound(ls_claims)
	For li_source = 1 To UpperBound(ls_sources)
		If Len(ls_sources[li_source]) = 0 Then Continue
		ls_value = of_JsonString(ls_sources[li_source], ls_claims[li_claim])
		If Len(ls_value) > 0 Then Return ls_value
	Next
Next

Return ""
end function

protected function string of_text (string as_id, string as_default, string as_parms[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Text
//
//	Access:  protected
//
//	Arguments:
//	as_id			ID of the text in the language file
//	as_default	the English text
//	as_parms[]	values for its placeholders
//
//	Returns:  String.  The text from the language service, if it is enabled, or the
//		English text, with the values
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

protected subroutine of_setflow ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetFlow
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Sets up the window for the sign-in flow: for the authorization code flow
//		the user signs in in the browser, so the user ID and password are hidden.
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
boolean	lb_password

lb_password = (Lower(inv_openidattrib.is_flow) <> "code")
ls_parms[1] = inv_openidattrib.is_appname

st_2.visible = lb_password
st_3.visible = lb_password
sle_userid.visible = lb_password
sle_password.visible = lb_password

If lb_password Then
	st_help.text = of_Text("pfc_logon_help", "Enter a User ID and password to log onto %s.", ls_parms)
Else
	st_help.text = of_Text("pfc_openidlogon_codehelp", "Click Sign In to sign in to %s in your web browser.", ls_parms)
	cb_ok.text = of_Text("pfc_openidlogon_signin", "&Sign In", ls_parms)
End If
end subroutine

protected function integer of_openbrowser (string as_url);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_OpenBrowser
//
//	Access:  protected
//
//	Arguments:
//	as_url		the authorization request
//
//	Returns:  Integer.  1 if the URL was opened, -1 if not
//
//	Description:  Opens the authorization request in the user's default web browser.
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
end function

protected function n_cst_oauth2 of_oauth2 ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_OAuth2
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  n_cst_oauth2.  The OAuth 2.0 token service whose helpers the window uses
//		(PKCE, random strings, URL encoding and JSON); created when first needed
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

If Not IsValid(inv_oauth2) Then inv_oauth2 = Create n_cst_oauth2
Return inv_oauth2
end function


on pfc_w_openid_logon.create
int iCurrent
call super::create
this.st_help=create st_help
this.cb_ok=create cb_ok
this.cb_cancel=create cb_cancel
this.sle_userid=create sle_userid
this.sle_password=create sle_password
this.st_2=create st_2
this.st_3=create st_3
this.rb_oauthclient=create rb_oauthclient
this.rb_httpclient=create rb_httpclient
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_help
this.Control[iCurrent+2]=this.cb_ok
this.Control[iCurrent+3]=this.cb_cancel
this.Control[iCurrent+4]=this.sle_userid
this.Control[iCurrent+5]=this.sle_password
this.Control[iCurrent+6]=this.st_2
this.Control[iCurrent+7]=this.st_3
this.Control[iCurrent+8]=this.rb_oauthclient
this.Control[iCurrent+9]=this.rb_httpclient
end on

on pfc_w_openid_logon.destroy
call super::destroy
destroy(this.st_help)
destroy(this.cb_ok)
destroy(this.cb_cancel)
destroy(this.sle_userid)
destroy(this.sle_password)
destroy(this.st_2)
destroy(this.st_3)
destroy(this.rb_oauthclient)
destroy(this.rb_httpclient)
end on

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  open
//
//	Description:  Reads the n_cst_openidattrib passed with OpenWithParm.
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

ib_disableclosequery = true

If IsValid(Message.PowerObjectParm) Then
	If inv_openidattrib.ClassName() = Message.PowerObjectParm.ClassName() Then
		inv_openidattrib = Message.PowerObjectParm
	End IF
Else
	// Set the return code to mean the window was closed by error.
	inv_openidattrib.ii_rc = -1
	inv_openidattrib.is_userid = ""
	CloseWithReturn (this, inv_openidattrib)
	Return
End If

// Application Name, in the help text.  A message with a placeholder, so that a
// translation (language service) can put the name where its word order needs it.
string	ls_none[]

If Len (inv_openidattrib.is_appname) = 0 Then
	inv_openidattrib.is_appname = of_Text("pfc_logon_defaultappname", "the application", ls_none)
End If

// The help text, and for the authorization code flow, no user ID and password
of_SetFlow()

sle_userid.text = inv_openidattrib.is_userid

// The client choice is only offered when demonstrating
rb_httpclient.checked = (Lower(inv_openidattrib.is_client) = "httpclient")
rb_oauthclient.checked = Not rb_httpclient.checked
rb_oauthclient.visible = inv_openidattrib.ib_showresponses
rb_httpclient.visible = inv_openidattrib.ib_showresponses

If Not sle_userid.visible Then
	cb_ok.SetFocus()
ElseIf Len (sle_userid.text) > 0 Then
	sle_password.SetFocus()
Else
	sle_userid.SetFocus()
End If
end event

event pfc_default;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  pfc_default
//
//	Description:  Logs on with the identity provider and reads the user's groups.
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
string	ls_parms[]

If Lower (inv_openidattrib.is_flow) = "code" Then
	This.Event pfc_signin()
	Return
End If

If Len (sle_userid.text) = 0 Then
	of_MessageBox ("pfc_openidlogon_enterid", inv_openidattrib.is_appname, &
		"Please enter a User ID to logon.", Exclamation!, OK!, 1)
	sle_userid.SetFocus()
	Return
End If

If Len (sle_password.text) = 0 Then
	of_MessageBox ("pfc_openidlogon_enterpassword", inv_openidattrib.is_appname, &
		"Please enter a password to logon.", Exclamation!, OK!, 1)
	sle_password.SetFocus()
	Return
End If

If Len (inv_openidattrib.is_tokenendpoint) = 0 Or Len (inv_openidattrib.is_userinfoendpoint) = 0 &
	Or Len (inv_openidattrib.is_clientid) = 0 Then
	of_MessageBox ("pfc_openidlogon_notconfigured", inv_openidattrib.is_appname, &
		"The identity provider settings (token endpoint, userinfo endpoint and client ID) are missing.", &
		StopSign!, OK!, 1)
	inv_openidattrib.ii_rc = -1
	inv_openidattrib.is_userid = ""
	CloseWithReturn (this, inv_openidattrib)
	Return
End If

SetPointer (HourGlass!)
If rb_httpclient.checked Then
	li_rc = of_Login_HTTPClient (sle_userid.text, sle_password.text)
Else
	li_rc = of_Login_OAuthClient (sle_userid.text, sle_password.text)
End If

Choose Case li_rc
	Case 1
		If of_LoadUserInfo (inv_openidattrib.is_accesstoken) = 1 Then
			// Some providers (Microsoft Entra ID) only put the groups in the ID token
			If UpperBound (inv_openidattrib.is_groups) = 0 Then of_LoadIDTokenGroups (inv_openidattrib.is_idtoken)
			inv_openidattrib.ii_rc = 1
			inv_openidattrib.is_userid = sle_userid.text
			CloseWithReturn (this, inv_openidattrib)
			Return
		End If
		of_MessageBox ("pfc_openidlogon_userinfo", inv_openidattrib.is_appname, &
			"The user's information could not be read from the identity provider.", StopSign!, OK!, 1)
	Case -1
		of_MessageBox ("pfc_openidlogon_incorrectpassword", inv_openidattrib.is_appname, &
			"The User ID or password is incorrect.", StopSign!, OK!, 1)
	Case Else
		ls_parms[1] = inv_openidattrib.is_tokenendpoint
		of_MessageBox ("pfc_openidlogon_connect", inv_openidattrib.is_appname, &
			"The identity provider could not be reached (%s).", ls_parms, &
			StopSign!, OK!, 1)
End Choose

sle_password.SetFocus()
end event

event pfc_cancel;call super::pfc_cancel;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  pfc_cancel
//
//	Description:  Closes the window without logging on.  While the window waits for
//		the user to sign in in the browser, stops waiting instead.
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

If ib_waiting Then
	ib_cancelled = True
	inv_listener.of_Cancel()
	Return
End If

inv_openidattrib.ii_rc = 0
inv_openidattrib.is_userid = ""
CloseWithReturn (this, inv_openidattrib)
end event

event pfc_signin();//////////////////////////////////////////////////////////////////////////////
//
//	Event:  pfc_signin
//
//	Description:  Signs the user in in the web browser (the authorization code flow
//		with PKCE) and reads the user's groups.
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
string	ls_parms[]

If ib_waiting Then Return

If Len (inv_openidattrib.is_authorizationendpoint) = 0 Or Len (inv_openidattrib.is_tokenendpoint) = 0 &
	Or Len (inv_openidattrib.is_userinfoendpoint) = 0 Or Len (inv_openidattrib.is_clientid) = 0 Then
	of_MessageBox ("pfc_openidlogon_notconfiguredcode", inv_openidattrib.is_appname, &
		"The identity provider settings (authorization endpoint, token endpoint, userinfo endpoint and client ID) are missing.", &
		StopSign!, OK!, 1)
	inv_openidattrib.ii_rc = -1
	inv_openidattrib.is_userid = ""
	CloseWithReturn (this, inv_openidattrib)
	Return
End If

li_rc = of_Login_Code()
If IsValid (inv_listener) Then inv_listener.of_Stop()
of_SetFlow()

Choose Case li_rc
	Case 1
		If of_LoadUserInfo (inv_openidattrib.is_accesstoken) = 1 Then
			If UpperBound (inv_openidattrib.is_groups) = 0 Then of_LoadIDTokenGroups (inv_openidattrib.is_idtoken)
			inv_openidattrib.ii_rc = 1
			inv_openidattrib.is_userid = of_GetUserID()
			CloseWithReturn (this, inv_openidattrib)
			Return
		End If
		of_MessageBox ("pfc_openidlogon_userinfo", inv_openidattrib.is_appname, &
			"The user's information could not be read from the identity provider.", StopSign!, OK!, 1)
	Case 0
		// Cancelled: the user can sign in again, or cancel again to close the window
	Case -1
		ls_parms[1] = is_error
		of_MessageBox ("pfc_openidlogon_refused", inv_openidattrib.is_appname, &
			"The identity provider refused the sign-in (%s).", ls_parms, StopSign!, OK!, 1)
	Case -2
		ls_parms[1] = inv_openidattrib.is_tokenendpoint
		of_MessageBox ("pfc_openidlogon_connect", inv_openidattrib.is_appname, &
			"The identity provider could not be reached (%s).", ls_parms, &
			StopSign!, OK!, 1)
	Case -3
		of_MessageBox ("pfc_openidlogon_browser", inv_openidattrib.is_appname, &
			"The sign-in could not be started in the web browser.", StopSign!, OK!, 1)
	Case -4
		of_MessageBox ("pfc_openidlogon_timeout", inv_openidattrib.is_appname, &
			"You didn't sign in in the web browser in time. Click Sign In to try again.", Exclamation!, OK!, 1)
	Case Else
		of_MessageBox ("pfc_openidlogon_invalidresponse", inv_openidattrib.is_appname, &
			"The identity provider's response is not valid.", StopSign!, OK!, 1)
End Choose

cb_ok.SetFocus()
end event

event closequery;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  closequery
//
//	Description:  While the window waits for the user to sign in in the browser, it
//		can't close (the wait is still running): stops waiting instead.
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

If ib_waiting Then
	ib_cancelled = True
	inv_listener.of_Cancel()
	Return 1
End If

Return Super::Event closequery()
end event

event close;call super::close;If IsValid (inv_listener) Then Destroy inv_listener
If IsValid(inv_oauth2) Then Destroy inv_oauth2
end event

type st_help from u_st within pfc_w_openid_logon
integer x = 37
integer y = 44
integer width = 1742
integer height = 120
long backcolor = 79741120
string text = "Enter a User ID and password to log onto "
end type

type cb_ok from u_cb within pfc_w_openid_logon
integer x = 1842
integer y = 28
integer taborder = 30
string text = "OK"
boolean default = true
end type

event clicked;call u_cb::clicked;
parent.event pfc_default()
end event

type cb_cancel from u_cb within pfc_w_openid_logon
integer x = 1842
integer y = 140
integer taborder = 40
string text = "Cancel"
boolean cancel = true
end type

event clicked;call u_cb::clicked;
parent.event pfc_cancel()
end event

type sle_userid from u_sle within pfc_w_openid_logon
integer x = 681
integer y = 200
integer width = 1088
integer height = 76
integer taborder = 10
boolean autohscroll = true
end type

event constructor;call u_sle::constructor;
this.ib_autoselect = true
end event

type sle_password from u_sle within pfc_w_openid_logon
integer x = 681
integer y = 304
integer width = 1088
integer height = 76
integer taborder = 20
boolean autohscroll = true
boolean password = true
end type

event constructor;call u_sle::constructor;
this.ib_autoselect = true
end event

type st_2 from u_st within pfc_w_openid_logon
integer x = 82
integer y = 208
integer width = 571
integer height = 72
string text = "User ID:"
alignment alignment = right!
end type

type st_3 from u_st within pfc_w_openid_logon
integer x = 82
integer y = 308
integer width = 571
integer height = 72
string text = "Password:"
alignment alignment = right!
end type

type rb_oauthclient from u_rb within pfc_w_openid_logon
integer x = 681
integer y = 408
integer width = 500
integer height = 72
integer taborder = 50
string text = "OAuthClient"
boolean checked = true
end type

type rb_httpclient from u_rb within pfc_w_openid_logon
integer x = 1230
integer y = 408
integer width = 500
integer height = 72
integer taborder = 60
string text = "HTTPClient"
end type
