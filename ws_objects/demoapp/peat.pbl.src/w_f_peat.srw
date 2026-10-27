$PBExportHeader$w_f_peat.srw
$PBExportComments$PEAT Frame window
forward
global type w_f_peat from w_frame
end type
end forward

global type w_f_peat from w_frame
integer x = 5
integer y = 4
integer width = 2935
integer height = 1928
string title = "Project Estimation and Actual Tracking System"
string menuname = "m_peat_frame"
windowstate windowstate = maximized!
string icon = "images\peat.ico"
boolean toolbarvisible = false
end type
global w_f_peat w_f_peat

forward prototypes
public function integer of_setribbon (boolean ab_ribbon)
public subroutine of_setribbonfont ()
end prototypes

public function integer of_setribbon (boolean ab_ribbon);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_SetRibbon
//
//	Access:			Public
//
//	Arguments:		ab_ribbon	True shows the menu as a ribbon, False as the menu bar
//									and toolbar
//
//	Returns:			Integer
//						1 if it changed, 0 if it was already so
//
//	Description:	Switches the ribbon on or off while the window is open.
//
//////////////////////////////////////////////////////////////////////////////

If this.DisplayMenuAsRibbonBar = ab_ribbon Then Return 0
this.DisplayMenuAsRibbonBar = ab_ribbon
If ab_ribbon Then of_SetRibbonFont()
Return 1
end function

public subroutine of_setribbonfont ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_SetRibbonFont
//
//	Access:			Public
//
//	Description:	The ribbon gets the font of the windows, Segoe UI at 8 points: its
//						own is much larger.  The ribbon is made again when a sheet with its
//						own menu is activated, so the sheet calls this too.
//
//////////////////////////////////////////////////////////////////////////////

mdirbb_1.FaceName = "Segoe UI"
mdirbb_1.TextSize = -8
end subroutine

event open;call super::open;this.Event pfc_open()
end event

event pfc_preopen;call super::pfc_preopen;// The menu as a ribbon (RibbonView), unless RibbonBar=0 in the [Application] section of the
// INI file.  The sheets' menus are shown in it too.
this.DisplayMenuAsRibbonBar = (ProfileString(gnv_app.of_GetAppIniFile(), "Application", "RibbonBar", "1") <> "0")
If this.DisplayMenuAsRibbonBar Then of_SetRibbonFont()
end event

on w_f_peat.create
call super::create
if IsValid(this.MenuID) then destroy(this.MenuID)
if this.MenuName = "m_peat_frame" then this.MenuID = create m_peat_frame
end on

on w_f_peat.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
end on

event pfc_new;call super::pfc_new;w_s_projectlist	w_active
string				ls_name

SetPointer(HourGlass!)
OpenWithParm(w_r_projectwizard, 0)
ls_name = message.stringparm
IF ls_name <> "" THEN
	w_active = this.GetActiveSheet()
	IF IsValid(w_active) THEN
		w_active.of_addnewproject(ls_name)
	END IF
END IF


end event

event pfc_postopen;call super::pfc_postopen;// With PFC security on (peat_security.ini), n_cst_peat opens the project list after the logon
If Not IsValid(gnv_app.inv_security) Then OpenSheet(w_s_projectlist, this, 0, layered!)
end event

