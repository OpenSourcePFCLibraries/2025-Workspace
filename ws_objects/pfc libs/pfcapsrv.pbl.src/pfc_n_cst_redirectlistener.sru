$PBExportHeader$pfc_n_cst_redirectlistener.sru
$PBExportComments$PFC OAuth redirect listener (loopback)
forward
global type pfc_n_cst_redirectlistener from n_base
end type
end forward

global type pfc_n_cst_redirectlistener from n_base
end type
global pfc_n_cst_redirectlistener pfc_n_cst_redirectlistener

type prototypes
// Windows Sockets (ws2_32.dll). The ws_ prefix avoids PowerScript names such as Send.
Function long ws_WSAStartup (uint aui_version, ref blob ablb_wsadata) Library "ws2_32.dll" Alias For "WSAStartup"
Function long ws_WSACleanup () Library "ws2_32.dll" Alias For "WSACleanup"
Function long ws_WSAGetLastError () Library "ws2_32.dll" Alias For "WSAGetLastError"
Function longptr ws_socket (long al_family, long al_kind, long al_protocol) Library "ws2_32.dll" Alias For "socket"
Function long ws_bind (longptr al_socket, ref blob ablb_addr, long al_addrlen) Library "ws2_32.dll" Alias For "bind"
Function long ws_listen (longptr al_socket, long al_backlog) Library "ws2_32.dll" Alias For "listen"
Function long ws_getsockname (longptr al_socket, ref blob ablb_addr, ref long al_addrlen) Library "ws2_32.dll" Alias For "getsockname"
Function long ws_ioctlsocket (longptr al_socket, long al_command, ref ulong aul_arg) Library "ws2_32.dll" Alias For "ioctlsocket"
Function longptr ws_accept (longptr al_socket, longptr al_addr, longptr al_addrlen) Library "ws2_32.dll" Alias For "accept"
Function long ws_connect (longptr al_socket, ref blob ablb_addr, long al_addrlen) Library "ws2_32.dll" Alias For "connect"
Function long ws_recv (longptr al_socket, ref blob ablb_buffer, long al_length, long al_flags) Library "ws2_32.dll" Alias For "recv"
Function long ws_send (longptr al_socket, ref blob ablb_buffer, long al_length, long al_flags) Library "ws2_32.dll" Alias For "send"
Function long ws_closesocket (longptr al_socket) Library "ws2_32.dll" Alias For "closesocket"
Subroutine ws_Sleep (ulong aul_milliseconds) Library "kernel32.dll" Alias For "Sleep"
end prototypes

type variables
Public:
// Path of the redirect URI
Constant String DEFAULTPATH = "/callback"

Protected:
Constant Long AF_INET = 2
Constant Long SOCK_STREAM = 1
Constant Long IPPROTO_TCP = 6
Constant Long FIONBIO = -2147195266		// 0x8004667E
Constant Long WSAEWOULDBLOCK = 10035
Constant LongPtr INVALID_SOCKET = -1

boolean	ib_started
boolean	ib_cancel
longptr	il_socket = -1
long		il_port
string	is_path = DEFAULTPATH
// How long a connection may take to send its request (browsers open connections they
// don't use), in milliseconds
long		il_readtimeout = 3000
// The request that ended the wait, and its parameters (decoded)
string	is_request
string	is_names[]
string	is_values[]
// Page shown in the browser
string	is_title = "Signed in"
string	is_message = "You can close this window and return to the application."
end variables

forward prototypes
public function integer of_start ()
public function integer of_start (string as_path)
public function long of_getport ()
public function string of_getredirecturi ()
public function integer of_wait (long al_seconds)
public subroutine of_cancel ()
public function string of_getparameter (string as_name)
public function string of_getrequest ()
public subroutine of_stop ()
public subroutine of_setpage (string as_title, string as_message)
public subroutine of_setreadtimeout (long al_milliseconds)
protected function integer of_handleconnection (longptr al_client)
protected function integer of_parse (string as_request)
protected function integer of_sendresponse (longptr al_client, string as_status, string as_body)
protected function string of_urldecode (string as_value)
protected function boolean of_setnonblocking (longptr al_socket)
end prototypes

public function integer of_start ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Start
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Integer.  1 if the listener is listening, -1 if not
//
//	Description:  Starts listening for the redirect, on the path DEFAULTPATH ("/callback").
//		See of_Start(string).
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

Return of_Start(DEFAULTPATH)
end function

public function integer of_start (string as_path);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Start
//
//	Access:  public
//
//	Arguments:
//	as_path		path of the redirect URI, for example "/callback"
//
//	Returns:  Integer.  1 if the listener is listening, -1 if not
//
//	Description:  Starts listening for the redirect of an OAuth authorization request
//		(RFC 8252, loopback interface redirection).  The listener accepts connections
//		from this computer only, on 127.0.0.1 and a port that Windows chooses.  Start
//		it before opening the browser: connections that arrive before of_Wait is called
//		are queued, so a fast response can't be missed.  The redirect URI to send is
//		of_GetRedirectURI().
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

blob{512}	lblb_wsadata
blob{16}		lblb_addr
long			ll_len
byte			lbyte_hi, lbyte_lo

of_Stop()
If IsNull(as_path) Or Left(as_path, 1) <> "/" Then Return -1
is_path = as_path

If ws_WSAStartup(514, lblb_wsadata) <> 0 Then Return -1		// version 2.2
ib_started = True

il_socket = ws_socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
If il_socket = INVALID_SOCKET Then
	of_Stop()
	Return -1
End If

// sockaddr_in: family AF_INET, port 0 (Windows chooses), address 127.0.0.1
SetByte(lblb_addr, 1, 2)
SetByte(lblb_addr, 5, 127)
SetByte(lblb_addr, 8, 1)
If ws_bind(il_socket, lblb_addr, 16) <> 0 Or ws_listen(il_socket, 16) <> 0 Then
	of_Stop()
	Return -1
End If

// The port Windows chose (network byte order)
ll_len = 16
If ws_getsockname(il_socket, lblb_addr, ll_len) <> 0 Then
	of_Stop()
	Return -1
End If
GetByte(lblb_addr, 3, lbyte_hi)
GetByte(lblb_addr, 4, lbyte_lo)
il_port = lbyte_hi * 256 + lbyte_lo

If Not of_SetNonBlocking(il_socket) Then
	of_Stop()
	Return -1
End If

Return 1
end function

public function long of_getport ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetPort
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  Long.  The port the listener listens on, or 0 if it isn't listening
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

Return il_port
end function

public function string of_getredirecturi ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetRedirectURI
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The redirect URI, for example http://127.0.0.1:52417/callback, or ""
//		if the listener isn't listening
//
//	Description:  The port changes each time.  Register the redirect URI with the identity
//		provider so that any port matches (Microsoft Entra ID ignores the port of
//		loopback redirect URIs; in Authentik, use a regular expression such as
//		http://127\.0\.0\.1:\d+/callback).
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

If il_port = 0 Then Return ""
Return "http://127.0.0.1:" + String(il_port) + is_path
end function

public function integer of_wait (long al_seconds);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Wait
//
//	Access:  public
//
//	Arguments:
//	al_seconds	how long to wait for the redirect, in seconds
//
//	Returns:  Integer
//	 1 = the redirect arrived: see of_GetParameter("code"), ("state") and ("error")
//	 0 = it didn't arrive in time, or of_Cancel was called
//	-1 = the listener isn't listening, or a socket error
//
//	Description:  Waits for the browser to request the redirect URI with the result of
//		the authorization request (a code or error parameter).  The window stays
//		responsive: the function checks for connections every 50 milliseconds and lets
//		PowerBuilder process events in between, so a Cancel button can call of_Cancel.
//		Connections that send nothing (browsers open some in advance) are closed after a
//		few seconds, and requests for other paths (such as /favicon.ico) get a 404; the
//		wait goes on.  The browser shows a page saying the user can close it (see
//		of_SetPage).  Check the state parameter against the one you sent.
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

longptr	ll_client
long		ll_end
integer	li_rc

If il_socket = INVALID_SOCKET Then Return -1

ib_cancel = False
ll_end = CPU() + al_seconds * 1000

Do While CPU() < ll_end
	If ib_cancel Then Return 0

	ll_client = ws_accept(il_socket, 0, 0)
	If ll_client <> INVALID_SOCKET Then
		li_rc = of_HandleConnection(ll_client)
		ws_closesocket(ll_client)
		If li_rc = 1 Then Return 1
	Else
		If ws_WSAGetLastError() <> WSAEWOULDBLOCK Then Return -1
		Yield()
		ws_Sleep(50)
	End If
Loop

Return 0
end function

public subroutine of_cancel ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Cancel
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Ends of_Wait (it returns 0), for example from a Cancel button.
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

ib_cancel = True
end subroutine

public function string of_getparameter (string as_name);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetParameter
//
//	Access:  public
//
//	Arguments:
//	as_name		name of a query parameter of the redirect, for example "code"
//
//	Returns:  String.  Its value (URL decoded), or "" if the redirect didn't have it
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

integer	li_idx

For li_idx = 1 To UpperBound(is_names)
	If is_names[li_idx] = as_name Then Return is_values[li_idx]
Next

Return ""
end function

public function string of_getrequest ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetRequest
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  String.  The request line of the redirect, for example
//		"GET /callback?code=...&state=... HTTP/1.1", or ""
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

Return is_request
end function

public subroutine of_stop ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Stop
//
//	Access:  public
//
//	Arguments:  None
//
//	Returns:  None
//
//	Description:  Stops listening and releases Windows Sockets.  The destructor calls it.
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

If il_socket <> INVALID_SOCKET Then
	ws_closesocket(il_socket)
	il_socket = INVALID_SOCKET
End If
If ib_started Then
	ws_WSACleanup()
	ib_started = False
End If
il_port = 0
end subroutine

public subroutine of_setpage (string as_title, string as_message);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetPage
//
//	Access:  public
//
//	Arguments:
//	as_title		title of the page the browser shows after the redirect
//	as_message	its text
//
//	Returns:  None
//
//	Description:  The default page says the user can close the browser window and return
//		to the application.
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

is_title = as_title
is_message = as_message
end subroutine

public subroutine of_setreadtimeout (long al_milliseconds);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetReadTimeout
//
//	Access:  public
//
//	Arguments:
//	al_milliseconds	how long a connection may take to send its request (default 3000)
//
//	Returns:  None
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

If al_milliseconds > 0 Then il_readtimeout = al_milliseconds
end subroutine

protected function integer of_handleconnection (longptr al_client);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_HandleConnection
//
//	Access:  protected
//
//	Arguments:
//	al_client	an accepted connection
//
//	Returns:  Integer.  1 if it was the redirect (the parameters are stored), 0 if not
//
//	Description:  Reads the request (until the end of its headers, for at most
//		il_readtimeout milliseconds) and answers it: the page for the redirect, a 404 for
//		other paths.  A connection that sends nothing is left for of_Wait to close.
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

blob{4096}	lblb_buffer
blob			lblb_request
long			ll_read, ll_end
string		ls_request, ls_body

of_SetNonBlocking(al_client)
ll_end = CPU() + il_readtimeout

Do While CPU() < ll_end
	ll_read = ws_recv(al_client, lblb_buffer, 4096, 0)
	If ll_read > 0 Then
		lblb_request += BlobMid(lblb_buffer, 1, ll_read)
		ls_request = String(lblb_request, EncodingUTF8!)
		If Pos(ls_request, "~r~n~r~n") > 0 Or Len(lblb_request) > 65536 Then Exit
	ElseIf ll_read = 0 Then
		// The browser closed the connection
		Exit
	ElseIf ws_WSAGetLastError() = WSAEWOULDBLOCK Then
		Yield()
		ws_Sleep(20)
	Else
		Exit
	End If
Loop

If Len(lblb_request) = 0 Then Return 0

If of_Parse(ls_request) = 1 Then
	ls_body = "<!DOCTYPE html><html><head><meta charset=~"utf-8~"><title>" + is_title + &
		"</title></head><body style=~"font-family: sans-serif; margin: 3em~"><h1>" + is_title + &
		"</h1><p>" + is_message + "</p></body></html>"
	of_SendResponse(al_client, "200 OK", ls_body)
	Return 1
End If

of_SendResponse(al_client, "404 Not Found", "")
Return 0
end function

protected function integer of_parse (string as_request);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Parse
//
//	Access:  protected
//
//	Arguments:
//	as_request	an HTTP request
//
//	Returns:  Integer.  1 if it is a GET of the redirect path with a code or error
//		parameter (the request line and parameters are stored), 0 if not
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

string	ls_line, ls_target, ls_query, ls_pair, ls_names[], ls_values[], ls_empty[]
long		ll_pos, ll_count
boolean	lb_result

// Request line: GET <target> HTTP/1.1
ll_pos = Pos(as_request, "~r~n")
If ll_pos = 0 Then ll_pos = Len(as_request) + 1
ls_line = Left(as_request, ll_pos - 1)
If Left(ls_line, 4) <> "GET " Then Return 0
ls_target = Mid(ls_line, 5)
ll_pos = Pos(ls_target, " ")
If ll_pos > 0 Then ls_target = Left(ls_target, ll_pos - 1)

ll_pos = Pos(ls_target, "?")
If ll_pos = 0 Then Return 0
If Left(ls_target, ll_pos - 1) <> is_path Then Return 0
ls_query = Mid(ls_target, ll_pos + 1)

Do While Len(ls_query) > 0
	ll_pos = Pos(ls_query, "&")
	If ll_pos = 0 Then ll_pos = Len(ls_query) + 1
	ls_pair = Left(ls_query, ll_pos - 1)
	ls_query = Mid(ls_query, ll_pos + 1)
	If ls_pair = "" Then Continue
	ll_count++
	ll_pos = Pos(ls_pair, "=")
	If ll_pos = 0 Then
		ls_names[ll_count] = of_UrlDecode(ls_pair)
		ls_values[ll_count] = ""
	Else
		ls_names[ll_count] = of_UrlDecode(Left(ls_pair, ll_pos - 1))
		ls_values[ll_count] = of_UrlDecode(Mid(ls_pair, ll_pos + 1))
	End If
	If ls_names[ll_count] = "code" Or ls_names[ll_count] = "error" Then lb_result = True
Loop

If Not lb_result Then Return 0

is_request = ls_line
is_names = ls_names
is_values = ls_values
Return 1
end function

protected function integer of_sendresponse (longptr al_client, string as_status, string as_body);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SendResponse
//
//	Access:  protected
//
//	Arguments:
//	al_client	the connection
//	as_status	HTTP status, for example "200 OK"
//	as_body		HTML page ("" for none)
//
//	Returns:  Integer.  1 if the response was sent, -1 if not
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

blob	lblb_body, lblb_response, lblb_rest
long	ll_sent, ll_end

lblb_body = Blob(as_body, EncodingUTF8!)
lblb_response = Blob("HTTP/1.1 " + as_status + "~r~n" + &
	"Content-Type: text/html; charset=utf-8~r~n" + &
	"Content-Length: " + String(Len(lblb_body)) + "~r~n" + &
	"Cache-Control: no-store~r~n" + &
	"Connection: close~r~n~r~n", EncodingUTF8!) + lblb_body

ll_end = CPU() + il_readtimeout
Do While Len(lblb_response) > 0 And CPU() < ll_end
	ll_sent = ws_send(al_client, lblb_response, Len(lblb_response), 0)
	If ll_sent > 0 Then
		lblb_rest = BlobMid(lblb_response, ll_sent + 1)
		lblb_response = lblb_rest
	ElseIf ws_WSAGetLastError() = WSAEWOULDBLOCK Then
		ws_Sleep(10)
	Else
		Return -1
	End If
Loop

If Len(lblb_response) > 0 Then Return -1
Return 1
end function

protected function string of_urldecode (string as_value);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_UrlDecode
//
//	Access:  protected
//
//	Arguments:
//	as_value		a query string value
//
//	Returns:  String.  The value decoded: + is a space, %XX a byte of UTF-8
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

CoderObject	lnv_coder
blob			lblb_decoded
string		ls_value
long			ll_pos

ls_value = as_value
ll_pos = Pos(ls_value, "+")
Do While ll_pos > 0
	ls_value = Replace(ls_value, ll_pos, 1, " ")
	ll_pos = Pos(ls_value, "+", ll_pos + 1)
Loop
If Pos(ls_value, "%") = 0 Then Return ls_value

lnv_coder = Create CoderObject
lblb_decoded = lnv_coder.UrlDecode(ls_value)
Destroy lnv_coder

If IsNull(lblb_decoded) Then Return ls_value
Return String(lblb_decoded, EncodingUTF8!)
end function

protected function boolean of_setnonblocking (longptr al_socket);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_SetNonBlocking
//
//	Access:  protected
//
//	Arguments:
//	al_socket	a socket
//
//	Returns:  Boolean.  True if the socket is now in non-blocking mode
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

ulong	lul_on = 1

Return ws_ioctlsocket(al_socket, FIONBIO, lul_on) = 0
end function

on pfc_n_cst_redirectlistener.create
call super::create
end on

on pfc_n_cst_redirectlistener.destroy
call super::destroy
end on

event destructor;call super::destructor;of_Stop()
end event
