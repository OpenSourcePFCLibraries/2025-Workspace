$PBExportHeader$w_metaclass.srw
$PBExportComments$Example of the metaclass service (n_cst_metaclass): what a class is made of, from its class definition
forward
global type w_metaclass from w_main
end type
type st_intro from statictext within w_metaclass
end type
type st_class from statictext within w_metaclass
end type
type sle_class from singlelineedit within w_metaclass
end type
type st_list from statictext within w_metaclass
end type
type ddlb_list from dropdownlistbox within w_metaclass
end type
type cb_show from u_cb within w_metaclass
end type
type cbx_skip from checkbox within w_metaclass
end type
type st_overview from statictext within w_metaclass
end type
type lb_list from listbox within w_metaclass
end type
type st_event from statictext within w_metaclass
end type
type sle_event from singlelineedit within w_metaclass
end type
type cb_check from u_cb within w_metaclass
end type
type st_check from statictext within w_metaclass
end type
type cb_close from u_cb within w_metaclass
end type
end forward

global type w_metaclass from w_main
integer x = 594
integer y = 300
integer width = 2240
integer height = 1800
string title = "PFC Example - Metaclass Service"
st_intro st_intro
st_class st_class
sle_class sle_class
st_list st_list
ddlb_list ddlb_list
cb_show cb_show
cbx_skip cbx_skip
st_overview st_overview
lb_list lb_list
st_event st_event
sle_event sle_event
cb_check cb_check
st_check st_check
cb_close cb_close
end type
global w_metaclass w_metaclass

type variables
Protected:
n_cst_metaclass	inv_metaclass
end variables

event open;call super::open;// n_cst_metaclass is autoinstantiated
ddlb_list.SelectItem(1)
cb_show.event clicked()
cb_check.event clicked()
end event

on w_metaclass.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.st_class=create st_class
this.sle_class=create sle_class
this.st_list=create st_list
this.ddlb_list=create ddlb_list
this.cb_show=create cb_show
this.cbx_skip=create cbx_skip
this.st_overview=create st_overview
this.lb_list=create lb_list
this.st_event=create st_event
this.sle_event=create sle_event
this.cb_check=create cb_check
this.st_check=create st_check
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.st_class
this.Control[iCurrent+3]=this.sle_class
this.Control[iCurrent+4]=this.st_list
this.Control[iCurrent+5]=this.ddlb_list
this.Control[iCurrent+6]=this.cb_show
this.Control[iCurrent+7]=this.cbx_skip
this.Control[iCurrent+8]=this.st_overview
this.Control[iCurrent+9]=this.lb_list
this.Control[iCurrent+10]=this.st_event
this.Control[iCurrent+11]=this.sle_event
this.Control[iCurrent+12]=this.cb_check
this.Control[iCurrent+13]=this.st_check
this.Control[iCurrent+14]=this.cb_close
end on

on w_metaclass.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.st_class)
destroy(this.sle_class)
destroy(this.st_list)
destroy(this.ddlb_list)
destroy(this.cb_show)
destroy(this.cbx_skip)
destroy(this.st_overview)
destroy(this.lb_list)
destroy(this.st_event)
destroy(this.sle_event)
destroy(this.cb_check)
destroy(this.st_check)
destroy(this.cb_close)
end on

type st_intro from statictext within w_metaclass
integer x = 37
integer y = 32
integer width = 2130
integer height = 172
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "The metaclass service (n_cst_metaclass) reads a class's definition at run time: its ancestors, events, functions, variables and nested classes, and whether it defines or scripts an event.  Type a class name, for example w_metaclass, u_dw or n_cst_string."
boolean focusrectangle = false
end type

type st_class from statictext within w_metaclass
integer x = 37
integer y = 248
integer width = 160
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Class:"
boolean focusrectangle = false
end type

type sle_class from singlelineedit within w_metaclass
integer x = 210
integer y = 236
integer width = 640
integer height = 84
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
string text = "w_metaclass"
borderstyle borderstyle = stylelowered!
end type

type st_list from statictext within w_metaclass
integer x = 887
integer y = 248
integer width = 128
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "&List:"
boolean focusrectangle = false
end type

type ddlb_list from dropdownlistbox within w_metaclass
integer x = 1024
integer y = 236
integer width = 640
integer height = 600
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
boolean sorted = false
boolean vscrollbar = true
string item[] = {"Ancestors","Events","Functions","Instance Variables","Nested Classes"}
borderstyle borderstyle = stylelowered!
end type

event selectionchanged;cb_show.event clicked()
end event

type cb_show from u_cb within w_metaclass
integer x = 1701
integer y = 232
integer width = 466
integer taborder = 30
string text = "&Show"
end type

event clicked;call super::clicked;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			clicked
//
//	Description:	Shows an overview of the class (of_GetOverview) and lists the
//						selected kind of definitions.
//
//////////////////////////////////////////////////////////////////////////////
classdefinition	lcd_class
s_classoverview_attrib	lstr_overview
string	ls_class, ls_list[], ls_auto
integer	li_count, li_i

ls_class = Trim(sle_class.Text)
lb_list.Reset()

// Leave out what PowerBuilder defines for every class of the type, or not
inv_metaclass.of_SetSkipSystemMode(cbx_skip.Checked)

// of_GetClassDefinition finds the class in the application's library list
lcd_class = inv_metaclass.of_GetClassDefinition(ls_class)
If Not IsValid(lcd_class) Then
	st_overview.Text = "There is no class " + ls_class + " in the application."
	Return
End If

inv_metaclass.of_GetOverview(lcd_class, lstr_overview)
If lstr_overview.isautoinstanciate Then ls_auto = ", autoinstantiated" Else ls_auto = ""
st_overview.Text = "of_GetOverview:  " + lstr_overview.class + ", a " + lstr_overview.classtype + &
	ls_auto + ", in " + lstr_overview.classlib + "; ancestors: " + String(lstr_overview.ancestorcount)

Choose Case ddlb_list.Text
	Case "Ancestors"
		// From the class's parent to the system class
		For li_i = 1 To lstr_overview.ancestorcount
			ls_list[li_i] = lstr_overview.ancestor[li_i]
		Next
		li_count = lstr_overview.ancestorcount
	Case "Events"
		li_count = inv_metaclass.of_GetEvents(lcd_class, ls_list)
	Case "Functions"
		li_count = inv_metaclass.of_GetFunctions(lcd_class, Public!, ls_list)
	Case "Instance Variables"
		li_count = inv_metaclass.of_GetInstanceVariables(lcd_class, ls_list)
	Case "Nested Classes"
		li_count = inv_metaclass.of_GetNestedClasses(lcd_class, ls_list)
End Choose

For li_i = 1 To li_count
	lb_list.AddItem(ls_list[li_i])
Next
If li_count <= 0 Then lb_list.AddItem("(none)")
end event

type cbx_skip from checkbox within w_metaclass
integer x = 37
integer y = 340
integer width = 2130
integer height = 72
integer taborder = 35
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Skip the &system-defined events, functions and variables (of_SetSkipSystemMode)"
boolean checked = true
end type

event clicked;cb_show.event clicked()
end event

type st_overview from statictext within w_metaclass
integer x = 37
integer y = 436
integer width = 2130
integer height = 72
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
boolean focusrectangle = false
end type

type lb_list from listbox within w_metaclass
integer x = 37
integer y = 528
integer width = 2130
integer height = 720
integer taborder = 40
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

type st_event from statictext within w_metaclass
integer x = 37
integer y = 1300
integer width = 160
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Event:"
boolean focusrectangle = false
end type

type sle_event from singlelineedit within w_metaclass
integer x = 210
integer y = 1288
integer width = 640
integer height = 84
integer taborder = 50
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
string text = "open"
borderstyle borderstyle = stylelowered!
end type

type cb_check from u_cb within w_metaclass
integer x = 887
integer y = 1284
integer width = 466
integer taborder = 60
string text = "Chec&k"
end type

event clicked;call super::clicked;// Whether the class has the event (of_IsEventDefined), and whether it or an
// ancestor has a script for it (of_IsEventImplemented)
string	ls_class, ls_event, ls_defined, ls_implemented

ls_class = Trim(sle_class.Text)
ls_event = Trim(sle_event.Text)
If Not IsValid(inv_metaclass.of_GetClassDefinition(ls_class)) Then
	st_check.Text = "There is no class " + ls_class + " in the application."
	Return
End If

If inv_metaclass.of_IsEventDefined(ls_class, ls_event) Then ls_defined = "yes" Else ls_defined = "no"
If inv_metaclass.of_IsEventImplemented(ls_class, ls_event) Then ls_implemented = "yes" Else ls_implemented = "no"
st_check.Text = ls_class + "." + ls_event + ":  of_IsEventDefined " + ls_defined + ",  of_IsEventImplemented " + ls_implemented
end event

type st_check from statictext within w_metaclass
integer x = 37
integer y = 1404
integer width = 2130
integer height = 128
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
boolean focusrectangle = false
end type

type cb_close from u_cb within w_metaclass
integer x = 1792
integer y = 1568
integer taborder = 70
string text = "Close"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
