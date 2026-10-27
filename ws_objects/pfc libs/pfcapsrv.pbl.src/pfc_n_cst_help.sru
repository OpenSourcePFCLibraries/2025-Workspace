$PBExportHeader$pfc_n_cst_help.sru
$PBExportComments$PFC Help service
forward
global type pfc_n_cst_help from n_base
end type
end forward

global type pfc_n_cst_help from n_base
end type
global pfc_n_cst_help pfc_n_cst_help

type prototypes
Function longptr FindExecutableW(string lpFile, string lpDirectory, ref string lpResult) Library "shell32.dll"
Function longptr ShellExecuteW(longptr hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, long nShowCmd) Library "shell32.dll"
Function ulong GetModuleFileNameW(ulong hModule, ref string lpFilename, ulong nSize) Library "kernel32.dll"
end prototypes

type variables
Public:
// Where a PDF help file is shown (of_SetViewer)
Constant Integer INAPP = 1
Constant Integer PDFVIEWER = 2
// The help file of the PFC dialog boxes
Constant String DEFAULTDIALOGHELPFILE = "pfcdlg.pdf"

Protected:
integer	ii_viewer = INAPP
string	is_dialoghelpfile = DEFAULTDIALOGHELPFILE
end variables

forward prototypes
public function integer of_setviewer (integer ai_viewer)
public function integer of_getviewer ()
public function integer of_setdialoghelpfile (string as_file)
public function string of_getdialoghelpfile ()
public function integer of_showhelp (string as_file)
public function integer of_showhelp (string as_file, string as_destination)
public function integer of_showhelp (string as_file, long al_topic)
public function integer of_showdialoghelp (string as_destination)
public function string of_getdestination (long al_topic)
public function string of_geturl (string as_path, string as_destination)
public function string of_getviewercommand (string as_viewer, string as_path, string as_destination)
public function boolean of_iscompiledhelp (string as_file)
protected function string of_getpath (string as_file)
protected function string of_getapplicationfolder ()
protected function string of_cleandestination (string as_destination)
protected function integer of_showinapp (string as_url)
protected function integer of_showinviewer (string as_path, string as_destination)
end prototypes

public function integer of_setviewer (integer ai_viewer);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetViewer
//
//	Access:  public
//
//	Arguments:
//	ai_viewer	Where PDF help files are shown:
//				INAPP, in a window of the application (w_helpviewer), the default, or
//				PDFVIEWER, in the PDF viewer of the user (the program that opens .pdf files)
//
//	Returns:  Integer
//	 1 = success
//	-1 = error (an invalid argument)
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

If ai_viewer <> INAPP And ai_viewer <> PDFVIEWER Then Return -1
ii_viewer = ai_viewer
Return 1
end function

public function integer of_getviewer ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetViewer
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Integer.  Where PDF help files are shown: INAPP or PDFVIEWER (see of_SetViewer)
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

Return ii_viewer
end function

public function integer of_setdialoghelpfile (string as_file);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetDialogHelpFile
//
//	Access:  public
//
//	Arguments:
//	as_file		The help file of the PFC dialog boxes, pfcdlg.pdf by default.  Without a
//				path, it is looked for in the current folder and then in the folder of
//				the application.
//
//	Returns:  Integer
//	 1 = success
//	-1 = error (an invalid argument)
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

If IsNull(as_file) Or Len(Trim(as_file)) = 0 Then Return -1
is_dialoghelpfile = Trim(as_file)
Return 1
end function

public function string of_getdialoghelpfile ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetDialogHelpFile
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The help file of the PFC dialog boxes (see of_SetDialogHelpFile)
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

Return is_dialoghelpfile
end function

public function integer of_showhelp (string as_file);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ShowHelp
//
//	Access:  public
//
//	Arguments:
//	as_file		The help file: a PDF file, or a compiled HTML Help (.chm) or WinHelp (.hlp)
//				file.  Without a path, it is looked for in the current folder and then in
//				the folder of the application.
//
//	Returns:  Integer
//	 1 = success
//	-1 = error (the file doesn't exist, or couldn't be shown)
//
//	Description:  Shows a help file from its start: a PDF file where of_SetViewer says, and
//		any other help file with ShowHelp (its contents).
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

Return of_ShowHelp(as_file, "")
end function

public function integer of_showhelp (string as_file, string as_destination);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ShowHelp
//
//	Access:  public
//
//	Arguments:
//	as_file				The help file: a PDF file, or a compiled HTML Help (.chm) or WinHelp
//						(.hlp) file.  Without a path, it is looked for in the current folder
//						and then in the folder of the application.
//	as_destination		For a PDF file, the named destination to show (the letters, digits,
//						and "_", "-" and "." of it), or "" for the start of the file.  For
//						another help file, a keyword, or "" for its contents.
//
//	Returns:  Integer
//	 1 = success
//	-1 = error (the file doesn't exist, or couldn't be shown)
//
//	Description:  Shows a help file at a place.  A PDF file is shown where of_SetViewer
//		says: in the application (w_helpviewer), or in the user's PDF viewer.  The
//		viewers that PFC knows (Microsoft Edge, Google Chrome, Mozilla Firefox, Adobe
//		Acrobat and Acrobat Reader, and SumatraPDF) open it at the destination; another
//		viewer opens it at its start.
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

string	ls_path

If IsNull(as_file) Or IsNull(as_destination) Then Return -1
ls_path = of_GetPath(as_file)
If ls_path = "" Then Return -1

// A compiled HTML Help or WinHelp file: as ShowHelp always did
If of_IsCompiledHelp(ls_path) Then
	If Len(as_destination) > 0 Then
		Return ShowHelp(ls_path, Keyword!, as_destination)
	End If
	Return ShowHelp(ls_path, Index!)
End If

If ii_viewer = PDFVIEWER Then
	Return of_ShowInViewer(ls_path, of_CleanDestination(as_destination))
End If
Return of_ShowInApp(of_GetURL(ls_path, as_destination))
end function

public function integer of_showhelp (string as_file, long al_topic);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ShowHelp
//
//	Access:  public
//
//	Arguments:
//	as_file		The help file: a PDF file, or a compiled HTML Help (.chm) or WinHelp (.hlp)
//				file.  Without a path, it is looked for in the current folder and then in
//				the folder of the application.
//	al_topic	A help topic number: in a PDF file, the named destination topic_<number>
//				(see of_GetDestination), and in another help file, its help context number
//
//	Returns:  Integer
//	 1 = success
//	-1 = error (the file doesn't exist, or couldn't be shown)
//
//	Description:  Shows a help file at a topic, the way ShowHelp(file, Topic!, number) did.
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

string	ls_path

If IsNull(as_file) Or IsNull(al_topic) Then Return -1
ls_path = of_GetPath(as_file)
If ls_path = "" Then Return -1

If of_IsCompiledHelp(ls_path) Then
	Return ShowHelp(ls_path, Topic!, al_topic)
End If
Return of_ShowHelp(ls_path, of_GetDestination(al_topic))
end function

public function integer of_showdialoghelp (string as_destination);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ShowDialogHelp
//
//	Access:  public
//
//	Arguments:
//	as_destination		The topic of the dialog box in the PFC dialog help: the name of the
//						PFC window without its prefix, for example "w_find"
//
//	Returns:  Integer
//	 1 = success
//	-1 = error (the help file doesn't exist, or couldn't be shown)
//
//	Description:  Shows the help of a PFC dialog box, from the help file set with
//		of_SetDialogHelpFile.
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

Return of_ShowHelp(is_dialoghelpfile, as_destination)
end function

public function string of_getdestination (long al_topic);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetDestination
//
//	Access:  public
//
//	Arguments:
//	al_topic	A help topic number (a help context number of a compiled help file)
//
//	Returns:  String.  The named destination of the topic in a PDF help file,
//		"topic_<number>", or "" for a number of 0 or less
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

If IsNull(al_topic) Or al_topic <= 0 Then Return ""
Return "topic_" + String(al_topic)
end function

public function string of_geturl (string as_path, string as_destination);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetURL
//
//	Access:  public
//
//	Arguments:
//	as_path				The full path of a file
//	as_destination		A named destination in it, or ""
//
//	Returns:  String.  The file: URL of the file, with #nameddest=<destination> when a
//		destination is given (only its letters, digits, and "_", "-" and ".")
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

string	ls_url, ls_char, ls_dest
long		ll_pos

If IsNull(as_path) Or IsNull(as_destination) Then Return ""

// The characters that have a meaning in a URL are escaped
For ll_pos = 1 To Len(as_path)
	ls_char = Mid(as_path, ll_pos, 1)
	Choose Case ls_char
		Case "\"
			ls_url += "/"
		Case "%"
			ls_url += "%25"
		Case " "
			ls_url += "%20"
		Case "#"
			ls_url += "%23"
		Case "?"
			ls_url += "%3F"
		Case Else
			ls_url += ls_char
	End Choose
Next

// A UNC path (\\server\share) becomes file://server/share
If Left(ls_url, 2) = "//" Then
	ls_url = "file:" + ls_url
Else
	ls_url = "file:///" + ls_url
End If

ls_dest = of_CleanDestination(as_destination)
If ls_dest <> "" Then ls_url += "#nameddest=" + ls_dest
Return ls_url
end function

public function string of_getviewercommand (string as_viewer, string as_path, string as_destination);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetViewerCommand
//
//	Access:  public
//
//	Arguments:
//	as_viewer			The program that opens PDF files (its full path)
//	as_path				The full path of the PDF file
//	as_destination		The named destination to show, or ""
//
//	Returns:  String.  The command line that opens the file at the destination in that
//		program, or "" if PFC doesn't know how the program opens a file at a destination
//		(the file is then opened at its start)
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

string	ls_program, ls_dest

If IsNull(as_viewer) Or IsNull(as_path) Or IsNull(as_destination) Then Return ""
ls_dest = of_CleanDestination(as_destination)
ls_program = Lower(Mid(as_viewer, LastPos(as_viewer, "\") + 1))

Choose Case ls_program
	Case "msedge.exe", "chrome.exe", "firefox.exe", "brave.exe"
		// A browser takes the file's URL, with the destination
		Return '"' + as_viewer + '" "' + of_GetURL(as_path, ls_dest) + '"'
	Case "acrobat.exe", "acrord32.exe"
		If ls_dest = "" Then Return '"' + as_viewer + '" "' + as_path + '"'
		Return '"' + as_viewer + '" /A "nameddest=' + ls_dest + '" "' + as_path + '"'
	Case "sumatrapdf.exe"
		If ls_dest = "" Then Return '"' + as_viewer + '" "' + as_path + '"'
		Return '"' + as_viewer + '" -named-dest ' + ls_dest + ' "' + as_path + '"'
End Choose
Return ""
end function

public function boolean of_iscompiledhelp (string as_file);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_IsCompiledHelp
//
//	Access:  public
//
//	Arguments:
//	as_file		A help file
//
//	Returns:  Boolean.  True for a compiled HTML Help (.chm) or WinHelp (.hlp) file, which
//		ShowHelp shows; False for any other file (a PDF file)
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

string	ls_ext

If IsNull(as_file) Then Return False
ls_ext = Lower(Right(as_file, 4))
Return ls_ext = ".chm" Or ls_ext = ".hlp"
end function

protected function string of_getpath (string as_file);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetPath
//
//	Access:  protected
//
//	Arguments:
//	as_file		A help file, with or without a path
//
//	Returns:  String.  The full path of the file: as given, if it exists; otherwise in the
//		current folder or the folder of the application.  "" if it isn't found.
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

string	ls_file, ls_folder

ls_file = Trim(as_file)
If ls_file = "" Then Return ""

// A full path (C:\... or \\server\...)
If Mid(ls_file, 2, 1) = ":" Or Left(ls_file, 2) = "\\" Then
	If FileExists(ls_file) Then Return ls_file
	Return ""
End If

ls_folder = GetCurrentDirectory()
If Right(ls_folder, 1) <> "\" Then ls_folder += "\"
If FileExists(ls_folder + ls_file) Then Return ls_folder + ls_file

ls_folder = of_GetApplicationFolder()
If FileExists(ls_folder + ls_file) Then Return ls_folder + ls_file
Return ""
end function

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

protected function string of_cleandestination (string as_destination);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_CleanDestination
//
//	Access:  protected
//
//	Arguments:
//	as_destination		A named destination
//
//	Returns:  String.  Its letters, digits, and "_", "-" and ".", the characters a
//		destination's name can have here (it goes into a URL and a command line)
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

Constant String ALLOWED = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-."
string	ls_dest, ls_char
long		ll_pos

If IsNull(as_destination) Then Return ""
For ll_pos = 1 To Len(as_destination)
	ls_char = Mid(as_destination, ll_pos, 1)
	If Pos(ALLOWED, ls_char) > 0 Then ls_dest += ls_char
Next
Return ls_dest
end function

protected function integer of_showinapp (string as_url);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ShowInApp
//
//	Access:  protected
//
//	Arguments:
//	as_url		The file: URL of a PDF file, with its destination
//
//	Returns:  Integer
//	 1 = success
//	-1 = error
//
//	Description:  Shows the file in the help window of the application (w_helpviewer),
//		which is opened if it isn't open.
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

If as_url = "" Then Return -1

If Not IsValid(w_helpviewer) Then
	If Open(w_helpviewer) <> 1 Then Return -1
Else
	If w_helpviewer.WindowState = Minimized! Then w_helpviewer.WindowState = Normal!
	w_helpviewer.BringToTop = True
End If
Return w_helpviewer.of_Show(as_url)
end function

protected function integer of_showinviewer (string as_path, string as_destination);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ShowInViewer
//
//	Access:  protected
//
//	Arguments:
//	as_path				The full path of a PDF file
//	as_destination		The named destination to show, or ""
//
//	Returns:  Integer
//	 1 = success
//	-1 = error
//
//	Description:  Opens the file in the program that opens PDF files on this computer, at
//		the destination when PFC knows how the program does that (of_GetViewerCommand).
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

string	ls_viewer, ls_command, ls_null
longptr	llp_rc

SetNull(ls_null)
ls_viewer = Space(260)
llp_rc = FindExecutableW(as_path, ls_null, ls_viewer)
If llp_rc > 32 Then
	ls_command = of_GetViewerCommand(Trim(ls_viewer), as_path, as_destination)
	If ls_command <> "" Then
		If Run(ls_command) = 1 Then Return 1
	End If
End If

// A viewer PFC doesn't know: it opens the file at its start
llp_rc = ShellExecuteW(0, "open", as_path, ls_null, ls_null, 1)
If llp_rc > 32 Then Return 1
Return -1
end function

on pfc_n_cst_help.create
call super::create
end on

on pfc_n_cst_help.destroy
call super::destroy
end on
