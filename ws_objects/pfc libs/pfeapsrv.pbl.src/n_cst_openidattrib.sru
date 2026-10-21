$PBExportHeader$n_cst_openidattrib.sru
$PBExportComments$Extension OpenID Connect logon window attributes
forward
global type n_cst_openidattrib from pfc_n_cst_openidattrib
end type
end forward

global type n_cst_openidattrib from pfc_n_cst_openidattrib
end type

on n_cst_openidattrib.create
TriggerEvent( this, "constructor" )
end on

on n_cst_openidattrib.destroy
TriggerEvent( this, "destructor" )
end on
