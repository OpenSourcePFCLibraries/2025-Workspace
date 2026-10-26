$PBExportHeader$pfcscanner_n_cst_target.sru
$PBExportComments$Reads the application and library list of a project or target
forward
global type pfcscanner_n_cst_target from nonvisualobject
end type
end forward

global type pfcscanner_n_cst_target from nonvisualobject
end type
global pfcscanner_n_cst_target pfcscanner_n_cst_target

forward prototypes
public function integer of_getprojects (string as_solution, ref string as_projects[], ref string as_default)
public function integer of_open (string as_file, ref string as_app, ref string as_libs[])
public function string of_readfile (string as_file)
public function string of_folder (string as_path)
public function string of_fullpath (string as_folder, string as_path)
protected function integer of_openproject (string as_file, ref string as_app, ref string as_libs[])
protected function integer of_opentarget (string as_file, ref string as_app, ref string as_libs[])
protected function string of_attribute (string as_element, string as_attribute)
protected function string of_xmlvalue (string as_value)
protected function string of_targetvalue (string as_line)
end prototypes

public function integer of_getprojects (string as_solution, ref string as_projects[], ref string as_default);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_GetProjects
//
//	Access:  public
//
//	Arguments:
//	as_solution		A PowerBuilder solution (.pbsln)
//	as_projects[]	Its projects (.pbproj), full paths (passed by reference)
//	as_default		Its default project, a full path (passed by reference)
//
//	Returns:  Integer
//	The number of projects, -1 if the solution can't be read
//
//////////////////////////////////////////////////////////////////////////////

string	ls_xml, ls_element, ls_folder, ls_empty[]
long		ll_pos, ll_end
integer	li_count

as_projects = ls_empty
as_default = ""
ls_xml = of_ReadFile(as_solution)
If Len(ls_xml) = 0 Then Return -1
ls_folder = of_Folder(as_solution)

ll_pos = Pos(ls_xml, "<Projects")
If ll_pos > 0 Then
	ll_end = Pos(ls_xml, ">", ll_pos)
	ls_element = Mid(ls_xml, ll_pos, ll_end - ll_pos + 1)
	If Len(of_Attribute(ls_element, "Default")) > 0 Then
		as_default = of_FullPath(ls_folder, of_Attribute(ls_element, "Default"))
	End If
End If

ll_pos = Pos(ls_xml, "<Project ")
Do While ll_pos > 0
	ll_end = Pos(ls_xml, ">", ll_pos)
	If ll_end = 0 Then Exit
	ls_element = Mid(ls_xml, ll_pos, ll_end - ll_pos + 1)
	If Len(of_Attribute(ls_element, "Path")) > 0 Then
		li_count++
		as_projects[li_count] = of_FullPath(ls_folder, of_Attribute(ls_element, "Path"))
	End If
	ll_pos = Pos(ls_xml, "<Project ", ll_end)
Loop
If as_default = "" And li_count > 0 Then as_default = as_projects[1]
Return li_count
end function

public function integer of_open (string as_file, ref string as_app, ref string as_libs[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Open
//
//	Access:  public
//
//	Arguments:
//	as_file		A PowerBuilder project (.pbproj) or target (.pbt)
//	as_app		The application's name (passed by reference)
//	as_libs[]	The application's libraries (passed by reference), each one a folder
//					of object source or a .pbl:
//					 - a project's libraries are folders of source (PowerBuilder 2025
//					   solutions);
//					 - a target's libraries are its .pbl files, or their source folders
//					   in the workspace's ws_objects folder when the workspace has one
//
//	Returns:  Integer
//	The number of libraries, -1 if the file can't be read
//
//////////////////////////////////////////////////////////////////////////////

string	ls_empty[]

as_app = ""
as_libs = ls_empty
If Not FileExists(as_file) Then Return -1

Choose Case Lower(Mid(as_file, LastPos(as_file, ".") + 1))
	Case "pbproj"
		Return of_OpenProject(as_file, as_app, as_libs)
	Case "pbt"
		Return of_OpenTarget(as_file, as_app, as_libs)
End Choose
Return -1
end function

public function string of_readfile (string as_file);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_ReadFile
//
//	Access:  public
//
//	Arguments:
//	as_file	A text file
//
//	Returns:  String
//	The file's text, or "" if it can't be read
//
//////////////////////////////////////////////////////////////////////////////

integer	li_file
string	ls_text

// UTF-8 (source files have a BOM); otherwise, such as a target, ANSI
li_file = FileOpen(as_file, TextMode!, Read!, Shared!, Replace!, EncodingUTF8!)
If li_file < 0 Then li_file = FileOpen(as_file, TextMode!, Read!, Shared!)
If li_file < 0 Then Return ""
If FileReadEx(li_file, ls_text) < 0 Then ls_text = ""
FileClose(li_file)
Return ls_text
end function

public function string of_folder (string as_path);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Folder
//
//	Access:  public
//
//	Arguments:
//	as_path	A file's path
//
//	Returns:  String
//	The file's folder, without a trailing backslash
//
//////////////////////////////////////////////////////////////////////////////

long	ll_pos

ll_pos = LastPos(as_path, "\")
If ll_pos = 0 Then Return GetCurrentDirectory()
Return Left(as_path, ll_pos - 1)
end function

public function string of_fullpath (string as_folder, string as_path);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_FullPath
//
//	Access:  public
//
//	Arguments:
//	as_folder	The folder that as_path is relative to
//	as_path		A path, absolute or relative (..\ and .\ are allowed)
//
//	Returns:  String
//	The full path
//
//////////////////////////////////////////////////////////////////////////////

long	ll_pos

as_path = Trim(as_path)
If Mid(as_path, 2, 1) = ":" Or Left(as_path, 2) = "\\" Then Return as_path
If Left(as_path, 1) = "\" Then Return Left(as_folder, 2) + as_path

If Right(as_folder, 1) = "\" Then as_folder = Left(as_folder, Len(as_folder) - 1)
Do While True
	If Left(as_path, 2) = ".\" Then
		as_path = Mid(as_path, 3)
	ElseIf Left(as_path, 3) = "..\" Then
		as_path = Mid(as_path, 4)
		ll_pos = LastPos(as_folder, "\")
		If ll_pos > 0 Then as_folder = Left(as_folder, ll_pos - 1)
	Else
		Exit
	End If
Loop
Return as_folder + "\" + as_path
end function

protected function integer of_openproject (string as_file, ref string as_app, ref string as_libs[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_OpenProject
//
//	Access:  protected
//
//	Arguments:
//	as_file		A PowerBuilder 2025 project (.pbproj)
//	as_app		The application's name (passed by reference)
//	as_libs[]	The project's libraries, folders of source (passed by reference)
//
//	Returns:  Integer
//	The number of libraries, -1 if the project can't be read
//
//	Description:  A project is XML: <Application Name="..."/> and, in <Libraries>,
//		a <Library Path="..."/> for each library, relative to the project's folder.
//
//////////////////////////////////////////////////////////////////////////////

string	ls_xml, ls_element, ls_folder
long		ll_pos, ll_end
integer	li_count

ls_xml = of_ReadFile(as_file)
If Len(ls_xml) = 0 Then Return -1
ls_folder = of_Folder(as_file)

ll_pos = Pos(ls_xml, "<Application ")
If ll_pos > 0 Then
	ll_end = Pos(ls_xml, ">", ll_pos)
	as_app = of_Attribute(Mid(ls_xml, ll_pos, ll_end - ll_pos + 1), "Name")
End If

ll_pos = Pos(ls_xml, "<Library ")
Do While ll_pos > 0
	ll_end = Pos(ls_xml, ">", ll_pos)
	If ll_end = 0 Then Exit
	ls_element = Mid(ls_xml, ll_pos, ll_end - ll_pos + 1)
	If Len(of_Attribute(ls_element, "Path")) > 0 Then
		li_count++
		as_libs[li_count] = of_FullPath(ls_folder, of_Attribute(ls_element, "Path"))
	End If
	ll_pos = Pos(ls_xml, "<Library ", ll_end)
Loop
Return li_count
end function

protected function integer of_opentarget (string as_file, ref string as_app, ref string as_libs[]);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_OpenTarget
//
//	Access:  protected
//
//	Arguments:
//	as_file		A PowerBuilder target (.pbt)
//	as_app		The application's name (passed by reference)
//	as_libs[]	The target's libraries (passed by reference)
//
//	Returns:  Integer
//	The number of libraries, -1 if the target can't be read
//
//	Description:  A target has appname "..."; and LibList "...;...";, with the
//		libraries relative to the target's folder.  A workspace whose objects are
//		kept as source (PowerBuilder 2022 and later, with source control) has them
//		in ws_objects\<library>.src next to the target: that folder is used when it
//		exists, otherwise the .pbl.
//
//////////////////////////////////////////////////////////////////////////////

string	ls_text, ls_line, ls_liblist, ls_folder, ls_lib, ls_source
long		ll_pos, ll_end, ll_len
integer	li_count
pfcscanner_n_cst_string	lnv_string

ls_text = of_ReadFile(as_file)
If Len(ls_text) = 0 Then Return -1
ls_folder = of_Folder(as_file)

ll_len = Len(ls_text)
ll_pos = 1
Do While ll_pos <= ll_len
	ll_end = Pos(ls_text, "~n", ll_pos)
	If ll_end = 0 Then ll_end = ll_len + 1
	ls_line = Trim(lnv_string.of_GlobalReplace(Mid(ls_text, ll_pos, ll_end - ll_pos), "~r", ""))
	ll_pos = ll_end + 1
	If Lower(Left(ls_line, 8)) = "appname " Then
		as_app = of_TargetValue(ls_line)
	ElseIf Lower(Left(ls_line, 8)) = "liblist " Then
		ls_liblist = of_TargetValue(ls_line)
	End If
Loop

Do While Len(ls_liblist) > 0
	ll_pos = Pos(ls_liblist, ";")
	If ll_pos = 0 Then ll_pos = Len(ls_liblist) + 1
	ls_lib = Trim(Left(ls_liblist, ll_pos - 1))
	ls_liblist = Mid(ls_liblist, ll_pos + 1)
	If ls_lib = "" Then Continue

	li_count++
	as_libs[li_count] = of_FullPath(ls_folder, ls_lib)
	If Mid(ls_lib, 2, 1) <> ":" And Left(ls_lib, 1) <> "\" Then
		ls_source = of_FullPath(ls_folder + "\ws_objects", ls_lib) + ".src"
		If DirectoryExists(ls_source) Then as_libs[li_count] = ls_source
	End If
Loop
Return li_count
end function

protected function string of_attribute (string as_element, string as_attribute);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_Attribute
//
//	Access:  protected
//
//	Arguments:
//	as_element		An XML start tag, such as <Library Path="..."/>
//	as_attribute	An attribute's name
//
//	Returns:  String
//	The attribute's value, or "" if the element doesn't have it
//
//////////////////////////////////////////////////////////////////////////////

long	ll_pos, ll_end

ll_pos = Pos(as_element, " " + as_attribute + "=~"")
If ll_pos = 0 Then Return ""
ll_pos += Len(as_attribute) + 3
ll_end = Pos(as_element, "~"", ll_pos)
If ll_end = 0 Then Return ""
Return of_XmlValue(Mid(as_element, ll_pos, ll_end - ll_pos))
end function

protected function string of_xmlvalue (string as_value);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_XmlValue
//
//	Access:  protected
//
//	Arguments:
//	as_value	An XML attribute's value
//
//	Returns:  String
//	The value with its entities replaced
//
//////////////////////////////////////////////////////////////////////////////

pfcscanner_n_cst_string	lnv_string

as_value = lnv_string.of_GlobalReplace(as_value, "&lt;", "<")
as_value = lnv_string.of_GlobalReplace(as_value, "&gt;", ">")
as_value = lnv_string.of_GlobalReplace(as_value, "&quot;", "~"")
as_value = lnv_string.of_GlobalReplace(as_value, "&apos;", "'")
as_value = lnv_string.of_GlobalReplace(as_value, "&amp;", "&")
Return as_value
end function

protected function string of_targetvalue (string as_line);//////////////////////////////////////////////////////////////////////////////
//
//	Function:  of_TargetValue
//
//	Access:  protected
//
//	Arguments:
//	as_line	A line of a target, such as LibList "a.pbl;b\\c.pbl";
//
//	Returns:  String
//	The quoted value, with \\ read as \
//
//////////////////////////////////////////////////////////////////////////////

long	ll_pos, ll_end
pfcscanner_n_cst_string	lnv_string

ll_pos = Pos(as_line, "~"")
If ll_pos = 0 Then Return ""
ll_end = LastPos(as_line, "~"")
If ll_end <= ll_pos Then Return ""
Return lnv_string.of_GlobalReplace(Mid(as_line, ll_pos + 1, ll_end - ll_pos - 1), "\\", "\")
end function

on pfcscanner_n_cst_target.create
call super::create
TriggerEvent( this, "constructor" )
end on

on pfcscanner_n_cst_target.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on
