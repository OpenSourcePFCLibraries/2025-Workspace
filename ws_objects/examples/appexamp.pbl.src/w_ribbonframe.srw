$PBExportHeader$w_ribbonframe.srw
$PBExportComments$Example of the ribbon bar control (u_rbb) on a frame, which lays out its client area under the ribbon bar
forward
global type w_ribbonframe from w_frame
end type
type rbb_1 from u_rbb within w_ribbonframe
end type
end forward

global type w_ribbonframe from w_frame
integer x = 400
integer y = 200
integer width = 3000
integer height = 2000
string title = "PFC Example - Ribbon Bar"
string menuname = "m_sheetframe"
boolean toolbarvisible = false
rbb_1 rbb_1
end type
global w_ribbonframe w_ribbonframe

type variables
Protected:
// Numbers the sheets
integer	ii_sheets
end variables

forward prototypes
protected subroutine of_buildribbon ()
end prototypes

protected subroutine of_buildribbon ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_BuildRibbon
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Description:	Fills the ribbon bar: categories (the tabs), panels and items.
//						Each item names the user event of rbb_1 that its click triggers.
//						A ribbon bar can also be loaded from XML or JSON
//						(ImportFromXMLString, ImportFromJSON).
//
//////////////////////////////////////////////////////////////////////////////
long	ll_category, ll_panel

ll_category = rbb_1.InsertCategoryLast("Home")
ll_panel = rbb_1.InsertPanelLast(ll_category, "Sheets", "AddSmall!")
rbb_1.InsertLargeButtonLast(ll_panel, "New Sheet", "AddBig!", "ue_new")
rbb_1.InsertLargeButtonLast(ll_panel, "Close Sheet", "DeleteBig!", "ue_closesheet")
ll_panel = rbb_1.InsertPanelLast(ll_category, "Arrange", "TabsSmall!")
rbb_1.InsertSmallButtonLast(ll_panel, "Cascade", "", "ue_arrange")
rbb_1.InsertSmallButtonLast(ll_panel, "Tile", "", "ue_arrange")
rbb_1.InsertSmallButtonLast(ll_panel, "Layer", "", "ue_arrange")

ll_category = rbb_1.InsertCategoryLast("View")
ll_panel = rbb_1.InsertPanelLast(ll_category, "Ribbon Bar", "PageSizeSmall!")
rbb_1.InsertCheckBoxLast(ll_panel, "Hide the Panel Text", "ue_hidepaneltext")
rbb_1.InsertCheckBoxLast(ll_panel, "Hide the Tab Header", "ue_hidetabheader")
end subroutine

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	Builds the ribbon bar and lays out the frame's client area under
//						it.  AutoSizeHeight fits the ribbon bar's height to its content when
//						the content changes; the design height is the height of this content.
//
//////////////////////////////////////////////////////////////////////////////
of_SetSheetManager(True)
of_BuildRibbon()
of_LayoutClient()
end event

event pfc_postopen;call super::pfc_postopen;// Two sheets to begin with
this.event pfc_new()
this.event pfc_new()
this.event pfc_cascade()
end event

event pfc_new;call super::pfc_new;// File > New, and the ribbon's New Sheet: another sheet
w_ribbonsheet	lw_sheet

ii_sheets++
OpenSheetWithParm(lw_sheet, "Sheet " + String(ii_sheets), this, 0, Original!)
end event

on w_ribbonframe.create
int iCurrent
call super::create
if this.MenuName = "m_sheetframe" then this.MenuID = create m_sheetframe
this.rbb_1=create rbb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.rbb_1
end on

on w_ribbonframe.destroy
call super::destroy
if IsValid(MenuID) then destroy(MenuID)
destroy(this.rbb_1)
end on

type rbb_1 from u_rbb within w_ribbonframe
event type long ue_new ( long itemhandle )
event type long ue_closesheet ( long itemhandle )
event type long ue_arrange ( long itemhandle )
event type long ue_hidepaneltext ( long itemhandle )
event type long ue_hidetabheader ( long itemhandle )
integer width = 2926
integer height = 460
boolean autosizeheight = true
end type

event ue_new;parent.event pfc_new()
Return 1
end event

event ue_closesheet;window	lw_sheet

lw_sheet = parent.GetActiveSheet()
If IsValid(lw_sheet) Then Close(lw_sheet)
Return 1
end event

event ue_arrange;// The three Arrange buttons share this event; the item's text tells them apart
RibbonSmallButtonItem	lr_button

this.GetSmallButton(itemhandle, lr_button)
Choose Case lr_button.Text
	Case "Cascade"
		parent.event pfc_cascade()
	Case "Tile"
		parent.event pfc_tilevertical()
	Case "Layer"
		parent.event pfc_layer()
End Choose
Return 1
end event

event ue_hidepaneltext;// of_SetHidePanelText changes the ribbon bar's height, and lays out the frame again
// (setting HidePanelText directly would leave the client area where it was)
this.of_SetHidePanelText(Not this.HidePanelText)
Return 1
end event

event ue_hidetabheader;// Without the tab header, only the selected category's panels show
this.of_SetHideTabHeader(Not this.HideTabHeader)
Return 1
end event
