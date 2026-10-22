$PBExportHeader$pfc_n_err.sru
$PBExportComments$PFC Error class
forward
global type pfc_n_err from error
end type
end forward

global type pfc_n_err from error
end type
global pfc_n_err pfc_n_err

type variables
Protected:
boolean		ib_IsObsolete
end variables

forward prototypes
protected function integer of_messagebox (string as_id, string as_title, string as_text, icon ae_icon, button ae_button, integer ai_default)
protected function integer of_messagebox (string as_id, string as_title, string as_text, string as_parms[], icon ae_icon, button ae_button, integer ai_default)
end prototypes

protected function integer of_messagebox (string as_id, string as_title, string as_text, icon ae_icon, button ae_button, integer ai_default);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  			of_MessageBox
//
//	Access:  			protected
//
//	Arguments:
//	as_id			An ID for the Message.
//	as_title  	Text for title bar
//	as_text		Text for the actual message.
//	ae_icon 		The icon you want to display on the MessageBox.
//	ae_button	Set of CommandButtons you want to display on the MessageBox.
//	ai_default  The default button.
//
//	Returns:  integer
//	Return value of the MessageBox.
//
//	Description:
//	Display a PowerScript MessageBox.  
//	Allow PFC MessageBoxes to be manipulated prior to their actual display.
//
//////////////////////////////////////////////////////////////////////////////
//
//	Revision History
//
//	Version
//	6.0   Initial version
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

// Language service: the message from the language file, if there is one
If IsValid(gnv_app) Then
	If IsValid(gnv_app.inv_language) Then gnv_app.inv_language.of_GetMessage(as_id, as_title, as_text)
End If

Return MessageBox(as_title, as_text, ae_icon, ae_button, ai_default)
end function

protected function integer of_messagebox (string as_id, string as_title, string as_text, string as_parms[], icon ae_icon, button ae_button, integer ai_default);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  			of_MessageBox
//
//	Access:  			protected
//
//	Arguments:
//	as_id			An ID for the Message.
//	as_title  	Text for title bar
//	as_text		Text for the actual message, in English, with placeholders (%s) for
//					the values in as_parms.
//	as_parms[]	Values for the placeholders.
//	ae_icon 		The icon you want to display on the MessageBox.
//	ae_button	Set of CommandButtons you want to display on the MessageBox.
//	ai_default  The default button.
//
//	Returns:  integer
//	Return value of the MessageBox.
//
//	Description:
//	Display a message that contains values.  With the language service, the message
//	comes from the language file (the entry as_id) when it has one; the values replace
//	the placeholders (see n_cst_string.of_Format).  The message is then displayed by
//	of_MessageBox(as_id, as_title, as_text, ae_icon, ae_button, ai_default).
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

n_cst_string	lnv_string

If IsValid(gnv_app) Then
	If IsValid(gnv_app.inv_language) Then
		gnv_app.inv_language.of_GetMessage(as_id, as_title, as_text, as_parms)
		Return of_MessageBox(as_id, as_title, as_text, ae_icon, ae_button, ai_default)
	End If
End If

Return of_MessageBox(as_id, as_title, lnv_string.of_Format(as_text, as_parms), ae_icon, ae_button, ai_default)
end function

on pfc_n_err.create
call super::create
TriggerEvent( this, "constructor" )
end on

on pfc_n_err.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

