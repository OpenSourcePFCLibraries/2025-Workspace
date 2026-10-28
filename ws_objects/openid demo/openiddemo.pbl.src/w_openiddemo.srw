$PBExportHeader$w_openiddemo.srw
$PBExportComments$PFC OpenID Connect demo: sign-in, OAuth 2.0 flows, groups and PFC security
forward
global type w_openiddemo from w_main
end type
type tab_1 from tab within w_openiddemo
end type
type tabpg_provider from userobject within tab_1
end type
type st_provider from statictext within tabpg_provider
end type
type st_authorization from statictext within tabpg_provider
end type
type sle_authorization from singlelineedit within tabpg_provider
end type
type st_token from statictext within tabpg_provider
end type
type sle_token from singlelineedit within tabpg_provider
end type
type st_userinfo from statictext within tabpg_provider
end type
type sle_userinfo from singlelineedit within tabpg_provider
end type
type st_device from statictext within tabpg_provider
end type
type sle_device from singlelineedit within tabpg_provider
end type
type st_clientid from statictext within tabpg_provider
end type
type sle_clientid from singlelineedit within tabpg_provider
end type
type st_secret from statictext within tabpg_provider
end type
type sle_secret from singlelineedit within tabpg_provider
end type
type st_scope from statictext within tabpg_provider
end type
type sle_scope from singlelineedit within tabpg_provider
end type
type st_groupsclaim from statictext within tabpg_provider
end type
type sle_groupsclaim from singlelineedit within tabpg_provider
end type
type cb_reload from u_cb within tabpg_provider
end type
type tabpg_provider from userobject within tab_1
st_provider st_provider
st_authorization st_authorization
sle_authorization sle_authorization
st_token st_token
sle_token sle_token
st_userinfo st_userinfo
sle_userinfo sle_userinfo
st_device st_device
sle_device sle_device
st_clientid st_clientid
sle_clientid sle_clientid
st_secret st_secret
sle_secret sle_secret
st_scope st_scope
sle_scope sle_scope
st_groupsclaim st_groupsclaim
sle_groupsclaim sle_groupsclaim
cb_reload cb_reload
end type
type tabpg_signin from userobject within tab_1
end type
type st_signin from statictext within tabpg_signin
end type
type rb_password from radiobutton within tabpg_signin
end type
type rb_code from radiobutton within tabpg_signin
end type
type cbx_responses from checkbox within tabpg_signin
end type
type cb_signin from u_cb within tabpg_signin
end type
type st_user from statictext within tabpg_signin
end type
type sle_user from singlelineedit within tabpg_signin
end type
type mle_signin from multilineedit within tabpg_signin
end type
type tabpg_signin from userobject within tab_1
st_signin st_signin
rb_password rb_password
rb_code rb_code
cbx_responses cbx_responses
cb_signin cb_signin
st_user st_user
sle_user sle_user
mle_signin mle_signin
end type
type tabpg_oauth2 from userobject within tab_1
end type
type st_oauth2 from statictext within tabpg_oauth2
end type
type st_flow from statictext within tabpg_oauth2
end type
type ddlb_flow from dropdownlistbox within tabpg_oauth2
end type
type cb_token from u_cb within tabpg_oauth2
end type
type cb_refresh from u_cb within tabpg_oauth2
end type
type cb_cancel from u_cb within tabpg_oauth2
end type
type cb_forget from u_cb within tabpg_oauth2
end type
type mle_oauth2 from multilineedit within tabpg_oauth2
end type
type tabpg_oauth2 from userobject within tab_1
st_oauth2 st_oauth2
st_flow st_flow
ddlb_flow ddlb_flow
cb_token cb_token
cb_refresh cb_refresh
cb_cancel cb_cancel
cb_forget cb_forget
mle_oauth2 mle_oauth2
end type
type tabpg_security from userobject within tab_1
end type
type st_security from statictext within tabpg_security
end type
type st_groups from statictext within tabpg_security
end type
type mle_groups from multilineedit within tabpg_security
end type
type st_map from statictext within tabpg_security
end type
type mle_map from multilineedit within tabpg_security
end type
type cb_map from u_cb within tabpg_security
end type
type st_mapped from statictext within tabpg_security
end type
type lb_mapped from listbox within tabpg_security
end type
type cb_secure from u_cb within tabpg_security
end type
type st_status from statictext within tabpg_security
end type
type tabpg_security from userobject within tab_1
st_security st_security
st_groups st_groups
mle_groups mle_groups
st_map st_map
mle_map mle_map
cb_map cb_map
st_mapped st_mapped
lb_mapped lb_mapped
cb_secure cb_secure
st_status st_status
end type
type tab_1 from tab within w_openiddemo
tabpg_provider tabpg_provider
tabpg_signin tabpg_signin
tabpg_oauth2 tabpg_oauth2
tabpg_security tabpg_security
end type
type cb_close from u_cb within w_openiddemo
end type
end forward

global type w_openiddemo from w_main
integer x = 594
integer y = 300
integer width = 2551
integer height = 1940
string title = "PFC OpenID Connect Demo"
tab_1 tab_1
cb_close cb_close
end type
global w_openiddemo w_openiddemo

type variables
Protected:
// The application's name in the security database
Constant String APPNAME = "openiddemo"
// The section of openiddemo.ini with the identity provider
Constant String SECTION = "OpenID"
string	is_inifile

// The signed-in user (Sign In tab), and the PFC security groups of the map
string	is_userid
string	is_mapped[]

// The OAuth 2.0 service of the OAuth 2.0 Flows tab: it keeps its tokens
n_cst_oauth2	inv_oauth2
// The security database
n_tr	itr_security
end variables

forward prototypes
public subroutine of_loadsettings ()
protected function integer of_readsection (string as_inifile, string as_section, ref string as_keys[], ref string as_values[])
protected function long of_lines (string as_text, ref string as_lines[])
protected function string of_decodejwt (string as_token)
protected function string of_formatjson (string as_json)
public subroutine of_signin ()
protected function string of_flow ()
protected subroutine of_setupoauth2 ()
protected subroutine of_setbusy (boolean ab_busy)
public subroutine of_gettoken ()
public subroutine of_refreshtoken ()
public subroutine of_canceltoken ()
public subroutine of_forgettokens ()
protected subroutine of_showtokens (integer ai_rc)
protected function string of_result (integer ai_rc)
public function long of_mapgroups ()
public subroutine of_applysecurity ()
end prototypes

public subroutine of_loadsettings ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_LoadSettings
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Shows the settings of openiddemo.ini: the identity provider ([OpenID]) and
//		the group map ([GroupMap]).
//
//////////////////////////////////////////////////////////////////////////////

string	ls_keys[], ls_values[], ls_map
long		ll_i

tab_1.tabpg_provider.sle_authorization.Text = ProfileString(is_inifile, SECTION, "AuthorizationEndpoint", "")
tab_1.tabpg_provider.sle_token.Text = ProfileString(is_inifile, SECTION, "TokenEndpoint", "")
tab_1.tabpg_provider.sle_userinfo.Text = ProfileString(is_inifile, SECTION, "UserInfoEndpoint", "")
tab_1.tabpg_provider.sle_device.Text = ProfileString(is_inifile, SECTION, "DeviceAuthorizationEndpoint", "")
tab_1.tabpg_provider.sle_clientid.Text = ProfileString(is_inifile, SECTION, "ClientID", "")
tab_1.tabpg_provider.sle_secret.Text = ProfileString(is_inifile, SECTION, "ClientSecret", "")
tab_1.tabpg_provider.sle_scope.Text = ProfileString(is_inifile, SECTION, "Scope", "")
tab_1.tabpg_provider.sle_groupsclaim.Text = ProfileString(is_inifile, SECTION, "GroupsClaim", "")
If tab_1.tabpg_provider.sle_scope.Text = "" Then tab_1.tabpg_provider.sle_scope.Text = "openid profile"
If tab_1.tabpg_provider.sle_groupsclaim.Text = "" Then tab_1.tabpg_provider.sle_groupsclaim.Text = "groups"
If Lower(ProfileString(is_inifile, SECTION, "Flow", "password")) = "code" Then
	tab_1.tabpg_signin.rb_code.Checked = True
Else
	tab_1.tabpg_signin.rb_password.Checked = True
End If

of_ReadSection(is_inifile, "GroupMap", ls_keys, ls_values)
For ll_i = 1 To UpperBound(ls_keys)
	ls_map += ls_keys[ll_i] + "=" + ls_values[ll_i] + "~r~n"
Next
tab_1.tabpg_security.mle_map.Text = ls_map

If Not FileExists(is_inifile) Then
	tab_1.tabpg_provider.st_provider.Text = is_inifile + " doesn't exist: copy openiddemo.ini.example to it and fill in the settings " + &
		"(see the README), or type them here."
End If
end subroutine

protected function integer of_readsection (string as_inifile, string as_section, ref string as_keys[], ref string as_values[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ReadSection
//
//	Access:  protected
//
//	Arguments:
//	as_inifile	an INI file
//	as_section	one of its sections
//	as_keys[]	the keys of the section (by reference)
//	as_values[]	their values (by reference)
//
//	Returns:  Integer.  The number of keys
//
//	Description:  ProfileString reads one key; the group map is a list of keys.
//
//////////////////////////////////////////////////////////////////////////////

integer	li_file, li_count
long		ll_pos
string	ls_line
boolean	lb_in
string	ls_empty[]

as_keys = ls_empty
as_values = ls_empty
li_file = FileOpen(as_inifile, LineMode!, Read!, Shared!)
If li_file < 0 Then Return 0

Do While FileRead(li_file, ls_line) >= 0
	ls_line = Trim(ls_line)
	If Left(ls_line, 1) = "[" Then
		lb_in = (Lower(ls_line) = "[" + Lower(as_section) + "]")
	ElseIf lb_in And ls_line <> "" And Left(ls_line, 1) <> ";" Then
		ll_pos = Pos(ls_line, "=")
		If ll_pos > 1 Then
			li_count++
			as_keys[li_count] = Trim(Left(ls_line, ll_pos - 1))
			as_values[li_count] = Trim(Mid(ls_line, ll_pos + 1))
		End If
	End If
Loop
FileClose(li_file)
Return li_count
end function

protected function long of_lines (string as_text, ref string as_lines[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Lines
//
//	Access:  protected
//
//	Arguments:
//	as_text	text, one item per line
//	as_lines[]	its lines that aren't empty, trimmed (by reference)
//
//	Returns:  Long.  The number of lines
//
//	Description:  
//
//////////////////////////////////////////////////////////////////////////////

long		ll_pos, ll_count
string	ls_line
string	ls_empty[]

as_lines = ls_empty
as_text = as_text + "~n"
Do While Len(as_text) > 0
	ll_pos = Pos(as_text, "~n")
	ls_line = Trim(Left(as_text, ll_pos - 1))
	If Right(ls_line, 1) = "~r" Then ls_line = Trim(Left(ls_line, Len(ls_line) - 1))
	as_text = Mid(as_text, ll_pos + 1)
	If ls_line <> "" Then
		ll_count++
		as_lines[ll_count] = ls_line
	End If
Loop
Return ll_count
end function

protected function string of_decodejwt (string as_token);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_DecodeJWT
//
//	Access:  protected
//
//	Arguments:
//	as_token	a JSON Web Token, such as an ID token
//
//	Returns:  String.  Its payload (the claims), JSON; "" if it isn't a JWT
//
//	Description:  A JWT is header.payload.signature, each part base64url-encoded.  The
//		signature isn't checked: the token came from the identity provider over HTTPS.
//
//////////////////////////////////////////////////////////////////////////////

long			ll_first, ll_second
blob			lblb_payload
CoderObject	lco_coder

ll_first = Pos(as_token, ".")
If ll_first = 0 Then Return ""
ll_second = Pos(as_token, ".", ll_first + 1)
If ll_second = 0 Then Return ""

lco_coder = Create CoderObject
Try
	lblb_payload = lco_coder.Base64UrlDecode(Mid(as_token, ll_first + 1, ll_second - ll_first - 1))
Catch (Throwable lth_error)
	// not base64url: not a JWT
Finally
	Destroy lco_coder
End Try
Return String(lblb_payload, EncodingUTF8!)
end function

protected function string of_formatjson (string as_json);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_FormatJSON
//
//	Access:  protected
//
//	Arguments:
//	as_json	JSON
//
//	Returns:  String.  The JSON indented, one member per line
//
//	Description:  
//
//////////////////////////////////////////////////////////////////////////////

string	ls_out, ls_char
long		ll_i, ll_len, ll_level
boolean	lb_string, lb_escape

ll_len = Len(as_json)
For ll_i = 1 To ll_len
	ls_char = Mid(as_json, ll_i, 1)
	If lb_string Then
		ls_out += ls_char
		If lb_escape Then
			lb_escape = False
		ElseIf ls_char = "\" Then
			lb_escape = True
		ElseIf ls_char = "~"" Then
			lb_string = False
		End If
		Continue
	End If
	Choose Case ls_char
		Case "~""
			lb_string = True
			ls_out += ls_char
		Case "{", "["
			ll_level++
			ls_out += ls_char + "~r~n" + Fill(" ", ll_level * 3)
		Case "}", "]"
			ll_level --
			ls_out += "~r~n" + Fill(" ", ll_level * 3) + ls_char
		Case ","
			ls_out += ",~r~n" + Fill(" ", ll_level * 3)
		Case ":"
			ls_out += ": "
		Case " ", "~t", "~r", "~n"
		Case Else
			ls_out += ls_char
	End Choose
Next
Return ls_out
end function

public subroutine of_signin ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SignIn
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Signs in with the logon window (gnv_app.of_OpenIDLogonDlg) and the settings
//		of the Identity Provider tab, and shows the user, the groups, the ID token's
//		claims and the userinfo response.  The groups go to the Groups and Security tab.
//
//////////////////////////////////////////////////////////////////////////////

n_cst_openidattrib	lnv_openid		// autoinstantiated
integer	li_rc
long		ll_i
string	ls_text, ls_groups

lnv_openid.is_appname = "PFC OpenID Connect Demo"
lnv_openid.is_tokenendpoint = Trim(tab_1.tabpg_provider.sle_token.Text)
lnv_openid.is_userinfoendpoint = Trim(tab_1.tabpg_provider.sle_userinfo.Text)
lnv_openid.is_authorizationendpoint = Trim(tab_1.tabpg_provider.sle_authorization.Text)
lnv_openid.is_clientid = Trim(tab_1.tabpg_provider.sle_clientid.Text)
If Trim(tab_1.tabpg_provider.sle_scope.Text) <> "" Then lnv_openid.is_scope = Trim(tab_1.tabpg_provider.sle_scope.Text)
If Trim(tab_1.tabpg_provider.sle_groupsclaim.Text) <> "" Then lnv_openid.is_groupsclaim = Trim(tab_1.tabpg_provider.sle_groupsclaim.Text)
If tab_1.tabpg_signin.rb_code.Checked Then
	lnv_openid.is_flow = "code"
Else
	lnv_openid.is_flow = "password"
End If
lnv_openid.ib_showresponses = tab_1.tabpg_signin.cbx_responses.Checked

// Settings left empty are read from the INI file by the overload with an INI file;
// this one uses the window's settings as they are
li_rc = gnv_app.of_OpenIDLogonDlg(lnv_openid)

Choose Case li_rc
	Case 1
		is_userid = lnv_openid.is_userid
		tab_1.tabpg_signin.sle_user.Text = is_userid
		For ll_i = 1 To UpperBound(lnv_openid.is_groups)
			ls_groups += lnv_openid.is_groups[ll_i] + "~r~n"
		Next
		ls_text = "Groups (the " + lnv_openid.is_groupsclaim + " claim): "
		If ls_groups = "" Then
			ls_text += "none~r~n"
		Else
			ls_text += "~r~n" + ls_groups
		End If
		If lnv_openid.is_idtoken <> "" Then
			ls_text += "~r~nID token claims:~r~n" + of_FormatJSON(of_DecodeJWT(lnv_openid.is_idtoken)) + "~r~n"
		Else
			ls_text += "~r~nNo ID token (the scope must include openid).~r~n"
		End If
		If lnv_openid.is_userinfo <> "" Then ls_text += "~r~nUserinfo response:~r~n" + of_FormatJSON(lnv_openid.is_userinfo) + "~r~n"
		tab_1.tabpg_signin.mle_signin.Text = ls_text
		tab_1.tabpg_security.mle_groups.Text = ls_groups
		of_MapGroups()
	Case 0
		tab_1.tabpg_signin.mle_signin.Text = "The sign-in was cancelled."
	Case Else
		tab_1.tabpg_signin.mle_signin.Text = "The sign-in failed.  Check the settings of the Identity Provider tab, and show the identity provider's responses to see why."
End Choose

end subroutine

protected function string of_flow ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Flow
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  String.  The n_cst_oauth2 flow chosen on the OAuth 2.0 Flows tab
//
//	Description:  
//
//////////////////////////////////////////////////////////////////////////////

Choose Case tab_1.tabpg_oauth2.ddlb_flow.FindItem(tab_1.tabpg_oauth2.ddlb_flow.Text, 0)
	Case 2
		Return inv_oauth2.DEVICECODE
	Case 3
		Return inv_oauth2.CLIENTCREDENTIALS
End Choose
Return inv_oauth2.AUTHORIZATIONCODE
end function

protected subroutine of_setupoauth2 ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetupOAuth2
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Gives the OAuth 2.0 service the settings of the Identity Provider tab.  The
//		tokens it has are kept.
//
//////////////////////////////////////////////////////////////////////////////

inv_oauth2.of_SetEndpoints(Trim(tab_1.tabpg_provider.sle_authorization.Text), Trim(tab_1.tabpg_provider.sle_token.Text), Trim(tab_1.tabpg_provider.sle_device.Text))
If Trim(tab_1.tabpg_provider.sle_secret.Text) = "" Then
	inv_oauth2.of_SetClient(Trim(tab_1.tabpg_provider.sle_clientid.Text))
Else
	inv_oauth2.of_SetClient(Trim(tab_1.tabpg_provider.sle_clientid.Text), Trim(tab_1.tabpg_provider.sle_secret.Text))
End If
inv_oauth2.of_SetScope(Trim(tab_1.tabpg_provider.sle_scope.Text))
end subroutine

protected subroutine of_setbusy (boolean ab_busy);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetBusy
//
//	Access:  protected
//
//	Arguments:
//	ab_busy	True while the OAuth 2.0 service waits for the identity provider or the user
//
//	Returns:  None
//
//	Description:  Only Cancel can be clicked while the service waits.
//
//////////////////////////////////////////////////////////////////////////////

tab_1.tabpg_oauth2.cb_token.Enabled = Not ab_busy
tab_1.tabpg_oauth2.cb_refresh.Enabled = Not ab_busy
tab_1.tabpg_oauth2.cb_forget.Enabled = Not ab_busy
tab_1.tabpg_oauth2.cb_cancel.Enabled = ab_busy
cb_close.Enabled = Not ab_busy
end subroutine

public subroutine of_gettoken ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetToken
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Gets a token with the flow chosen: the browser opens, or the device code is
//		put on the clipboard and the sign-in page opens, or the application signs in.
//
//////////////////////////////////////////////////////////////////////////////

string	ls_flow
integer	li_rc

of_SetupOAuth2()
ls_flow = of_Flow()
Choose Case ls_flow
	Case inv_oauth2.AUTHORIZATIONCODE
		tab_1.tabpg_oauth2.mle_oauth2.Text = "Sign in in your web browser (Cancel stops waiting)..."
	Case inv_oauth2.DEVICECODE
		tab_1.tabpg_oauth2.mle_oauth2.Text = "Getting a device code: it will be on the clipboard, and the sign-in page will open (Cancel stops waiting)..."
	Case Else
		tab_1.tabpg_oauth2.mle_oauth2.Text = "Getting a token for the application..."
End Choose

of_SetBusy(True)
li_rc = inv_oauth2.of_Authorize(ls_flow)
of_SetBusy(False)
of_ShowTokens(li_rc)
end subroutine

public subroutine of_refreshtoken ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_RefreshToken
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Gets a new access token with the refresh token, without signing in.
//
//////////////////////////////////////////////////////////////////////////////

integer	li_rc

If inv_oauth2.of_GetRefreshToken() = "" Then
	tab_1.tabpg_oauth2.mle_oauth2.Text = "There is no refresh token: get a token first, with the authorization code or device code flow (the identity provider may need the offline_access scope)."
	Return
End If
of_SetupOAuth2()
of_SetBusy(True)
li_rc = inv_oauth2.of_Refresh()
of_SetBusy(False)
of_ShowTokens(li_rc)
end subroutine

public subroutine of_canceltoken ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_CancelToken
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Stops waiting for the user.
//
//////////////////////////////////////////////////////////////////////////////

inv_oauth2.of_Cancel()
end subroutine

public subroutine of_forgettokens ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ForgetTokens
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Forgets the tokens, so the next token needs a sign-in.
//
//////////////////////////////////////////////////////////////////////////////

inv_oauth2.of_Reset()
tab_1.tabpg_oauth2.mle_oauth2.Text = "The tokens are forgotten."
end subroutine

protected subroutine of_showtokens (integer ai_rc);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ShowTokens
//
//	Access:  protected
//
//	Arguments:
//	ai_rc	the return code of of_Authorize or of_Refresh
//
//	Returns:  None
//
//	Description:  Shows the tokens, or why there are none, and the identity provider's
//		last response.
//
//////////////////////////////////////////////////////////////////////////////

string	ls_text, ls_token

If ai_rc = 1 Then
	ls_token = inv_oauth2.of_GetAccessToken()
	ls_text = "Access token: " + Left(ls_token, 40) + "... (" + String(Len(ls_token)) + " characters)~r~n"
	If IsNull(inv_oauth2.of_GetExpires()) Then
		ls_text += "Expires: not given~r~n"
	Else
		ls_text += "Expires: " + String(inv_oauth2.of_GetExpires(), "yyyy-mm-dd hh:mm:ss") + "~r~n"
	End If
	If inv_oauth2.of_GetRefreshToken() = "" Then
		ls_text += "Refresh token: none~r~n"
	Else
		ls_text += "Refresh token: yes (Refresh the Token gets a new access token without signing in)~r~n"
	End If
	If inv_oauth2.of_GetIDToken() <> "" Then
		ls_text += "~r~nID token claims:~r~n" + of_FormatJSON(of_DecodeJWT(inv_oauth2.of_GetIDToken())) + "~r~n"
	End If
	// an access token that is a JWT (Entra ID, Authentik) has claims too
	If of_DecodeJWT(ls_token) <> "" Then
		ls_text += "~r~nAccess token claims:~r~n" + of_FormatJSON(of_DecodeJWT(ls_token)) + "~r~n"
	End If
Else
	ls_text = of_Result(ai_rc) + "~r~n"
	If inv_oauth2.of_GetErrorCode() <> "" Then ls_text += "Error: " + inv_oauth2.of_GetErrorCode() + "~r~n"
	If inv_oauth2.of_GetUserCode() <> "" Then
		ls_text += "~r~nDevice code: " + inv_oauth2.of_GetUserCode() + " at " + inv_oauth2.of_GetVerificationUri() + "~r~n"
	End If
	If inv_oauth2.of_GetResponse() <> "" Then
		ls_text += "~r~nThe identity provider's last response:~r~n" + of_FormatJSON(inv_oauth2.of_GetResponse()) + "~r~n"
	End If
End If
tab_1.tabpg_oauth2.mle_oauth2.Text = ls_text
end subroutine

protected function string of_result (integer ai_rc);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Result
//
//	Access:  protected
//
//	Arguments:
//	ai_rc	a return code of n_cst_oauth2.of_Authorize or of_Refresh
//
//	Returns:  String.  What it means
//
//	Description:  
//
//////////////////////////////////////////////////////////////////////////////

string	ls_error

ls_error = inv_oauth2.of_GetError()
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
Return "Error " + String(ai_rc) + ": " + ls_error
end function

public function long of_mapgroups ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_MapGroups
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Long.  The number of PFC security groups
//
//	Description:  Maps the identity provider's groups to PFC security groups with the group
//		map (n_cst_security.of_MapGroups): a group not in the map is passed on
//		unchanged; a group mapped to nothing (name=) isn't used.
//
//////////////////////////////////////////////////////////////////////////////

string	ls_groups[], ls_map[], ls_from[], ls_to[]
long		ll_i, ll_pos, ll_count
n_cst_security	lnv_security

of_Lines(tab_1.tabpg_security.mle_groups.Text, ls_groups)
of_Lines(tab_1.tabpg_security.mle_map.Text, ls_map)
For ll_i = 1 To UpperBound(ls_map)
	ll_pos = Pos(ls_map[ll_i], "=")
	If ll_pos > 1 Then
		ll_count++
		ls_from[ll_count] = Trim(Left(ls_map[ll_i], ll_pos - 1))
		ls_to[ll_count] = Trim(Mid(ls_map[ll_i], ll_pos + 1))
	End If
Next

// of_MapGroups doesn't need security to be initialized
If IsValid(gnv_app.inv_security) Then
	gnv_app.inv_security.of_MapGroups(ls_groups, ls_from, ls_to, is_mapped)
Else
	lnv_security = Create n_cst_security
	lnv_security.of_MapGroups(ls_groups, ls_from, ls_to, is_mapped)
	Destroy lnv_security
End If

tab_1.tabpg_security.lb_mapped.Reset()
For ll_i = 1 To UpperBound(is_mapped)
	tab_1.tabpg_security.lb_mapped.AddItem(is_mapped[ll_i])
Next
Return UpperBound(is_mapped)
end function

public subroutine of_applysecurity ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ApplySecurity
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Connects to the security database ([Security] of openiddemo.ini), initializes
//		PFC security for the signed-in user with the mapped groups (of_InitSecurity),
//		and opens the secured window, which applies it (of_SetSecurity).
//
//////////////////////////////////////////////////////////////////////////////

integer	li_rc
string	ls_default, ls_message

If is_userid = "" Then
	tab_1.tabpg_security.st_status.Text = "Sign in first, on the Sign In tab: security is for the signed-in user."
	Return
End If
of_MapGroups()

If Not IsValid(itr_security) Then itr_security = Create n_tr
If Not itr_security.of_IsConnected() Then
	If itr_security.of_Init(is_inifile, "Security") = -1 Then
		tab_1.tabpg_security.st_status.Text = "The [Security] section of " + is_inifile + " has the security database's connection; it can't be read."
		Return
	End If
	If itr_security.of_Connect() <> 0 Then
		tab_1.tabpg_security.st_status.Text = "Unable to connect to the security database: " + itr_security.SQLErrText
		Return
	End If
End If

ls_default = ProfileString(is_inifile, "Security", "DefaultGroup", "")
gnv_app.of_SetSecurity(True)
li_rc = gnv_app.inv_security.of_InitSecurity(itr_security, APPNAME, is_userid, is_mapped, ls_default)
Choose Case li_rc
	Case 1
		ls_message = "Security is initialized for " + is_userid + "."
	Case -2
		ls_message = "The security database doesn't have the application " + APPNAME + ": scan it with the security scanner (openid demo.pbproj)."
	Case -4, -5
		ls_message = "None of the groups is a PFC security group, and there is no default group (DefaultGroup in [Security]).  Define the groups in the security administrator, or map the provider's groups to them."
	Case Else
		ls_message = "Security could not be initialized (" + String(li_rc) + "): " + itr_security.SQLErrText
End Choose
tab_1.tabpg_security.st_status.Text = ls_message
If li_rc <> 1 Then Return

Open(w_openiddemo_secured)
end subroutine

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	Reads the settings of openiddemo.ini.
//
//////////////////////////////////////////////////////////////////////////////
is_inifile = gnv_app.of_GetAppIniFile()
If Mid(is_inifile, 2, 1) <> ":" Then is_inifile = GetCurrentDirectory() + "\" + is_inifile
inv_oauth2 = Create n_cst_oauth2
tab_1.tabpg_oauth2.ddlb_flow.SelectItem(1)
of_LoadSettings()
end event

event closequery;call super::closequery;// Don't close while the OAuth 2.0 service waits for the user: Cancel first
If Not cb_close.Enabled Then Return 1
Return AncestorReturnValue
end event

event close;call super::close;If IsValid(inv_oauth2) Then Destroy inv_oauth2
If IsValid(itr_security) Then
	If itr_security.of_IsConnected() Then itr_security.of_Disconnect()
	Destroy itr_security
End If
end event

on w_openiddemo.create
int iCurrent
call super::create
this.tab_1=create tab_1
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.tab_1
this.Control[iCurrent+2]=this.cb_close
end on

on w_openiddemo.destroy
call super::destroy
destroy(this.tab_1)
destroy(this.cb_close)
end on

type tab_1 from tab within w_openiddemo
integer x = 37
integer y = 32
integer width = 2459
integer height = 1620
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long backcolor = 67108864
boolean raggedright = true
boolean focusonbuttondown = true
integer selectedtab = 1
tabpg_provider tabpg_provider
tabpg_signin tabpg_signin
tabpg_oauth2 tabpg_oauth2
tabpg_security tabpg_security
end type

on tab_1.create
this.tabpg_provider=create tabpg_provider
this.tabpg_signin=create tabpg_signin
this.tabpg_oauth2=create tabpg_oauth2
this.tabpg_security=create tabpg_security
this.Control[]={this.tabpg_provider,&
this.tabpg_signin,&
this.tabpg_oauth2,&
this.tabpg_security}
end on

on tab_1.destroy
destroy(this.tabpg_provider)
destroy(this.tabpg_signin)
destroy(this.tabpg_oauth2)
destroy(this.tabpg_security)
end on

type tabpg_provider from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1504
long backcolor = 67108864
string text = "Identity Provider"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_provider st_provider
st_authorization st_authorization
sle_authorization sle_authorization
st_token st_token
sle_token sle_token
st_userinfo st_userinfo
sle_userinfo sle_userinfo
st_device st_device
sle_device sle_device
st_clientid st_clientid
sle_clientid sle_clientid
st_secret st_secret
sle_secret sle_secret
st_scope st_scope
sle_scope sle_scope
st_groupsclaim st_groupsclaim
sle_groupsclaim sle_groupsclaim
cb_reload cb_reload
end type

on tabpg_provider.create
this.st_provider=create st_provider
this.st_authorization=create st_authorization
this.sle_authorization=create sle_authorization
this.st_token=create st_token
this.sle_token=create sle_token
this.st_userinfo=create st_userinfo
this.sle_userinfo=create sle_userinfo
this.st_device=create st_device
this.sle_device=create sle_device
this.st_clientid=create st_clientid
this.sle_clientid=create sle_clientid
this.st_secret=create st_secret
this.sle_secret=create sle_secret
this.st_scope=create st_scope
this.sle_scope=create sle_scope
this.st_groupsclaim=create st_groupsclaim
this.sle_groupsclaim=create sle_groupsclaim
this.cb_reload=create cb_reload
this.Control[]={this.st_provider,&
this.st_authorization,&
this.sle_authorization,&
this.st_token,&
this.sle_token,&
this.st_userinfo,&
this.sle_userinfo,&
this.st_device,&
this.sle_device,&
this.st_clientid,&
this.sle_clientid,&
this.st_secret,&
this.sle_secret,&
this.st_scope,&
this.sle_scope,&
this.st_groupsclaim,&
this.sle_groupsclaim,&
this.cb_reload}
end on

on tabpg_provider.destroy
destroy(this.st_provider)
destroy(this.st_authorization)
destroy(this.sle_authorization)
destroy(this.st_token)
destroy(this.sle_token)
destroy(this.st_userinfo)
destroy(this.sle_userinfo)
destroy(this.st_device)
destroy(this.sle_device)
destroy(this.st_clientid)
destroy(this.sle_clientid)
destroy(this.st_secret)
destroy(this.sle_secret)
destroy(this.st_scope)
destroy(this.sle_scope)
destroy(this.st_groupsclaim)
destroy(this.sle_groupsclaim)
destroy(this.cb_reload)
end on

type st_provider from statictext within tabpg_provider
integer x = 32
integer y = 24
integer width = 2350
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "The identity provider and the application registered with it.  They are read from the [OpenID] section of openiddemo.ini (copy openiddemo.ini.example, next to it); see the README for Authentik, Microsoft Entra ID and Google.  Change them here to try other values: they are used by the other tabs, but not saved."
boolean focusrectangle = false
end type

type st_authorization from statictext within tabpg_provider
integer x = 32
integer y = 252
integer width = 640
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Authorization endpoint:"
boolean focusrectangle = false
end type

type sle_authorization from singlelineedit within tabpg_provider
integer x = 690
integer y = 240
integer width = 1692
integer height = 84
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_token from statictext within tabpg_provider
integer x = 32
integer y = 352
integer width = 640
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Token endpoint:"
boolean focusrectangle = false
end type

type sle_token from singlelineedit within tabpg_provider
integer x = 690
integer y = 340
integer width = 1692
integer height = 84
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_userinfo from statictext within tabpg_provider
integer x = 32
integer y = 452
integer width = 640
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Userinfo endpoint:"
boolean focusrectangle = false
end type

type sle_userinfo from singlelineedit within tabpg_provider
integer x = 690
integer y = 440
integer width = 1692
integer height = 84
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_device from statictext within tabpg_provider
integer x = 32
integer y = 552
integer width = 640
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Device endpoint:"
boolean focusrectangle = false
end type

type sle_device from singlelineedit within tabpg_provider
integer x = 690
integer y = 540
integer width = 1692
integer height = 84
integer taborder = 40
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_clientid from statictext within tabpg_provider
integer x = 32
integer y = 652
integer width = 640
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Client &ID:"
boolean focusrectangle = false
end type

type sle_clientid from singlelineedit within tabpg_provider
integer x = 690
integer y = 640
integer width = 1692
integer height = 84
integer taborder = 50
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_secret from statictext within tabpg_provider
integer x = 32
integer y = 752
integer width = 640
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Client &secret:"
boolean focusrectangle = false
end type

type sle_secret from singlelineedit within tabpg_provider
integer x = 690
integer y = 740
integer width = 1692
integer height = 84
integer taborder = 60
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean autohscroll = true
boolean password = true
borderstyle borderstyle = stylelowered!
end type

type st_scope from statictext within tabpg_provider
integer x = 32
integer y = 852
integer width = 640
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "S&cope:"
boolean focusrectangle = false
end type

type sle_scope from singlelineedit within tabpg_provider
integer x = 690
integer y = 840
integer width = 1692
integer height = 84
integer taborder = 70
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_groupsclaim from statictext within tabpg_provider
integer x = 32
integer y = 952
integer width = 640
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Groups claim:"
boolean focusrectangle = false
end type

type sle_groupsclaim from singlelineedit within tabpg_provider
integer x = 690
integer y = 940
integer width = 1692
integer height = 84
integer taborder = 80
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type cb_reload from u_cb within tabpg_provider
integer x = 32
integer y = 1072
integer width = 660
integer taborder = 100
string text = "&Reload openiddemo.ini"
end type

event clicked;call super::clicked;w_openiddemo.of_LoadSettings()
end event

type tabpg_signin from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1504
long backcolor = 67108864
string text = "Sign In"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_signin st_signin
rb_password rb_password
rb_code rb_code
cbx_responses cbx_responses
cb_signin cb_signin
st_user st_user
sle_user sle_user
mle_signin mle_signin
end type

on tabpg_signin.create
this.st_signin=create st_signin
this.rb_password=create rb_password
this.rb_code=create rb_code
this.cbx_responses=create cbx_responses
this.cb_signin=create cb_signin
this.st_user=create st_user
this.sle_user=create sle_user
this.mle_signin=create mle_signin
this.Control[]={this.st_signin,&
this.rb_password,&
this.rb_code,&
this.cbx_responses,&
this.cb_signin,&
this.st_user,&
this.sle_user,&
this.mle_signin}
end on

on tabpg_signin.destroy
destroy(this.st_signin)
destroy(this.rb_password)
destroy(this.rb_code)
destroy(this.cbx_responses)
destroy(this.cb_signin)
destroy(this.st_user)
destroy(this.sle_user)
destroy(this.mle_signin)
end on

type st_signin from statictext within tabpg_signin
integer x = 32
integer y = 24
integer width = 2350
integer height = 208
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "PFC's logon window, w_openid_logon (gnv_app.of_OpenIDLogonDlg).  With the password grant, the user types the user ID and password in it; with the authorization code flow, the user signs in in the web browser, with MFA and single sign-on.  The groups come from the userinfo response or the ID token."
boolean focusrectangle = false
end type

type rb_password from radiobutton within tabpg_signin
integer x = 32
integer y = 240
integer width = 1780
integer height = 80
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Password grant: the logon window asks for the user ID and password"
boolean checked = true
end type

type rb_code from radiobutton within tabpg_signin
integer x = 32
integer y = 320
integer width = 1780
integer height = 80
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Authorization &code flow with PKCE: sign in in the web browser"
end type

type cbx_responses from checkbox within tabpg_signin
integer x = 32
integer y = 400
integer width = 1780
integer height = 80
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Show the identity provider's &responses in the logon window"
end type

type cb_signin from u_cb within tabpg_signin
integer x = 1824
integer y = 236
integer width = 558
integer taborder = 40
string text = "&Sign In..."
end type

event clicked;call super::clicked;w_openiddemo.of_SignIn()
end event

type st_user from statictext within tabpg_signin
integer x = 32
integer y = 524
integer width = 320
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Signed in as:"
boolean focusrectangle = false
end type

type sle_user from singlelineedit within tabpg_signin
integer x = 360
integer y = 512
integer width = 1000
integer height = 84
integer taborder = 50
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean autohscroll = true
boolean displayonly = true
borderstyle borderstyle = stylelowered!
end type

type mle_signin from multilineedit within tabpg_signin
integer x = 32
integer y = 620
integer width = 2350
integer height = 864
integer taborder = 60
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean vscrollbar = true
boolean autovscroll = true
boolean displayonly = true
boolean hscrollbar = true
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type tabpg_oauth2 from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1504
long backcolor = 67108864
string text = "OAuth 2.0 Flows"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_oauth2 st_oauth2
st_flow st_flow
ddlb_flow ddlb_flow
cb_token cb_token
cb_refresh cb_refresh
cb_cancel cb_cancel
cb_forget cb_forget
mle_oauth2 mle_oauth2
end type

on tabpg_oauth2.create
this.st_oauth2=create st_oauth2
this.st_flow=create st_flow
this.ddlb_flow=create ddlb_flow
this.cb_token=create cb_token
this.cb_refresh=create cb_refresh
this.cb_cancel=create cb_cancel
this.cb_forget=create cb_forget
this.mle_oauth2=create mle_oauth2
this.Control[]={this.st_oauth2,&
this.st_flow,&
this.ddlb_flow,&
this.cb_token,&
this.cb_refresh,&
this.cb_cancel,&
this.cb_forget,&
this.mle_oauth2}
end on

on tabpg_oauth2.destroy
destroy(this.st_oauth2)
destroy(this.st_flow)
destroy(this.ddlb_flow)
destroy(this.cb_token)
destroy(this.cb_refresh)
destroy(this.cb_cancel)
destroy(this.cb_forget)
destroy(this.mle_oauth2)
end on

type st_oauth2 from statictext within tabpg_oauth2
integer x = 32
integer y = 24
integer width = 2350
integer height = 256
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "The OAuth 2.0 service, n_cst_oauth2, gets tokens for the application with the flows the logon window doesn't use, besides the authorization code flow: with the device code flow, the code is put on the clipboard and the sign-in page opens (the user can sign in on another device); with client credentials, the application signs in with its own secret, without a user.  Refresh uses the refresh token, so the user signs in only once."
boolean focusrectangle = false
end type

type st_flow from statictext within tabpg_oauth2
integer x = 32
integer y = 312
integer width = 200
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Flow:"
boolean focusrectangle = false
end type

type ddlb_flow from dropdownlistbox within tabpg_oauth2
integer x = 240
integer y = 300
integer width = 1100
integer height = 500
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean sorted = false
boolean vscrollbar = true
string item[] = {"Authorization code (web browser, PKCE)","Device code","Client credentials (no user)"}
borderstyle borderstyle = stylelowered!
end type

type cb_token from u_cb within tabpg_oauth2
integer x = 32
integer y = 420
integer width = 558
integer taborder = 20
string text = "&Get a Token"
end type

event clicked;call super::clicked;w_openiddemo.of_GetToken()
end event

type cb_refresh from u_cb within tabpg_oauth2
integer x = 620
integer y = 420
integer width = 558
integer taborder = 30
string text = "&Refresh the Token"
end type

event clicked;call super::clicked;w_openiddemo.of_RefreshToken()
end event

type cb_cancel from u_cb within tabpg_oauth2
integer x = 1208
integer y = 420
integer width = 558
integer taborder = 40
string text = "Ca&ncel"
boolean enabled = false
end type

event clicked;call super::clicked;w_openiddemo.of_CancelToken()
end event

type cb_forget from u_cb within tabpg_oauth2
integer x = 1796
integer y = 420
integer width = 558
integer taborder = 50
string text = "&Forget the Tokens"
end type

event clicked;call super::clicked;w_openiddemo.of_ForgetTokens()
end event

type mle_oauth2 from multilineedit within tabpg_oauth2
integer x = 32
integer y = 540
integer width = 2350
integer height = 944
integer taborder = 60
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean vscrollbar = true
boolean autovscroll = true
boolean displayonly = true
boolean hscrollbar = true
boolean autohscroll = true
borderstyle borderstyle = stylelowered!
end type

type tabpg_security from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1504
long backcolor = 67108864
string text = "Groups and Security"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_security st_security
st_groups st_groups
mle_groups mle_groups
st_map st_map
mle_map mle_map
cb_map cb_map
st_mapped st_mapped
lb_mapped lb_mapped
cb_secure cb_secure
st_status st_status
end type

on tabpg_security.create
this.st_security=create st_security
this.st_groups=create st_groups
this.mle_groups=create mle_groups
this.st_map=create st_map
this.mle_map=create mle_map
this.cb_map=create cb_map
this.st_mapped=create st_mapped
this.lb_mapped=create lb_mapped
this.cb_secure=create cb_secure
this.st_status=create st_status
this.Control[]={this.st_security,&
this.st_groups,&
this.mle_groups,&
this.st_map,&
this.mle_map,&
this.cb_map,&
this.st_mapped,&
this.lb_mapped,&
this.cb_secure,&
this.st_status}
end on

on tabpg_security.destroy
destroy(this.st_security)
destroy(this.st_groups)
destroy(this.mle_groups)
destroy(this.st_map)
destroy(this.mle_map)
destroy(this.cb_map)
destroy(this.st_mapped)
destroy(this.lb_mapped)
destroy(this.cb_secure)
destroy(this.st_status)
end on

type st_security from statictext within tabpg_security
integer x = 32
integer y = 24
integer width = 2350
integer height = 208
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "The groups of the sign-in, or groups typed here, are mapped to PFC security groups with [GroupMap] (n_cst_security.of_MapGroups); of_InitSecurity applies their settings.  First scan this demo with the security scanner, and set the groups' permissions in the security administrator (see the README)."
boolean focusrectangle = false
end type

type st_groups from statictext within tabpg_security
integer x = 32
integer y = 236
integer width = 1150
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Identity provider &groups, one per line:"
boolean focusrectangle = false
end type

type mle_groups from multilineedit within tabpg_security
integer x = 32
integer y = 300
integer width = 1150
integer height = 420
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean vscrollbar = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
end type

type st_map from statictext within tabpg_security
integer x = 1232
integer y = 236
integer width = 1150
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Group &map, provider group=PFC group:"
boolean focusrectangle = false
end type

type mle_map from multilineedit within tabpg_security
integer x = 1232
integer y = 300
integer width = 1150
integer height = 420
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean vscrollbar = true
boolean autovscroll = true
borderstyle borderstyle = stylelowered!
end type

type cb_map from u_cb within tabpg_security
integer x = 32
integer y = 760
integer width = 558
integer taborder = 30
string text = "&Map the Groups"
end type

event clicked;call super::clicked;w_openiddemo.of_MapGroups()
end event

type st_mapped from statictext within tabpg_security
integer x = 32
integer y = 880
integer width = 1150
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "PFC security groups:"
boolean focusrectangle = false
end type

type lb_mapped from listbox within tabpg_security
integer x = 32
integer y = 944
integer width = 1150
integer height = 540
integer taborder = 40
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean vscrollbar = true
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

type cb_secure from u_cb within tabpg_security
integer x = 1232
integer y = 944
integer width = 1150
integer taborder = 50
string text = "&Apply Security and Open the Secured Window"
end type

event clicked;call super::clicked;w_openiddemo.of_ApplySecurity()
end event

type st_status from statictext within tabpg_security
integer x = 1232
integer y = 1060
integer width = 1150
integer height = 424
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = ""
boolean focusrectangle = false
end type

type cb_close from u_cb within w_openiddemo
integer x = 2121
integer y = 1684
integer taborder = 20
string text = "Close"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
