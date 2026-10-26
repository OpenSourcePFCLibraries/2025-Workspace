$PBExportHeader$pfcsecurity_scanner.sra
$PBExportComments$PFC Security Scanner Application
forward
global type pfcsecurity_scanner from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables
transaction inv_trans
constant string gs_displayname = 'PFC Security Scanner Utility'
end variables

global type pfcsecurity_scanner from application
string appname = "pfcsecurity_scanner"
integer highdpimode = 0
string themepath = "C:\Program Files (x86)\Appeon\PowerBuilder 25.0\IDE\theme"
string themename = "Do Not Use Themes"
boolean nativepdfvalid = false
boolean nativepdfincludecustomfont = false
string nativepdfappname = ""
long richtextedittype = 5
long richtexteditx64type = 5
long richtexteditversion = 3
string richtexteditkey = ""
string appicon = ""
string appruntimeversion = "25.1.0.6430"
boolean manualsession = false
boolean unsupportedapierror = false
boolean ultrafast = false
boolean bignoreservercertificate = false
uint ignoreservercertificate = 0
long webview2distribution = 0
boolean webview2checkx86 = false
boolean webview2checkx64 = false
string webview2url = "https://developer.microsoft.com/en-us/microsoft-edge/webview2/"
end type
global pfcsecurity_scanner pfcsecurity_scanner

on pfcsecurity_scanner.create
appname="pfcsecurity_scanner"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on pfcsecurity_scanner.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;string	ls_ini_file, ls_args, ls_values[], ls_path, ls_file
long		ll_pos
ContextKeyword	lcx_key

// The security administrator's INI file, with the security database's
// connection: given on the command line (/ini <file>), or in the
// PFC_SECURITY_INI environment variable, or pfcsecad.ini in the current
// folder; otherwise the user chooses it.
ls_args = Trim(CommandParm())
ll_pos = Pos(Lower(ls_args), "/ini ")
If ll_pos > 0 Then
	ls_ini_file = Trim(Mid(ls_args, ll_pos + 5))
	If Left(ls_ini_file, 1) = '"' Then
		ls_ini_file = Mid(ls_ini_file, 2)
		If Pos(ls_ini_file, '"') > 0 Then ls_ini_file = Left(ls_ini_file, Pos(ls_ini_file, '"') - 1)
	ElseIf Pos(ls_ini_file, " /") > 0 Then
		ls_ini_file = Left(ls_ini_file, Pos(ls_ini_file, " /") - 1)
	End If
End If
If ls_ini_file = "" Then
	If GetContextService("Keyword", lcx_key) = 1 Then
		lcx_key.GetContextKeywords("PFC_SECURITY_INI", ls_values)
		If UpperBound(ls_values) > 0 Then ls_ini_file = Trim(ls_values[1])
	End If
End If
If ls_ini_file = "" And FileExists("pfcsecad.ini") Then ls_ini_file = GetCurrentDirectory() + "\pfcsecad.ini"

inv_trans = create transaction
Do While True
	If ls_ini_file <> "" And Not FileExists(ls_ini_file) Then
		MessageBox(gs_displayname, "The INI file " + ls_ini_file + " doesn't exist.", Exclamation!)
		ls_ini_file = ""
	End If
	If ls_ini_file = "" Then
		ls_path = ""
		If GetFileOpenName("Select the Security Administrator's INI File", ls_path, ls_file, "ini", "INI Files (*.ini),*.ini") <> 1 Then
			Halt
			Return
		End If
		ls_ini_file = ls_path
	End If

	// This script will read all the database values from the ini file
	//   and store them in inv_trans.
	inv_trans.DBMS = ProfileString(ls_ini_file,"Database","DBMS", "")
	If Trim(inv_trans.DBMS) = "" Then
		MessageBox(gs_displayname, ls_ini_file + " has no DBMS in its [Database] section.", Exclamation!)
		ls_ini_file = ""
		Continue
	End If
	inv_trans.Database		= ProfileString(ls_ini_file,"Database","DataBase",         " ")
	inv_trans.LogID			= ProfileString(ls_ini_file,"Database","LogID",            " ")
	inv_trans.LogPass			= ProfileString(ls_ini_file,"Database","LogPassword",      " ")
	inv_trans.ServerName		= ProfileString(ls_ini_file,"Database","ServerName",       " ")
	inv_trans.UserID			= ProfileString(ls_ini_file,"Database","UserID",           " ")
	inv_trans.DBPass			= ProfileString(ls_ini_file,"Database","DatabasePassword", " ")
	inv_trans.Lock				= ProfileString(ls_ini_file,"Database","Lock",             " ")
	inv_trans.DbParm			= ProfileString(ls_ini_file,"Database","DbParm",           " ")

	connect using inv_trans;
	If inv_trans.SQLCode = 0 Then Exit

	If MessageBox(gs_displayname, "Unable to connect to the security database with " + ls_ini_file + ":" + &
			"~r~n~r~n" + inv_trans.SQLErrText + "~r~n~r~nChoose another INI file?", StopSign!, YesNo!) = 2 Then
		Halt
		Return
	End If
	ls_ini_file = ""
Loop

open(w_pfcsecurity_targetselection)
end event

event systemerror;string 	ls_message

ls_message = 'Error Number '+string(error.number) & 
	+'.~r~nError text = '+Error.text &
	+'.~r~nWindow/Menu/Object = '+error.windowmenu &
	+'.~r~nError Object/Control = '+Error.object &
	+'.~r~nScript = '+Error.objectevent &
	+'.~r~nLine in Script = '+string(Error.line) + '.'
	
messagebox('System Error',ls_message, StopSign!, Ok!)

halt close
end event

event close;If IsValid(inv_trans) Then
	disconnect using inv_trans;
	destroy inv_trans
End If
end event

