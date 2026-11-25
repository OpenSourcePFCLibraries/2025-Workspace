$PBExportHeader$pfcscanner_n_cst_filesrv.sru
$PBExportComments$PFC File handler service
forward
global type pfcscanner_n_cst_filesrv from nonvisualobject
end type
end forward

global type pfcscanner_n_cst_filesrv from nonvisualobject
end type
global pfcscanner_n_cst_filesrv pfcscanner_n_cst_filesrv

type variables
string	is_Separator
string	is_AllFiles
string is_FileType
end variables

forward prototypes
end prototypes

on pfcscanner_n_cst_filesrv.create
call super::create
TriggerEvent( this, "constructor" )
end on

on pfcscanner_n_cst_filesrv.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

