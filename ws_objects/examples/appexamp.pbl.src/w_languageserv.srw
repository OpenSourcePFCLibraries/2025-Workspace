$PBExportHeader$w_languageserv.srw
$PBExportComments$Example of the language service (n_cst_language): PFC in another language
forward
global type w_languageserv from w_main
end type
type st_intro from statictext within w_languageserv
end type
type st_filelabel from statictext within w_languageserv
end type
type sle_file from singlelineedit within w_languageserv
end type
type st_entries from statictext within w_languageserv
end type
type cb_choose from u_cb within w_languageserv
end type
type cb_english from u_cb within w_languageserv
end type
type cb_message from u_cb within w_languageserv
end type
type cb_sort from u_cb within w_languageserv
end type
type dw_1 from u_dw within w_languageserv
end type
type cb_close from u_cb within w_languageserv
end type
end forward

global type w_languageserv from w_main
integer x = 594
integer y = 400
integer width = 2551
integer height = 1820
string title = "PFC Example - Language Service"
st_intro st_intro
st_filelabel st_filelabel
sle_file sle_file
st_entries st_entries
cb_choose cb_choose
cb_english cb_english
cb_message cb_message
cb_sort cb_sort
dw_1 dw_1
cb_close cb_close
end type
global w_languageserv w_languageserv

type variables
Protected:
// TRUE if this window started the language service (and stops it when it closes)
boolean	ib_startedservice
// The folder the file dialog starts in
string	is_folder
end variables

forward prototypes
protected function integer of_setlanguagefile (string as_file)
protected subroutine of_showlanguage ()
end prototypes

protected function integer of_setlanguagefile (string as_file);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_SetLanguageFile
//
//	Access:			Protected
//
//	Arguments:
//	as_file			A language file (a translated pfc.lng), or "" for English
//
//	Returns:			Integer
//						The n_cst_language of_SetLanguageFile return value: 1 if the file was
//						read, 0 for English, -1 if it could not be read
//
//	Description:	Switches PFC to the language of the file.  An application with texts of
//						its own keeps them in its own file for each language (here pfcexamp.lng,
//						after the application object), which of_AddLanguageFile adds.
//
//////////////////////////////////////////////////////////////////////////////
integer	li_rc
string	ls_folder

If Not IsValid(gnv_app.inv_language) Then Return -1

li_rc = gnv_app.inv_language.of_SetLanguageFile(as_file)
If li_rc = 1 Then
	ls_folder = Left(as_file, LastPos(as_file, "\"))
	gnv_app.inv_language.of_AddLanguageFile(ls_folder + "pfcexamp.lng")
ElseIf li_rc = -1 Then
	MessageBox(this.Title, "The language file " + as_file + " could not be read.", Exclamation!)
End If

of_ShowLanguage()
Return li_rc
end function

protected subroutine of_showlanguage ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_ShowLanguage
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Description:	Shows the language file the service uses and how many texts it read.
//
//////////////////////////////////////////////////////////////////////////////
If IsValid(gnv_app.inv_language) And gnv_app.inv_language.of_GetCount() > 0 Then
	sle_file.Text = gnv_app.inv_language.of_GetLanguageFile()
	st_entries.Text = String(gnv_app.inv_language.of_GetCount()) + " texts read"
Else
	sle_file.Text = ""
	st_entries.Text = "No language file: PFC is in English"
End If
end subroutine

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	Starts the language service if the application doesn't use it yet.
//						The file dialog starts in the lang folder of a localization repository
//						checked out next to this one, if there is one.
//
//////////////////////////////////////////////////////////////////////////////
string	ls_folder

If Not IsValid(gnv_app.inv_language) Then
	gnv_app.of_SetLanguage(True)
	ib_startedservice = True
End If

ls_folder = GetCurrentDirectory()
If DirectoryExists(ls_folder + "\..\..\localization\lang") Then
	is_folder = ls_folder + "\..\..\localization\lang"
Else
	is_folder = ls_folder
End If

of_ShowLanguage()
end event

event close;call super::close;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			close
//
//	Description:	Leaves the rest of the application as it was: stops the language service
//						if this window started it, or goes back to the application's own
//						language files.
//
//////////////////////////////////////////////////////////////////////////////
If ib_startedservice Then
	gnv_app.of_SetLanguage(False)
ElseIf IsValid(gnv_app.inv_language) Then
	gnv_app.inv_language.of_SetLanguageFile(gnv_app.inv_language.of_GetDefaultLanguageFile())
	gnv_app.inv_language.of_AddLanguageFile(gnv_app.inv_language.of_GetDefaultApplicationFile())
End If
end event

on w_languageserv.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.st_filelabel=create st_filelabel
this.sle_file=create sle_file
this.st_entries=create st_entries
this.cb_choose=create cb_choose
this.cb_english=create cb_english
this.cb_message=create cb_message
this.cb_sort=create cb_sort
this.dw_1=create dw_1
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.st_filelabel
this.Control[iCurrent+3]=this.sle_file
this.Control[iCurrent+4]=this.st_entries
this.Control[iCurrent+5]=this.cb_choose
this.Control[iCurrent+6]=this.cb_english
this.Control[iCurrent+7]=this.cb_message
this.Control[iCurrent+8]=this.cb_sort
this.Control[iCurrent+9]=this.dw_1
this.Control[iCurrent+10]=this.cb_close
end on

on w_languageserv.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.st_filelabel)
destroy(this.sle_file)
destroy(this.st_entries)
destroy(this.cb_choose)
destroy(this.cb_english)
destroy(this.cb_message)
destroy(this.cb_sort)
destroy(this.dw_1)
destroy(this.cb_close)
end on

type st_intro from statictext within w_languageserv
integer x = 37
integer y = 32
integer width = 2437
integer height = 296
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "The language service (n_cst_language) shows PFC's messages, and the captions of its windows, menus and DataWindow objects, in the language of a language file.  Choose a translated pfc.lng (the localization repository has eight, in lang\<language>\pfc.lng), then show a PFC message, open the sort dialog, or right-click the list.  Windows and menus opened after the change use the new language; this window keeps its own texts."
boolean focusrectangle = false
end type

type st_filelabel from statictext within w_languageserv
integer x = 37
integer y = 360
integer width = 384
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Language file:"
boolean focusrectangle = false
end type

type sle_file from singlelineedit within w_languageserv
integer x = 439
integer y = 348
integer width = 2034
integer height = 84
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean displayonly = true
borderstyle borderstyle = stylelowered!
end type

type st_entries from statictext within w_languageserv
integer x = 439
integer y = 448
integer width = 2034
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
boolean focusrectangle = false
end type

type cb_choose from u_cb within w_languageserv
integer x = 37
integer y = 544
integer width = 718
integer taborder = 10
string text = "C&hoose a Language File..."
string facename = "Segoe UI"
end type

event clicked;call super::clicked;string	ls_path, ls_file

If GetFileOpenName("Choose a Language File", ls_path, ls_file, "lng", &
	"Language Files (*.lng),*.lng", is_folder) <> 1 Then Return

is_folder = Left(ls_path, LastPos(ls_path, "\") - 1)
parent.of_SetLanguageFile(ls_path)
end event

type cb_english from u_cb within w_languageserv
integer x = 777
integer y = 544
integer width = 375
integer taborder = 20
string text = "&English"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.of_SetLanguageFile("")
end event

type cb_message from u_cb within w_languageserv
integer x = 1175
integer y = 544
integer width = 640
integer taborder = 30
string text = "Show a PFC &Message"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// A PFC message with two values: the language file has it by its ID, with the %s
// placeholders where the translation puts the values
string	ls_values[]

ls_values = {"Company Name", "3"}
parent.of_MessageBox("pfc_checkrequired_missingvalue", "Required Value", &
	"Required value missing for %s on row %s.  Please enter a value.", ls_values, &
	Information!, OK!, 1)
end event

type cb_sort from u_cb within w_languageserv
integer x = 1838
integer y = 544
integer width = 635
integer taborder = 40
string text = "&Sort Dialog..."
string facename = "Segoe UI"
end type

event clicked;call super::clicked;dw_1.Event pfc_SortDlg()
end event

type dw_1 from u_dw within w_languageserv
string dataobject = "d_customerlist"
integer x = 37
integer y = 668
integer width = 2437
integer height = 880
integer taborder = 50
end type

event constructor;call super::constructor;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			constructor
//
//	Description:	The sort service with PFC's drag-and-drop sort dialog, whose captions
//						the language service translates.
//
//////////////////////////////////////////////////////////////////////////////
of_SetTransObject(sqlca)
of_SetSort(True)
inv_sort.of_SetStyle(inv_sort.DRAGDROP)
inv_sort.of_SetColumnHeader(True)
of_Retrieve()
end event

event pfc_retrieve;call super::pfc_retrieve;Return this.Retrieve()
end event

type cb_close from u_cb within w_languageserv
integer x = 2107
integer y = 1600
integer taborder = 60
string text = "Close"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
