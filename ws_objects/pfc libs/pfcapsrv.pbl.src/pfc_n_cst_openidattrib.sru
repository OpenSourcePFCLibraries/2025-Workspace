$PBExportHeader$pfc_n_cst_openidattrib.sru
$PBExportComments$PFC OpenID Connect logon window attributes
forward
global type pfc_n_cst_openidattrib from n_cst_baseattrib
end type
end forward

global type pfc_n_cst_openidattrib from n_cst_baseattrib autoinstantiate
end type

type variables
Public:
// Return code: 1 = logged on, 0 = cancelled, -1 = error
integer	ii_rc = -99
string	is_appname
// User ID (in: initial value for the logon window; out: the user ID that logged on)
string	is_userid

// Identity provider settings (n_cst_appmanager.of_OpenIDLogonDlg fills empty values from
// the [OpenID] section of the application INI file)
string	is_tokenendpoint
string	is_userinfoendpoint
string	is_clientid
string	is_scope = "openid profile"
// Client implementation: "OAuthClient" (default) or "HTTPClient"
string	is_client = "OAuthClient"
// Show the identity provider responses and the client choice (for demonstrations; off by default)
boolean	ib_showresponses = false

// Results
string	is_accesstoken
string	is_userinfo
string	is_groups[]
end variables

on pfc_n_cst_openidattrib.create
TriggerEvent( this, "constructor" )
end on

on pfc_n_cst_openidattrib.destroy
TriggerEvent( this, "destructor" )
end on
