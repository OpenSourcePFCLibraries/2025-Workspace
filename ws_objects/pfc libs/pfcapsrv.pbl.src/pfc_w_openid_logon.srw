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
end type
global pfc_w_openid_logon pfc_w_openid_logon

type variables
Protected:
n_cst_openidattrib	inv_openidattrib
end variables

forward prototypes
protected function integer of_login_httpclient (string as_userid, string as_password)
protected function integer of_login_oauthclient (string as_userid, string as_password)
protected function integer of_loaduserinfo (string as_accesstoken)
protected function string of_urlencode (string as_value)
protected function string of_jsonstring (string as_json, string as_key)
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
//	 1 = logged on; the access token is in inv_openidattrib.is_accesstoken
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
//	 1 = logged on; the access token is in inv_openidattrib.is_accesstoken
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
//	Description:  Reads the user's claims from the userinfo endpoint and keeps the
//		"groups" claim (returned with the profile scope by providers such as Authentik).
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
JSONParser	lnv_json
Long			ll_rc, ll_root, ll_idx, ll_count, ll_groups, ll_group, ll_ngroups
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
		lnv_json = Create JSONParser
		If lnv_json.LoadString(ls_response) = "" Then
			ll_root = lnv_json.GetRootItem()
			ll_count = lnv_json.GetChildCount(ll_root)
			For ll_idx = 1 To ll_count
				If lnv_json.GetChildKey(ll_root, ll_idx) = "groups" Then
					ll_groups = lnv_json.GetChildItem(ll_root, ll_idx)
					If lnv_json.GetItemType(ll_groups) = JsonArrayItem! Then
						For ll_group = 1 To lnv_json.GetChildCount(ll_groups)
							ll_ngroups++
							ls_groups[ll_ngroups] = lnv_json.GetItemString(lnv_json.GetChildItem(ll_groups, ll_group))
							If ll_ngroups > 1 Then ls_list += ", "
							ls_list += ls_groups[ll_ngroups]
						Next
					End If
					Exit
				End If
			Next
			inv_openidattrib.is_userinfo = ls_response
			inv_openidattrib.is_groups = ls_groups
			li_rc = 1
		End If
		Destroy lnv_json
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
String		ls_encoded

If IsNull(as_value) Then Return ""

lnv_coder = Create CoderObject
ls_encoded = lnv_coder.UrlEncode(Blob(as_value, EncodingUTF8!))
Destroy lnv_coder

Return ls_encoded
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
Long			ll_root, ll_idx, ll_count, ll_item
String		ls_value

lnv_json = Create JSONParser
If lnv_json.LoadString(as_json) = "" Then
	ll_root = lnv_json.GetRootItem()
	ll_count = lnv_json.GetChildCount(ll_root)
	For ll_idx = 1 To ll_count
		If lnv_json.GetChildKey(ll_root, ll_idx) = as_key Then
			ll_item = lnv_json.GetChildItem(ll_root, ll_idx)
			If lnv_json.GetItemType(ll_item) = JsonStringItem! Then ls_value = lnv_json.GetItemString(ll_item)
			Exit
		End If
	Next
End If
Destroy lnv_json

Return ls_value
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

If Len (inv_openidattrib.is_appname) = 0 Then inv_openidattrib.is_appname = "the application"
st_help.text = st_help.text + inv_openidattrib.is_appname + "."

sle_userid.text = inv_openidattrib.is_userid

// The client choice is only offered when demonstrating
rb_httpclient.checked = (Lower(inv_openidattrib.is_client) = "httpclient")
rb_oauthclient.checked = Not rb_httpclient.checked
rb_oauthclient.visible = inv_openidattrib.ib_showresponses
rb_httpclient.visible = inv_openidattrib.ib_showresponses

If Len (sle_userid.text) > 0 Then
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
		of_MessageBox ("pfc_openidlogon_connect", inv_openidattrib.is_appname, &
			"The identity provider could not be reached (" + inv_openidattrib.is_tokenendpoint + ").", &
			StopSign!, OK!, 1)
End Choose

sle_password.SetFocus()
end event

event pfc_cancel;call super::pfc_cancel;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  pfc_cancel
//
//	Description:  Closes the window without logging on.
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

inv_openidattrib.ii_rc = 0
inv_openidattrib.is_userid = ""
CloseWithReturn (this, inv_openidattrib)
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
