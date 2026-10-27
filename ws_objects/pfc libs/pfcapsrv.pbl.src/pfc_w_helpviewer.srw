$PBExportHeader$pfc_w_helpviewer.srw
$PBExportComments$PFC Help window
forward
global type pfc_w_helpviewer from w_popup
end type
type wb_help from u_wb within pfc_w_helpviewer
end type
end forward

global type pfc_w_helpviewer from w_popup
integer width = 3200
integer height = 2640
string title = "Help"
boolean center = true
wb_help wb_help
end type
global pfc_w_helpviewer pfc_w_helpviewer

type variables
Protected:
// The page shown
string	is_url
end variables

forward prototypes
public function integer of_show (string as_url)
end prototypes

public function integer of_show (string as_url);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Show
//
//	Access:  public
//
//	Arguments:
//	as_url		The URL to show: a PDF help file, with #nameddest=<destination> to show
//				a place in it (see n_cst_help.of_GetURL)
//
//	Returns:  Integer
//	 1 = success
//	-1 = error
//
//	Description:  Shows a help file.  The help service (n_cst_help) opens this window and
//		calls this function; the file is shown by the browser control (Microsoft Edge
//		WebView2), whose PDF viewer opens it at the destination.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

If IsNull(as_url) Or as_url = "" Then Return -1
is_url = as_url
If wb_help.Navigate(is_url) <> 1 Then Return -1
Return 1
end function

event resize;call super::resize;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  resize
//
//	Description:  The browser control fills the window.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	2025	Initial version
//
//////////////////////////////////////////////////////////////////////////////
//
/*
 * Open Source PowerBuilder Foundation Class Libraries
 *
 * Copyright (c) 2004-2017, All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted in accordance with the MIT License

 *
 * https://opensource.org/licenses/MIT
 *
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals and was originally based on software copyright (c)
 * 1996-2004 Sybase, Inc. http://www.sybase.com.  For more
 * information on the Open Source PowerBuilder Foundation Class
 * Libraries see https://github.com/OpenSourcePFCLibraries
*/
//
//////////////////////////////////////////////////////////////////////////////

wb_help.Move(0, 0)
wb_help.Resize(newwidth, newheight)
end event

on pfc_w_helpviewer.create
int iCurrent
call super::create
this.wb_help=create wb_help
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.wb_help
end on

on pfc_w_helpviewer.destroy
call super::destroy
destroy(this.wb_help)
end on

type wb_help from u_wb within pfc_w_helpviewer
integer width = 3163
integer height = 2540
integer taborder = 10
end type
