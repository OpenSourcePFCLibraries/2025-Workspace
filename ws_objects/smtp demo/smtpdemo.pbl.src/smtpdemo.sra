$PBExportHeader$smtpdemo.sra
$PBExportComments$PFC SMTP client demo: sends mail with n_smtpclient and an OAuth 2.0 token
forward
global n_tr sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global n_msg message
end forward

global variables
/*  Application Manager  */
n_cst_appmanager gnv_app 
end variables

global type smtpdemo from application
 string appruntimeversion = "25.1.0.6430"
integer highdpimode = 0
end type
global smtpdemo smtpdemo

on smtpdemo.create
appname = "smtpdemo"
message = create n_msg
sqlca = create n_tr
sqlda = create dynamicdescriptionarea
sqlsa = create dynamicstagingarea
error = create error
end on

on smtpdemo.destroy
destroy( sqlca )
destroy( sqlda )
destroy( sqlsa )
destroy( error )
destroy( message )
end on

event open;gnv_app = create n_cst_appmanager

gnv_app.TriggerEvent ( "pfc_open" )
Open(w_smtpdemo)
end event

event close;gnv_app.TriggerEvent ( "pfc_close" )

If IsValid ( gnv_app ) Then Destroy gnv_app
end event

event systemerror;gnv_app.Event pfc_systemerror ( )
end event

event idle;gnv_app.Event pfc_idle (  )
end event
