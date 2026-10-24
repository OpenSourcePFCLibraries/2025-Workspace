$PBExportHeader$n_cst_examplecatalog.sru
$PBExportComments$The example catalog: the main window's tree and list, read from exam.txt and examcat.txt
forward
global type n_cst_examplecatalog from nonvisualobject
end type
end forward

global type n_cst_examplecatalog from nonvisualobject autoinstantiate
end type

type variables
Public:
// The catalog files, in the application's folder (next to examples.ini).  They are
// tab-delimited, without a header line:
// exam.txt: example_id, title, ostype, pbtype, exhelp, window
// examcat.txt: category_id, category_name, category_parent_id, example_id, picture_idx,
//		selected_picture_idx, state_picture_idx, overlay_picture_idx
constant string EXAMPLES_FILE = "exam.txt"
constant string CATEGORIES_FILE = "examcat.txt"

Protected:
n_ds	ids_examples
n_ds	ids_categories
string	is_ostype

// The TreeView's data sources, one per level (see of_GetTreeSource)
n_ds	ids_tree[3]
// The ListView's data source and the one before it (see of_GetListSource)
n_ds	ids_list
n_ds	ids_previouslist
end variables

forward prototypes
public function integer of_load (string as_ostype)
public function n_ds of_gettreesource (integer ai_level)
public function n_ds of_getlistsource (integer ai_treelevel, long al_key)
protected function boolean of_isavailable (long al_example)
protected function long of_addcategory (n_ds ads_target, long al_row)
protected function integer of_fillcategories (n_ds ads_target, long al_parent)
protected function integer of_fillexamples (n_ds ads_target, long al_parent)
protected function integer of_fillwindows (n_ds ads_target, long al_example)
public function string of_gettitle (string as_window)
protected function integer of_loadexamples ()
end prototypes

public function integer of_load (string as_ostype);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_Load
//
//	Access:			Public
//
//	Arguments:
//	as_ostype		The platform, as it appears in the examples' ostype column (for
//						example "windows"); only the examples for this platform are shown
//
//	Returns:			Integer
//						1 if the catalog files were read, -1 if one is missing or can't be read
//
//	Description:	Reads the catalog files and prepares the TreeView's data sources.
//
//////////////////////////////////////////////////////////////////////////////
long		ll_row, ll_rows

is_ostype = Lower(Trim(as_ostype))

If Not FileExists(EXAMPLES_FILE) Or Not FileExists(CATEGORIES_FILE) Then Return -1

If of_LoadExamples() <> 1 Then Return -1

// d_catexamples has the columns of examcat.txt, in the same order
ids_categories = Create n_ds
ids_categories.DataObject = "d_catexamples"
If ids_categories.ImportFile(CATEGORIES_FILE) < 0 Then Return -1
ids_categories.SetSort("category_name A")
ids_categories.Sort()

ids_tree[1] = Create n_ds
ids_tree[1].DataObject = "d_toplevel"
ids_tree[2] = Create n_ds
ids_tree[2].DataObject = "d_maincategorylist"
ids_tree[3] = Create n_ds
ids_tree[3].DataObject = "d_catexamples"

// Level 1: the root
ll_rows = ids_categories.RowCount()
For ll_row = 1 To ll_rows
	If ids_categories.GetItemNumber(ll_row, "category_id") = 0 Then of_AddCategory(ids_tree[1], ll_row)
Next
// Levels 2 and 3: the categories and the examples of every parent.  The TreeView's level
// source service filters them on category_parent_id.
of_FillCategories(ids_tree[2], -1)
of_FillExamples(ids_tree[3], -1)

Return 1
end function

public function n_ds of_gettreesource (integer ai_level);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_GetTreeSource
//
//	Access:			Public
//
//	Arguments:
//	ai_level		The TreeView level: 1 (the root), 2 (the categories) or 3 (the examples
//					and subcategories)
//
//	Returns:			n_ds
//						The level's data source, with the rows of every parent
//
//////////////////////////////////////////////////////////////////////////////
n_ds	lds_none

If ai_level < 1 Or ai_level > UpperBound(ids_tree) Then Return lds_none
Return ids_tree[ai_level]
end function

public function n_ds of_getlistsource (integer ai_treelevel, long al_key);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_GetListSource
//
//	Access:			Public
//
//	Arguments:
//	ai_treelevel	The level of the selected TreeView item
//	al_key			Its category_id (level 1 and 2) or example_id (level 3)
//
//	Returns:			n_ds
//						The rows the ListView shows for the item: the categories under it
//						(level 1), the examples and subcategories under it (level 2), or the
//						example itself (level 3)
//
//	Description:	Each call creates a new DataStore.  The one before stays, because the
//						ListView's data source service still refers to it until the new one is
//						registered; the one before that is destroyed.
//
//////////////////////////////////////////////////////////////////////////////
If IsValid(ids_previouslist) Then Destroy ids_previouslist
ids_previouslist = ids_list
ids_list = Create n_ds

Choose Case ai_treelevel
	Case 1
		ids_list.DataObject = "d_maincategorylist"
		of_FillCategories(ids_list, al_key)
	Case 2
		ids_list.DataObject = "d_catexamples"
		of_FillExamples(ids_list, al_key)
	Case 3
		ids_list.DataObject = "d_windows"
		of_FillWindows(ids_list, al_key)
End Choose

Return ids_list
end function

protected function boolean of_isavailable (long al_example);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_IsAvailable
//
//	Access:			Protected
//
//	Arguments:
//	al_example		An example_id
//
//	Returns:			Boolean
//						TRUE if the example exists and its ostype includes the platform (the
//						subcategories' rows refer to example 0, which includes every platform)
//
//////////////////////////////////////////////////////////////////////////////
long		ll_row
string	ls_ostype

ll_row = ids_examples.Find("example_id = " + String(al_example), 1, ids_examples.RowCount())
If ll_row < 1 Then Return False
ls_ostype = Lower(ids_examples.GetItemString(ll_row, "ostype"))
If IsNull(ls_ostype) Then Return False
Return Pos(ls_ostype, is_ostype) > 0
end function

protected function long of_addcategory (n_ds ads_target, long al_row);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_AddCategory
//
//	Access:			Protected
//
//	Arguments:
//	ads_target		The DataStore to add the row to
//	al_row			The row in the categories
//
//	Returns:			Long
//						The new row in ads_target
//
//	Description:	Copies the category's columns that ads_target has, by name: the catalog
//						DataWindows don't all have the same columns, or in the same order.
//
//////////////////////////////////////////////////////////////////////////////
integer	li_col, li_cols
long		ll_new
string	ls_column, ls_type

ll_new = ads_target.InsertRow(0)
li_cols = Integer(ads_target.Describe("DataWindow.Column.Count"))
For li_col = 1 To li_cols
	ls_column = ads_target.Describe("#" + String(li_col) + ".Name")
	If ids_categories.Describe(ls_column + ".ColType") = "!" Then Continue
	ls_type = Lower(ads_target.Describe(ls_column + ".ColType"))
	If Left(ls_type, 4) = "char" Then
		ads_target.SetItem(ll_new, ls_column, ids_categories.GetItemString(al_row, ls_column))
	ElseIf Left(ls_type, 7) = "decimal" Then
		ads_target.SetItem(ll_new, ls_column, ids_categories.GetItemDecimal(al_row, ls_column))
	Else
		ads_target.SetItem(ll_new, ls_column, Long(ids_categories.GetItemNumber(al_row, ls_column)))
	End If
Next
Return ll_new
end function

protected function integer of_fillcategories (n_ds ads_target, long al_parent);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_FillCategories
//
//	Access:			Protected
//
//	Arguments:
//	ads_target		The DataStore to fill (d_maincategorylist)
//	al_parent		The parent category, or -1 for every parent
//
//	Returns:			Integer
//						The number of rows added
//
//	Description:	The categories under a category: the rows that refer to no example
//						(example_id 0), except the root, which is its own parent.
//
//////////////////////////////////////////////////////////////////////////////
long	ll_row, ll_rows, ll_parent
integer	li_count

ll_rows = ids_categories.RowCount()
For ll_row = 1 To ll_rows
	ll_parent = ids_categories.GetItemNumber(ll_row, "category_parent_id")
	If al_parent <> -1 And ll_parent <> al_parent Then Continue
	If ids_categories.GetItemNumber(ll_row, "example_id") <> 0 Then Continue
	If ids_categories.GetItemNumber(ll_row, "category_id") = ll_parent Then Continue
	of_AddCategory(ads_target, ll_row)
	li_count++
Next
Return li_count
end function

protected function integer of_fillexamples (n_ds ads_target, long al_parent);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_FillExamples
//
//	Access:			Protected
//
//	Arguments:
//	ads_target		The DataStore to fill (d_catexamples)
//	al_parent		The parent category, or -1 for every parent
//
//	Returns:			Integer
//						The number of rows added
//
//	Description:	The rows under a category whose example is available on this
//						platform (see of_IsAvailable).
//
//////////////////////////////////////////////////////////////////////////////
long	ll_row, ll_rows
integer	li_count

ll_rows = ids_categories.RowCount()
For ll_row = 1 To ll_rows
	If al_parent <> -1 And ids_categories.GetItemNumber(ll_row, "category_parent_id") <> al_parent Then Continue
	If Not of_IsAvailable(ids_categories.GetItemNumber(ll_row, "example_id")) Then Continue
	of_AddCategory(ads_target, ll_row)
	li_count++
Next
Return li_count
end function

protected function integer of_fillwindows (n_ds ads_target, long al_example);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_FillWindows
//
//	Access:			Protected
//
//	Arguments:
//	ads_target		The DataStore to fill (d_windows)
//	al_example		The example_id
//
//	Returns:			Integer
//						The number of rows added
//
//	Description:	The example with its window, once for each category row that refers to
//						it, with that row's pictures.
//
//////////////////////////////////////////////////////////////////////////////
long	ll_row, ll_rows, ll_example, ll_new
integer	li_count

ll_example = ids_examples.Find("example_id = " + String(al_example), 1, ids_examples.RowCount())
If ll_example < 1 Then Return 0

ll_rows = ids_categories.RowCount()
For ll_row = 1 To ll_rows
	If ids_categories.GetItemNumber(ll_row, "example_id") <> al_example Then Continue
	ll_new = of_AddCategory(ads_target, ll_row)
	ads_target.SetItem(ll_new, "window", ids_examples.GetItemString(ll_example, "window"))
	ads_target.SetItem(ll_new, "example_id", al_example)
	ads_target.SetItem(ll_new, "title", ids_examples.GetItemString(ll_example, "title"))
	ads_target.SetItem(ll_new, "example", "Example")
	li_count++
Next
Return li_count
end function

public function string of_gettitle (string as_window);//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_GetTitle
//
//	Access:			Public
//
//	Arguments:
//	as_window		The class name of an example's window
//
//	Returns:			String
//						The example's title in the catalog, "" if the catalog has no example
//						with that window, or "!" if the examples file can't be read
//
//	Description:	Used by the examples' windows for their title (see w_master's open
//						event).  Reads only the examples file.
//
//////////////////////////////////////////////////////////////////////////////
long	ll_row

If of_LoadExamples() <> 1 Then Return "!"
ll_row = ids_examples.Find("Lower(window) = '" + Lower(as_window) + "'", 1, ids_examples.RowCount())
If ll_row < 1 Then Return ""
Return ids_examples.GetItemString(ll_row, "title")
end function

protected function integer of_loadexamples ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_LoadExamples
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Returns:			Integer
//						1 if the examples file is read (now or before), -1 if it can't be
//
//////////////////////////////////////////////////////////////////////////////
If IsValid(ids_examples) Then Return 1
If Not FileExists(EXAMPLES_FILE) Then Return -1

ids_examples = Create n_ds
ids_examples.DataObject = "d_examplecatalog"
If ids_examples.ImportFile(EXAMPLES_FILE) < 0 Then
	Destroy ids_examples
	Return -1
End If
Return 1
end function

on n_cst_examplecatalog.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_examplecatalog.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event destructor;integer	li_level

For li_level = 1 To UpperBound(ids_tree)
	If IsValid(ids_tree[li_level]) Then Destroy ids_tree[li_level]
Next
If IsValid(ids_list) Then Destroy ids_list
If IsValid(ids_previouslist) Then Destroy ids_previouslist
If IsValid(ids_categories) Then Destroy ids_categories
If IsValid(ids_examples) Then Destroy ids_examples
end event
