$PBExportHeader$pfc_n_cst_language.sru
$PBExportComments$PFC Language service
forward
global type pfc_n_cst_language from n_base
end type
end forward

global type pfc_n_cst_language from n_base
end type
global pfc_n_cst_language pfc_n_cst_language

type prototypes
Function ulong GetModuleFileNameW(ulong hModule, ref string lpFilename, ulong nSize) Library "kernel32.dll"
end prototypes

type variables
Public:
// File name of the PFC language file in the "lang" folder of the application
Constant String DEFAULTFILE = "pfc.lng"
// Prefix of the keys of captions ("English text"="translation") in is_keys
Constant String CAPTION = "~t"

Protected:
// The language file in use ("" if none)
string	is_file
// Its entries, sorted by key (keys in lower case)
string	is_keys[]
string	is_values[]
long		il_count
end variables

forward prototypes
public function integer of_setlanguagefile (string as_file)
public function string of_getlanguagefile ()
public function string of_getdefaultlanguagefile ()
public function long of_getcount ()
public function string of_gettext (string as_key, string as_default)
public function string of_gettext (string as_key, string as_default, string as_parms[])
public function boolean of_getentry (string as_key, ref string as_text)
public function integer of_getmessage (string as_id, ref string as_title, ref string as_text)
public function integer of_getmessage (string as_id, ref string as_title, ref string as_text, string as_parms[])
protected function long of_find (string as_key)
protected function string of_unescape (string as_value)
protected function boolean of_hasplaceholders (string as_text)
protected function integer of_load (string as_file)
protected subroutine of_sort (long al_seq[])
protected function string of_getapplicationfolder ()
public function string of_translatetext (string as_text)
public function integer of_translate (window aw_window)
public function integer of_translate (menu am_menu)
public function integer of_translate (windowobject awo_control)
public function integer of_translate (datastore ads_data)
protected function integer of_translatedwobjects (powerobject apo_dw)
protected function string of_escape (string as_text)
end prototypes

public function integer of_setlanguagefile (string as_file);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetLanguageFile
//
//	Access:  public
//
//	Arguments:
//	as_file		the language file (with its path), or "" to use none
//
//	Returns:  Integer
//	 1 = the file was read
//	 0 = there is no such file (or as_file is ""): texts are left in English
//	-1 = the file could not be read
//
//	Description:  Reads a language file, replacing the entries read before.  By default
//		the service reads lang\pfc.lng in the application folder when it is created.
//		Use this function to choose another file, for example to switch languages.
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

string	ls_empty[]

is_keys = ls_empty
is_values = ls_empty
il_count = 0
is_file = ""

If IsNull(as_file) Or Len(Trim(as_file)) = 0 Then Return 0
If Not FileExists(as_file) Then Return 0

Return of_Load(as_file)
end function

public function string of_getlanguagefile ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetLanguageFile
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The language file in use, or "" if there is none
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

Return is_file
end function

public function string of_getdefaultlanguagefile ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetDefaultLanguageFile
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  lang\pfc.lng in the application folder: the folder of the
//		executable, or the current folder when the application runs in the IDE
//
//	Description:  The language file the service reads when it is created.  As with
//		PowerBuilder's own lang\default.lng, replace this file with one for another
//		language to translate the PFC.
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

Return of_GetApplicationFolder() + "lang\" + DEFAULTFILE
end function

public function long of_getcount ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetCount
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Long.  The number of entries in the language file in use
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

Return il_count
end function

public function string of_gettext (string as_key, string as_default);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetText
//
//	Access:  public
//
//	Arguments:
//	as_key		key of the entry in the language file
//	as_default	text to use when the file has no such entry (the English text)
//
//	Returns:  String.  The text from the language file, or as_default
//
//	Description:  For texts that application code builds, for example
//			st_status.Text = gnv_app.inv_language.of_GetText("app_status_ready", "Ready")
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

string	ls_text

ls_text = as_default
of_GetEntry(as_key, ls_text)
Return ls_text
end function

public function string of_gettext (string as_key, string as_default, string as_parms[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetText
//
//	Access:  public
//
//	Arguments:
//	as_key		key of the entry in the language file
//	as_default	text to use when the file has no such entry (the English text)
//	as_parms[]	values for the placeholders (%s, or %1 - %9) in the text
//
//	Returns:  String.  The text from the language file, or as_default, with the
//		placeholders replaced (see n_cst_string.of_Format)
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

Return lnv_string.of_Format(of_GetText(as_key, as_default), as_parms)
end function

public function boolean of_getentry (string as_key, ref string as_text);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetEntry
//
//	Access:  public
//
//	Arguments:
//	as_key		key of the entry in the language file
//	as_text		(by ref) set to the text from the language file, if it has the entry
//
//	Returns:  Boolean.  True if the language file has the entry
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

long	ll_index

ll_index = of_Find(as_key)
If ll_index = 0 Then Return False

as_text = is_values[ll_index]
Return True
end function

public function integer of_getmessage (string as_id, ref string as_title, ref string as_text);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetMessage
//
//	Access:  public
//
//	Arguments:
//	as_id			message ID, as passed to of_MessageBox
//	as_title		(by ref) the title; replaced by the entry <as_id>.title, if any
//	as_text		(by ref) the text; replaced by the entry <as_id>, if any
//
//	Returns:  Integer.  1 if the text was replaced, 0 if not
//
//	Description:  Called by of_MessageBox in the PFC objects.  An entry with
//		placeholders (%s) is not used here: the values are not known.  Messages with
//		values use of_GetMessage(as_id, as_title, as_text, as_parms[]).
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

string	ls_text
integer	li_rc

If IsNull(as_id) Or Len(as_id) = 0 Then Return 0

of_GetEntry(as_id + ".title", as_title)
If of_GetEntry(as_id, ls_text) Then
	If Not of_HasPlaceholders(ls_text) Then
		as_text = ls_text
		li_rc = 1
	End If
End If

Return li_rc
end function

public function integer of_getmessage (string as_id, ref string as_title, ref string as_text, string as_parms[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetMessage
//
//	Access:  public
//
//	Arguments:
//	as_id			message ID, as passed to of_MessageBox
//	as_title		(by ref) the title; replaced by the entry <as_id>.title, if any
//	as_text		(by ref) the English text with placeholders (%s); replaced by the entry
//					<as_id>, if any, and then the placeholders by the values
//	as_parms[]	values for the placeholders
//
//	Returns:  Integer.  1 if the text was replaced by the entry, 0 if not
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
integer	li_rc

If Not IsNull(as_id) And Len(as_id) > 0 Then
	of_GetEntry(as_id + ".title", as_title)
	If of_GetEntry(as_id, as_text) Then li_rc = 1
End If

as_text = lnv_string.of_Format(as_text, as_parms)
Return li_rc
end function

protected function long of_find (string as_key);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Find
//
//	Access:  protected
//
//	Arguments:
//	as_key		key: an ID (not case sensitive) or CAPTION + an English text (case
//					sensitive)
//
//	Returns:  Long.  The index of the entry in is_keys / is_values, or 0
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

long		ll_low, ll_high, ll_mid
string	ls_key

If il_count = 0 Or IsNull(as_key) Then Return 0

// IDs are not case sensitive; captions are
If Left(as_key, 1) = CAPTION Then
	ls_key = as_key
Else
	ls_key = Lower(as_key)
End If
ll_low = 1
ll_high = il_count
Do While ll_low <= ll_high
	ll_mid = Int((ll_low + ll_high) / 2)
	If is_keys[ll_mid] = ls_key Then Return ll_mid
	If is_keys[ll_mid] < ls_key Then
		ll_low = ll_mid + 1
	Else
		ll_high = ll_mid - 1
	End If
Loop

Return 0
end function

protected function string of_unescape (string as_value);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Unescape
//
//	Access:  protected
//
//	Arguments:
//	as_value		value as written in the language file
//
//	Returns:  String.  The value with the PowerScript escapes (~r ~n ~t ~" ~' ~~)
//		replaced by the characters
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

string	ls_result, ls_char
long		ll_pos, ll_start

ll_start = 1
ll_pos = Pos(as_value, "~~")
Do While ll_pos > 0 And ll_pos < Len(as_value)
	Choose Case Mid(as_value, ll_pos + 1, 1)
		Case "r"
			ls_char = "~r"
		Case "n"
			ls_char = "~n"
		Case "t"
			ls_char = "~t"
		Case "~"", "'", "~~"
			ls_char = Mid(as_value, ll_pos + 1, 1)
		Case Else
			// Not an escape: keep the tilde
			ls_char = "~~" + Mid(as_value, ll_pos + 1, 1)
	End Choose
	ls_result += Mid(as_value, ll_start, ll_pos - ll_start) + ls_char
	ll_start = ll_pos + 2
	ll_pos = Pos(as_value, "~~", ll_start)
Loop

Return ls_result + Mid(as_value, ll_start)
end function

protected function boolean of_hasplaceholders (string as_text);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_HasPlaceholders
//
//	Access:  protected
//
//	Arguments:
//	as_text		text
//
//	Returns:  Boolean.  True if the text has a placeholder (%s or %1 - %9)
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

long	ll_pos

ll_pos = Pos(as_text, "%")
Do While ll_pos > 0
	Choose Case Mid(as_text, ll_pos + 1, 1)
		Case "s", "1", "2", "3", "4", "5", "6", "7", "8", "9"
			Return True
		Case "%"
			ll_pos++
	End Choose
	ll_pos = Pos(as_text, "%", ll_pos + 1)
Loop

Return False
end function

protected function integer of_load (string as_file);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Load
//
//	Access:  protected
//
//	Arguments:
//	as_file		language file
//
//	Returns:  Integer.  1 if the file was read, -1 if it could not be opened
//
//	Description:  Reads a language file.  The format is the one of PowerBuilder's
//		lang\default.lng: one entry per line, KEY="text", and comment lines that start
//		with #.  Two kinds of entries:
//			pfc_logon_enterid="..."		a message or other text, by its ID
//			"&Cancel"="&Abbrechen"		a caption (of a window, control, menu item or
//											DataWindow text), by its English text
//		Texts can use the PowerScript escapes ~r ~n ~t ~" and ~~.  The file can be
//		UTF-16 (like default.lng), UTF-8 or ANSI; the encoding is read from its byte
//		order mark.  IDs are not case sensitive; captions are.  When a key appears more than once,
//		the last entry is used.
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

integer	li_file
long		ll_read, ll_pos, ll_seq[]
string	ls_line, ls_key, ls_value

li_file = FileOpen(as_file, LineMode!, Read!, Shared!, Append!, FileEncoding(as_file))
If li_file = -1 Then Return -1

ll_read = FileReadEx(li_file, ls_line)
Do While ll_read <> -100 And ll_read <> -1
	ls_line = Trim(ls_line)
	If Len(ls_line) > 0 And Left(ls_line, 1) <> "#" Then
		If Left(ls_line, 1) = '"' Then
			// A caption: "English text"="translation"
			ll_pos = 2
			Do While ll_pos <= Len(ls_line)
				If Mid(ls_line, ll_pos, 1) = "~~" Then
					ll_pos += 2
				ElseIf Mid(ls_line, ll_pos, 1) = '"' Then
					Exit
				Else
					ll_pos++
				End If
			Loop
			ls_key = CAPTION + of_Unescape(Mid(ls_line, 2, ll_pos - 2))
			ls_line = Trim(Mid(ls_line, ll_pos + 1))
			If Left(ls_line, 1) = "=" Then ll_pos = 1 Else ll_pos = 0
		Else
			// A message or another text, by its ID: key="text"
			ll_pos = Pos(ls_line, "=")
			If ll_pos > 1 Then
				ls_key = Lower(Trim(Left(ls_line, ll_pos - 1)))
			Else
				ll_pos = 0
			End If
		End If
		If ll_pos > 0 Then
			ls_value = Trim(Mid(ls_line, ll_pos + 1))
			If Len(ls_value) >= 2 And Left(ls_value, 1) = '"' And Right(ls_value, 1) = '"' Then
				ls_value = Mid(ls_value, 2, Len(ls_value) - 2)
			End If
			il_count++
			is_keys[il_count] = ls_key
			is_values[il_count] = of_Unescape(ls_value)
			ll_seq[il_count] = il_count
		End If
	End If
	ll_read = FileReadEx(li_file, ls_line)
Loop
FileClose(li_file)

of_Sort(ll_seq)
is_file = as_file
Return 1
end function

protected subroutine of_sort (long al_seq[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Sort
//
//	Access:  protected
//
//	Arguments:
//	al_seq[]		order in which the entries were read
//
//	Returns:  None
//
//	Description:  Sorts the entries by key (shell sort), and keeps only the last entry
//		read for a key, so that of_Find can do a binary search.
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

long		ll_gap, ll_idx, ll_pos, ll_seq, ll_count
string	ls_key, ls_value

// Shell sort on (key, order read)
ll_gap = 1
Do While ll_gap < il_count / 3
	ll_gap = ll_gap * 3 + 1
Loop
Do While ll_gap >= 1
	For ll_idx = ll_gap + 1 To il_count
		ls_key = is_keys[ll_idx]
		ls_value = is_values[ll_idx]
		ll_seq = al_seq[ll_idx]
		ll_pos = ll_idx
		Do While ll_pos > ll_gap
			If is_keys[ll_pos - ll_gap] < ls_key Then Exit
			If is_keys[ll_pos - ll_gap] = ls_key And al_seq[ll_pos - ll_gap] < ll_seq Then Exit
			is_keys[ll_pos] = is_keys[ll_pos - ll_gap]
			is_values[ll_pos] = is_values[ll_pos - ll_gap]
			al_seq[ll_pos] = al_seq[ll_pos - ll_gap]
			ll_pos -= ll_gap
		Loop
		is_keys[ll_pos] = ls_key
		is_values[ll_pos] = ls_value
		al_seq[ll_pos] = ll_seq
	Next
	ll_gap = Int(ll_gap / 3)
Loop

// Keep the last entry read for each key
For ll_idx = 1 To il_count
	If ll_count > 0 Then
		If is_keys[ll_count] = is_keys[ll_idx] Then
			is_values[ll_count] = is_values[ll_idx]
			Continue
		End If
	End If
	ll_count++
	is_keys[ll_count] = is_keys[ll_idx]
	is_values[ll_count] = is_values[ll_idx]
Next
il_count = ll_count
end subroutine

protected function string of_getapplicationfolder ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetApplicationFolder
//
//	Access:  protected
//
//	Arguments:  None
//
//	Returns:  String.  The folder of the executable, or the current folder when the
//		application runs in the IDE, with a trailing backslash
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

string	ls_folder
ulong		lul_len

// In the IDE, Handle(GetApplication()) is 0 and the executable is PowerBuilder itself
If Handle(GetApplication()) <> 0 Then
	ls_folder = Space(1024)
	lul_len = GetModuleFileNameW(0, ls_folder, 1024)
	If lul_len > 0 Then
		ls_folder = Left(ls_folder, lul_len)
		ls_folder = Left(ls_folder, LastPos(ls_folder, "\"))
	Else
		ls_folder = ""
	End If
End If

If ls_folder = "" Then ls_folder = GetCurrentDirectory()
If Right(ls_folder, 1) <> "\" Then ls_folder += "\"
Return ls_folder
end function

public function string of_translatetext (string as_text);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_TranslateText
//
//	Access:  public
//
//	Arguments:
//	as_text		a caption, in English
//
//	Returns:  String.  The translation of the caption ("English text"="translation" in
//		the language file), or as_text if the file has none
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

long	ll_index

If il_count = 0 Or IsNull(as_text) Or Len(as_text) = 0 Then Return as_text

ll_index = of_Find(CAPTION + as_text)
If ll_index = 0 Then Return as_text
Return is_values[ll_index]
end function

public function integer of_translate (window aw_window);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Translate
//
//	Access:  public
//
//	Arguments:
//	aw_window	window
//
//	Returns:  Integer.  The number of texts translated, or -1 if aw_window is not valid
//
//	Description:  Translates the captions of a window: its title, its controls (see
//		of_Translate(windowobject)) and its menu (see of_Translate(menu)).  w_master
//		calls it when a window opens.  Only captions with an entry in the language file
//		change, so captions the application set to other texts are kept.
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

integer	li_count, li_idx, li_rc
string	ls_text

If IsNull(aw_window) Or Not IsValid(aw_window) Then Return -1
If il_count = 0 Then Return 0

ls_text = of_TranslateText(aw_window.Title)
If ls_text <> aw_window.Title Then
	aw_window.Title = ls_text
	li_count++
End If

For li_idx = 1 To UpperBound(aw_window.Control)
	li_rc = of_Translate(aw_window.Control[li_idx])
	If li_rc > 0 Then li_count += li_rc
Next

If IsValid(aw_window.MenuID) Then
	li_rc = of_Translate(aw_window.MenuID)
	If li_rc > 0 Then li_count += li_rc
End If

Return li_count
end function

public function integer of_translate (menu am_menu);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Translate
//
//	Access:  public
//
//	Arguments:
//	am_menu		menu or menu item
//
//	Returns:  Integer.  The number of texts translated, or -1 if am_menu is not valid
//
//	Description:  Translates the Text, MicroHelp and ToolbarItemText of a menu item and
//		of all the items below it.  The PFC objects call it for their popup menus.
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

integer	li_count, li_idx, li_rc
string	ls_text

If IsNull(am_menu) Or Not IsValid(am_menu) Then Return -1
If il_count = 0 Then Return 0

ls_text = of_TranslateText(am_menu.Text)
If ls_text <> am_menu.Text Then
	am_menu.Text = ls_text
	li_count++
End If
ls_text = of_TranslateText(am_menu.MicroHelp)
If ls_text <> am_menu.MicroHelp Then
	am_menu.MicroHelp = ls_text
	li_count++
End If
ls_text = of_TranslateText(am_menu.ToolbarItemText)
If ls_text <> am_menu.ToolbarItemText Then
	am_menu.ToolbarItemText = ls_text
	li_count++
End If

For li_idx = 1 To UpperBound(am_menu.Item)
	li_rc = of_Translate(am_menu.Item[li_idx])
	If li_rc > 0 Then li_count += li_rc
Next

Return li_count
end function

public function integer of_translate (windowobject awo_control);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Translate
//
//	Access:  public
//
//	Arguments:
//	awo_control		control
//
//	Returns:  Integer.  The number of texts translated, or -1 if awo_control is not valid
//
//	Description:  Translates the captions of a control: the Text of buttons, check boxes,
//		radio buttons, static texts, group boxes and hyperlinks; the Text and PowerTipText
//		of tab pages, with their controls; the controls of user objects; and the text
//		objects and code table display values of a DataWindow's DataWindow object.
//		Text the user enters (SingleLineEdit, MultiLineEdit, EditMask) is not translated,
//		nor are the items of list boxes and drop-down list boxes: code often uses them
//		as values (for example the search direction of w_find).
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

integer	li_count, li_idx, li_rc
string	ls_text
commandbutton		lcb
checkbox				lcbx
radiobutton			lrb
statictext			lst
groupbox				lgb
picturebutton		lpb
statichyperlink	lsth
tab					ltab
userobject			luo
datawindow			ldw

If IsNull(awo_control) Or Not IsValid(awo_control) Then Return -1
If il_count = 0 Then Return 0

Choose Case TypeOf(awo_control)
	Case commandbutton!
		lcb = awo_control
		ls_text = of_TranslateText(lcb.Text)
		If ls_text <> lcb.Text Then
			lcb.Text = ls_text
			li_count++
		End If
	Case checkbox!
		lcbx = awo_control
		ls_text = of_TranslateText(lcbx.Text)
		If ls_text <> lcbx.Text Then
			lcbx.Text = ls_text
			li_count++
		End If
	Case radiobutton!
		lrb = awo_control
		ls_text = of_TranslateText(lrb.Text)
		If ls_text <> lrb.Text Then
			lrb.Text = ls_text
			li_count++
		End If
	Case statictext!
		lst = awo_control
		ls_text = of_TranslateText(lst.Text)
		If ls_text <> lst.Text Then
			lst.Text = ls_text
			li_count++
		End If
	Case groupbox!
		lgb = awo_control
		ls_text = of_TranslateText(lgb.Text)
		If ls_text <> lgb.Text Then
			lgb.Text = ls_text
			li_count++
		End If
	Case picturebutton!
		lpb = awo_control
		ls_text = of_TranslateText(lpb.Text)
		If ls_text <> lpb.Text Then
			lpb.Text = ls_text
			li_count++
		End If
	Case statichyperlink!
		lsth = awo_control
		ls_text = of_TranslateText(lsth.Text)
		If ls_text <> lsth.Text Then
			lsth.Text = ls_text
			li_count++
		End If
	Case tab!
		ltab = awo_control
		For li_idx = 1 To UpperBound(ltab.Control)
			li_rc = of_Translate(ltab.Control[li_idx])
			If li_rc > 0 Then li_count += li_rc
		Next
	Case userobject!
		// A tab page or a custom visual user object
		luo = awo_control
		ls_text = of_TranslateText(luo.Text)
		If ls_text <> luo.Text Then
			luo.Text = ls_text
			li_count++
		End If
		ls_text = of_TranslateText(luo.PowerTipText)
		If ls_text <> luo.PowerTipText Then
			luo.PowerTipText = ls_text
			li_count++
		End If
		For li_idx = 1 To UpperBound(luo.Control)
			li_rc = of_Translate(luo.Control[li_idx])
			If li_rc > 0 Then li_count += li_rc
		Next
	Case datawindow!
		ldw = awo_control
		li_rc = of_TranslateDWObjects(ldw)
		If li_rc > 0 Then li_count += li_rc
End Choose

Return li_count
end function

public function integer of_translate (datastore ads_data);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Translate
//
//	Access:  public
//
//	Arguments:
//	ads_data		DataStore, for example one used to print a report
//
//	Returns:  Integer.  The number of texts translated, or -1 if ads_data is not valid
//
//	Description:  Translates the text objects and code table display values of the
//		DataStore's DataWindow object.  Call it again after changing the DataObject.
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

If IsNull(ads_data) Or Not IsValid(ads_data) Then Return -1
Return of_TranslateDWObjects(ads_data)
end function

protected function integer of_translatedwobjects (powerobject apo_dw);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_TranslateDWObjects
//
//	Access:  protected
//
//	Arguments:
//	apo_dw		DataWindow control or DataStore
//
//	Returns:  Integer.  The number of texts translated
//
//	Description:  Translates the text objects (except those whose text is an expression)
//		and the display values of the code tables of the columns.
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

string	ls_objects, ls_object, ls_text, ls_new, ls_values, ls_item, ls_display, ls_newvalues
long		ll_pos, ll_tab
integer	li_count
boolean	lb_changed

If il_count = 0 Then Return 0

ls_objects = String(apo_dw.Dynamic Describe("DataWindow.Objects"))
If ls_objects = "" Or ls_objects = "!" Or ls_objects = "?" Then Return 0
ls_objects += "~t"

Do While Len(ls_objects) > 0
	ll_pos = Pos(ls_objects, "~t")
	ls_object = Left(ls_objects, ll_pos - 1)
	ls_objects = Mid(ls_objects, ll_pos + 1)
	If ls_object = "" Then Continue

	Choose Case String(apo_dw.Dynamic Describe(ls_object + ".Type"))
		Case "text"
			ls_text = String(apo_dw.Dynamic Describe(ls_object + ".Text"))
			// A text with an expression is described as "default~texpression"
			If Left(ls_text, 1) = '"' Then Continue
			ls_new = of_TranslateText(ls_text)
			If ls_new <> ls_text Then
				apo_dw.Dynamic Modify(ls_object + ".Text=~"" + of_Escape(ls_new) + "~"")
				li_count++
			End If
		Case "column"
			// Code table: display~tdata/display~tdata/...
			ls_values = String(apo_dw.Dynamic Describe(ls_object + ".Values"))
			If ls_values = "" Or ls_values = "?" Or ls_values = "!" Then Continue
			ls_newvalues = ""
			lb_changed = False
			Do While Len(ls_values) > 0
				ll_pos = Pos(ls_values, "/")
				If ll_pos = 0 Then ll_pos = Len(ls_values) + 1
				ls_item = Left(ls_values, ll_pos - 1)
				ls_values = Mid(ls_values, ll_pos + 1)
				ll_tab = Pos(ls_item, "~t")
				If ll_tab > 0 Then
					ls_display = Left(ls_item, ll_tab - 1)
					ls_new = of_TranslateText(ls_display)
					If ls_new <> ls_display Then
						ls_item = ls_new + Mid(ls_item, ll_tab)
						lb_changed = True
					End If
				End If
				ls_newvalues += ls_item + "/"
			Loop
			If lb_changed Then
				apo_dw.Dynamic Modify(ls_object + ".Values=~"" + of_Escape(ls_newvalues) + "~"")
				li_count++
			End If
	End Choose
Loop

Return li_count
end function

protected function string of_escape (string as_text);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Escape
//
//	Access:  protected
//
//	Arguments:
//	as_text		text
//
//	Returns:  String.  The text with ~ " tabs and line breaks escaped, to put between
//		double quotes in a DataWindow Modify expression
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

string	ls_result, ls_char
long		ll_idx

For ll_idx = 1 To Len(as_text)
	ls_char = Mid(as_text, ll_idx, 1)
	Choose Case ls_char
		Case "~~"
			ls_result += "~~~~"
		Case "~""
			ls_result += "~~~""
		Case "~t"
			ls_result += "~~t"
		Case "~r"
			ls_result += "~~r"
		Case "~n"
			ls_result += "~~n"
		Case Else
			ls_result += ls_char
	End Choose
Next

Return ls_result
end function

on pfc_n_cst_language.create
call super::create
end on

on pfc_n_cst_language.destroy
call super::destroy
end on

event constructor;call super::constructor;//////////////////////////////////////////////////////////////////////////////
//
//	Event:  constructor
//
//	Description:  Reads the default language file, lang\pfc.lng in the application
//		folder, if there is one.
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

of_SetLanguageFile(of_GetDefaultLanguageFile())
end event
