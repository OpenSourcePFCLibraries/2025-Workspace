$PBExportHeader$w_sheetframe.srw
$PBExportComments$Example of the sheet manager (n_cst_winsrv_sheetmanager): an MDI frame with its own sheets
forward
global type w_sheetframe from w_frame
end type
end forward

global type w_sheetframe from w_frame
integer x = 400
integer y = 200
integer width = 3000
integer height = 2000
string title = "PFC Example - Sheet Manager"
string menuname = "m_sheetframe"
end type
global w_sheetframe w_sheetframe

type variables
Protected:
// Numbers the sheets
integer	ii_sheets
end variables

event pfc_preopen;call super::pfc_preopen;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			pfc_preopen
//
//	Description:	Starts the sheet manager, which the Window menu's Cascade, Tile,
//						Layer, Minimize All and Undo Arrange items use, and which lists and
//						finds the sheets.  Like every Examples window, the frame also keeps
//						its size, position and toolbar settings (the window preference
//						service, started by the Examples w_master).
//
//////////////////////////////////////////////////////////////////////////////
of_SetSheetManager(True)
end event

event pfc_postopen;call super::pfc_postopen;// Three sheets to begin with; File > New opens more
integer	li_i

For li_i = 1 To 3
	this.event pfc_new()
Next
this.event pfc_cascade()
end event

event pfc_new;call super::pfc_new;// File > New: another sheet
w_sheetdemo	lw_sheet

ii_sheets++
OpenSheetWithParm(lw_sheet, "Sheet " + String(ii_sheets), this, 0, Original!)
end event

on w_sheetframe.create
call super::create
if this.MenuName = "m_sheetframe" then this.MenuID = create m_sheetframe
end on

on w_sheetframe.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
end on
