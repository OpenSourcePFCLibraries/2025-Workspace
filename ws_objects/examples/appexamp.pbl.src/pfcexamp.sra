$PBExportHeader$pfcexamp.sra
forward
global type pfcexamp from application
end type
global n_tr sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global n_msg message
end forward

global variables
n_ExampleAppManager gnv_app 
end variables

global type pfcexamp from application
string appname = "pfcexamp"
integer highdpimode = 0
string themepath = "."
string themename = "Flat Design Grey - Modified"
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
global pfcexamp pfcexamp

on pfcexamp.create
appname="pfcexamp"
message=create n_msg
sqlca=create n_tr
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on pfcexamp.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;//////////////////////////////////////////////////////////////////////////////
//	Event:			open
//	Arguments:		None
//	Returns:			None
//	Description:		Creates the Application Manager, n_exampleappmanager, as gnv_app,
// 						then triggers its pfc_open event.
//////////////////////////////////////////////////////////////////////////////
gnv_app = create n_exampleappmanager

gnv_app.TriggerEvent ( "pfc_open" )
end event

event close;//////////////////////////////////////////////////////////////////////////////
//	Event:			close
//	Arguments:		None
//	Returns:			None
//	Description:		Triggers the pfc_close event on gnv_app, then destroys the Application Manager.
//////////////////////////////////////////////////////////////////////////////
gnv_app.TriggerEvent ( "pfc_close" )
If IsValid ( gnv_app ) Then Destroy gnv_app
end event

event systemerror;//////////////////////////////////////////////////////////////////////////////
//	Event:			systemerror
//	Arguments:		None
//	Returns:			None
//	Description:		Triggers the pfc_systemerror event on the Application Manager (gnv_app).
//////////////////////////////////////////////////////////////////////////////
gnv_app.event pfc_systemerror ( )
end event

