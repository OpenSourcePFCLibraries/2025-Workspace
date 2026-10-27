$PBExportHeader$w_utilityserv.srw
$PBExportComments$Example of the utility services: string, numerical, conversion, color, platform and collection objects
forward
global type w_utilityserv from w_main
end type
type st_intro from statictext within w_utilityserv
end type
type tab_1 from tab within w_utilityserv
end type
type tabpg_string from userobject within tab_1
end type
type st_string from statictext within tabpg_string
end type
type st_text from statictext within tabpg_string
end type
type sle_text from singlelineedit within tabpg_string
end type
type st_find from statictext within tabpg_string
end type
type sle_find from singlelineedit within tabpg_string
end type
type st_replace from statictext within tabpg_string
end type
type sle_replace from singlelineedit within tabpg_string
end type
type cb_string from u_cb within tabpg_string
end type
type lb_string from listbox within tabpg_string
end type
type tabpg_string from userobject within tab_1
st_string st_string
st_text st_text
sle_text sle_text
st_find st_find
sle_find sle_find
st_replace st_replace
sle_replace sle_replace
cb_string cb_string
lb_string lb_string
end type
type tabpg_numerical from userobject within tab_1
end type
type st_numerical from statictext within tabpg_numerical
end type
type st_value1 from statictext within tabpg_numerical
end type
type sle_value1 from singlelineedit within tabpg_numerical
end type
type st_value2 from statictext within tabpg_numerical
end type
type sle_value2 from singlelineedit within tabpg_numerical
end type
type st_base from statictext within tabpg_numerical
end type
type sle_base from singlelineedit within tabpg_numerical
end type
type cb_numerical from u_cb within tabpg_numerical
end type
type lb_numerical from listbox within tabpg_numerical
end type
type tabpg_numerical from userobject within tab_1
st_numerical st_numerical
st_value1 st_value1
sle_value1 sle_value1
st_value2 st_value2
sle_value2 sle_value2
st_base st_base
sle_base sle_base
cb_numerical cb_numerical
lb_numerical lb_numerical
end type
type tabpg_conversion from userobject within tab_1
end type
type st_conversion from statictext within tabpg_conversion
end type
type st_number from statictext within tabpg_conversion
end type
type sle_number from singlelineedit within tabpg_conversion
end type
type st_boolean from statictext within tabpg_conversion
end type
type sle_boolean from singlelineedit within tabpg_conversion
end type
type cb_conversion from u_cb within tabpg_conversion
end type
type lb_conversion from listbox within tabpg_conversion
end type
type tabpg_conversion from userobject within tab_1
st_conversion st_conversion
st_number st_number
sle_number sle_number
st_boolean st_boolean
sle_boolean sle_boolean
cb_conversion cb_conversion
lb_conversion lb_conversion
end type
type tabpg_color from userobject within tab_1
end type
type st_color from statictext within tabpg_color
end type
type st_named from statictext within tabpg_color
end type
type ddlb_named from dropdownlistbox within tabpg_color
end type
type st_red from statictext within tabpg_color
end type
type sle_red from singlelineedit within tabpg_color
end type
type st_green from statictext within tabpg_color
end type
type sle_green from singlelineedit within tabpg_color
end type
type st_blue from statictext within tabpg_color
end type
type sle_blue from singlelineedit within tabpg_color
end type
type st_swatch from statictext within tabpg_color
end type
type cb_color from u_cb within tabpg_color
end type
type lb_color from listbox within tabpg_color
end type
type tabpg_color from userobject within tab_1
st_color st_color
st_named st_named
ddlb_named ddlb_named
st_red st_red
sle_red sle_red
st_green st_green
sle_green sle_green
st_blue st_blue
sle_blue sle_blue
st_swatch st_swatch
cb_color cb_color
lb_color lb_color
end type
type tabpg_platform from userobject within tab_1
end type
type st_platform from statictext within tabpg_platform
end type
type cb_platform from u_cb within tabpg_platform
end type
type lb_platform from listbox within tabpg_platform
end type
type tabpg_platform from userobject within tab_1
st_platform st_platform
cb_platform cb_platform
lb_platform lb_platform
end type
type tabpg_collections from userobject within tab_1
end type
type st_collections from statictext within tabpg_collections
end type
type st_items from statictext within tabpg_collections
end type
type sle_items from singlelineedit within tabpg_collections
end type
type cb_collections from u_cb within tabpg_collections
end type
type lb_collections from listbox within tabpg_collections
end type
type tabpg_collections from userobject within tab_1
st_collections st_collections
st_items st_items
sle_items sle_items
cb_collections cb_collections
lb_collections lb_collections
end type
type tab_1 from tab within w_utilityserv
tabpg_string tabpg_string
tabpg_numerical tabpg_numerical
tabpg_conversion tabpg_conversion
tabpg_color tabpg_color
tabpg_platform tabpg_platform
tabpg_collections tabpg_collections
end type
type cb_close from u_cb within w_utilityserv
end type
end forward

global type w_utilityserv from w_main
integer x = 594
integer y = 300
integer width = 2551
integer height = 1940
string title = "PFC Example - Utility Services"
st_intro st_intro
tab_1 tab_1
cb_close cb_close
end type
global w_utilityserv w_utilityserv

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	Shows the results for the initial input on every tab.
//
//////////////////////////////////////////////////////////////////////////////
tab_1.tabpg_color.ddlb_named.SelectItem(1)
tab_1.tabpg_string.cb_string.event clicked()
tab_1.tabpg_numerical.cb_numerical.event clicked()
tab_1.tabpg_conversion.cb_conversion.event clicked()
tab_1.tabpg_color.cb_color.event clicked()
tab_1.tabpg_platform.cb_platform.event clicked()
tab_1.tabpg_collections.cb_collections.event clicked()
end event

on w_utilityserv.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.tab_1=create tab_1
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.tab_1
this.Control[iCurrent+3]=this.cb_close
end on

on w_utilityserv.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.tab_1)
destroy(this.cb_close)
end on

type st_intro from statictext within w_utilityserv
integer x = 37
integer y = 32
integer width = 2459
integer height = 200
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "PFC's utility objects are autoinstantiated (the platform service is created with f_SetPlatform): declare a variable and call its functions.  Each tab works with some of them; change the input and click the button to see the results.  The date and time functions (n_cst_datetime) have an example of their own, Date / Time Service."
boolean focusrectangle = false
end type

type tab_1 from tab within w_utilityserv
integer x = 37
integer y = 256
integer width = 2459
integer height = 1400
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long backcolor = 67108864
boolean raggedright = true
boolean focusonbuttondown = true
integer selectedtab = 1
tabpg_string tabpg_string
tabpg_numerical tabpg_numerical
tabpg_conversion tabpg_conversion
tabpg_color tabpg_color
tabpg_platform tabpg_platform
tabpg_collections tabpg_collections
end type

on tab_1.create
this.tabpg_string=create tabpg_string
this.tabpg_numerical=create tabpg_numerical
this.tabpg_conversion=create tabpg_conversion
this.tabpg_color=create tabpg_color
this.tabpg_platform=create tabpg_platform
this.tabpg_collections=create tabpg_collections
this.Control[]={this.tabpg_string,&
this.tabpg_numerical,&
this.tabpg_conversion,&
this.tabpg_color,&
this.tabpg_platform,&
this.tabpg_collections}
end on

on tab_1.destroy
destroy(this.tabpg_string)
destroy(this.tabpg_numerical)
destroy(this.tabpg_conversion)
destroy(this.tabpg_color)
destroy(this.tabpg_platform)
destroy(this.tabpg_collections)
end on

type tabpg_string from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1284
long backcolor = 67108864
string text = "String"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_string st_string
st_text st_text
sle_text sle_text
st_find st_find
sle_find sle_find
st_replace st_replace
sle_replace sle_replace
cb_string cb_string
lb_string lb_string
end type

on tabpg_string.create
this.st_string=create st_string
this.st_text=create st_text
this.sle_text=create sle_text
this.st_find=create st_find
this.sle_find=create sle_find
this.st_replace=create st_replace
this.sle_replace=create sle_replace
this.cb_string=create cb_string
this.lb_string=create lb_string
this.Control[]={this.st_string,&
this.st_text,&
this.sle_text,&
this.st_find,&
this.sle_find,&
this.st_replace,&
this.sle_replace,&
this.cb_string,&
this.lb_string}
end on

on tabpg_string.destroy
destroy(this.st_string)
destroy(this.st_text)
destroy(this.sle_text)
destroy(this.st_find)
destroy(this.sle_find)
destroy(this.st_replace)
destroy(this.sle_replace)
destroy(this.cb_string)
destroy(this.lb_string)
end on

type st_string from statictext within tabpg_string
integer x = 32
integer y = 24
integer width = 2350
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "n_cst_string searches, replaces, parses, trims, pads and tests strings.  Type some text, a string to find and one to replace it with."
boolean focusrectangle = false
end type

type st_text from statictext within tabpg_string
integer x = 32
integer y = 252
integer width = 251
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Text:"
boolean focusrectangle = false
end type

type sle_text from singlelineedit within tabpg_string
integer x = 297
integer y = 240
integer width = 2085
integer height = 84
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "The quick brown fox jumps over the lazy dog, then the dog sleeps."
borderstyle borderstyle = stylelowered!
end type

type st_find from statictext within tabpg_string
integer x = 32
integer y = 352
integer width = 251
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Find:"
boolean focusrectangle = false
end type

type sle_find from singlelineedit within tabpg_string
integer x = 297
integer y = 340
integer width = 366
integer height = 84
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "the"
borderstyle borderstyle = stylelowered!
end type

type st_replace from statictext within tabpg_string
integer x = 699
integer y = 352
integer width = 375
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Replace with:"
boolean focusrectangle = false
end type

type sle_replace from singlelineedit within tabpg_string
integer x = 1083
integer y = 340
integer width = 366
integer height = 84
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "a"
borderstyle borderstyle = stylelowered!
end type

type cb_string from u_cb within tabpg_string
integer x = 1824
integer y = 336
integer width = 558
integer taborder = 40
string text = "&Show the Results"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;n_cst_string	lnv_string
n_cst_conversion	lnv_conv
string	ls_text, ls_find, ls_words[], ls_joined
long	ll_words

ls_text = sle_text.Text
ls_find = sle_find.Text
lb_string.Reset()
lb_string.AddItem("of_WordCap:  " + lnv_string.of_WordCap(ls_text))
lb_string.AddItem("of_GlobalReplace (ignoring case):  " + lnv_string.of_GlobalReplace(ls_text, ls_find, sle_replace.Text, True))
lb_string.AddItem("of_CountOccurrences (ignoring case):  " + String(lnv_string.of_CountOccurrences(ls_text, ls_find, True)))
lb_string.AddItem("of_LastPos:  " + String(lnv_string.of_LastPos(ls_text, ls_find)))

// of_ParseToArray splits the text into an array; of_ArrayToString joins it again
ll_words = lnv_string.of_ParseToArray(ls_text, " ", ls_words)
lnv_string.of_ArrayToString(ls_words, " | ", ls_joined)
lb_string.AddItem("of_ParseToArray (on spaces), of_ArrayToString:  " + String(ll_words) + " words:  " + ls_joined)

lb_string.AddItem("of_RemoveWhiteSpace:  " + lnv_string.of_RemoveWhiteSpace(ls_text))
lb_string.AddItem("of_RemovePunctuation:  " + lnv_string.of_RemovePunctuation(ls_text))
lb_string.AddItem("of_PadLeft (to 12):  [" + lnv_string.of_PadLeft(ls_find, 12) + "]")
lb_string.AddItem("of_Quote:  " + lnv_string.of_Quote(ls_find))
lb_string.AddItem("of_URLEncode:  " + lnv_string.of_URLEncode(ls_text))
lb_string.AddItem("of_GetKeyValue (~"database~" in ~"server=srv1;database=demo~"):  " + lnv_string.of_GetKeyValue("server=srv1;database=demo", "database", ";"))
lb_string.AddItem("of_IsAlpha:  " + lnv_conv.of_String(lnv_string.of_IsAlpha(ls_text)) + &
	",  of_IsAlphaNum:  " + lnv_conv.of_String(lnv_string.of_IsAlphaNum(ls_text)) + &
	",  of_IsLower:  " + lnv_conv.of_String(lnv_string.of_IsLower(ls_text)) + &
	",  of_IsUpper:  " + lnv_conv.of_String(lnv_string.of_IsUpper(ls_text)))
lb_string.AddItem("of_IsWellFormedEmailAddress:  " + lnv_conv.of_String(lnv_string.of_IsWellFormedEmailAddress(ls_text)))
end event

type lb_string from listbox within tabpg_string
integer x = 32
integer y = 464
integer width = 2350
integer height = 772
integer taborder = 50
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

type tabpg_numerical from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1284
long backcolor = 67108864
string text = "Numbers"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_numerical st_numerical
st_value1 st_value1
sle_value1 sle_value1
st_value2 st_value2
sle_value2 sle_value2
st_base st_base
sle_base sle_base
cb_numerical cb_numerical
lb_numerical lb_numerical
end type

on tabpg_numerical.create
this.st_numerical=create st_numerical
this.st_value1=create st_value1
this.sle_value1=create sle_value1
this.st_value2=create st_value2
this.sle_value2=create sle_value2
this.st_base=create st_base
this.sle_base=create sle_base
this.cb_numerical=create cb_numerical
this.lb_numerical=create lb_numerical
this.Control[]={this.st_numerical,&
this.st_value1,&
this.sle_value1,&
this.st_value2,&
this.sle_value2,&
this.st_base,&
this.sle_base,&
this.cb_numerical,&
this.lb_numerical}
end on

on tabpg_numerical.destroy
destroy(this.st_numerical)
destroy(this.st_value1)
destroy(this.sle_value1)
destroy(this.st_value2)
destroy(this.sle_value2)
destroy(this.st_base)
destroy(this.sle_base)
destroy(this.cb_numerical)
destroy(this.lb_numerical)
end on

type st_numerical from statictext within tabpg_numerical
integer x = 32
integer y = 24
integer width = 2350
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "n_cst_numerical shows whole numbers in binary, octal, hexadecimal or another base, reads binary numbers back, and gets, sets and combines bits."
boolean focusrectangle = false
end type

type st_value1 from statictext within tabpg_numerical
integer x = 32
integer y = 252
integer width = 251
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Number:"
boolean focusrectangle = false
end type

type sle_value1 from singlelineedit within tabpg_numerical
integer x = 297
integer y = 240
integer width = 366
integer height = 84
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "202"
borderstyle borderstyle = stylelowered!
end type

type st_value2 from statictext within tabpg_numerical
integer x = 699
integer y = 252
integer width = 375
integer height = 112
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Second number:"
boolean focusrectangle = false
end type

type sle_value2 from singlelineedit within tabpg_numerical
integer x = 1083
integer y = 240
integer width = 366
integer height = 84
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "15"
borderstyle borderstyle = stylelowered!
end type

type st_base from statictext within tabpg_numerical
integer x = 32
integer y = 352
integer width = 251
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Base:"
boolean focusrectangle = false
end type

type sle_base from singlelineedit within tabpg_numerical
integer x = 297
integer y = 340
integer width = 366
integer height = 84
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "5"
borderstyle borderstyle = stylelowered!
end type

type cb_numerical from u_cb within tabpg_numerical
integer x = 1824
integer y = 336
integer width = 558
integer taborder = 40
string text = "&Show the Results"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;n_cst_numerical	lnv_num
n_cst_conversion	lnv_conv
long	ll_value1, ll_value2
string	ls_binary

lb_numerical.Reset()
If Not IsNumber(sle_value1.Text) Or Not IsNumber(sle_value2.Text) Or Not IsNumber(sle_base.Text) Then
	lb_numerical.AddItem("Enter two whole numbers, and a base from 2 to 16.")
	Return
End If
ll_value1 = Long(sle_value1.Text)
ll_value2 = Long(sle_value2.Text)

ls_binary = lnv_num.of_Binary(ll_value1)
lb_numerical.AddItem("of_Binary:  " + ls_binary)
lb_numerical.AddItem("of_Decimal (the binary number back):  " + String(lnv_num.of_Decimal(ls_binary)))
lb_numerical.AddItem("of_Octal:  " + lnv_num.of_Octal(ll_value1))
lb_numerical.AddItem("of_Hex:  " + lnv_num.of_Hex(ll_value1))
lb_numerical.AddItem("of_NumberBaseString (base " + sle_base.Text + "):  " + lnv_num.of_NumberBaseString(ll_value1, Integer(sle_base.Text)))
lb_numerical.AddItem("of_GetBit (bit 1, the lowest):  " + lnv_conv.of_String(lnv_num.of_GetBit(ll_value1, 1)))
lb_numerical.AddItem("of_SetBit (bit 1 on):  " + String(lnv_num.of_SetBit(ll_value1, 1, True)))
lb_numerical.AddItem("of_BitwiseAnd (with the second number):  " + String(lnv_num.of_BitwiseAnd(ll_value1, ll_value2)) + &
	"  (binary " + lnv_num.of_Binary(lnv_num.of_BitwiseAnd(ll_value1, ll_value2)) + ")")
lb_numerical.AddItem("of_BitwiseOr:  " + String(lnv_num.of_BitwiseOr(ll_value1, ll_value2)) + &
	"  (binary " + lnv_num.of_Binary(lnv_num.of_BitwiseOr(ll_value1, ll_value2)) + ")")
lb_numerical.AddItem("of_BitwiseXor:  " + String(lnv_num.of_BitwiseXor(ll_value1, ll_value2)) + &
	"  (binary " + lnv_num.of_Binary(lnv_num.of_BitwiseXor(ll_value1, ll_value2)) + ")")
lb_numerical.AddItem("of_BitwiseNot:  " + String(lnv_num.of_BitwiseNot(ll_value1)))
end event

type lb_numerical from listbox within tabpg_numerical
integer x = 32
integer y = 464
integer width = 2350
integer height = 772
integer taborder = 50
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

type tabpg_conversion from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1284
long backcolor = 67108864
string text = "Conversions"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_conversion st_conversion
st_number st_number
sle_number sle_number
st_boolean st_boolean
sle_boolean sle_boolean
cb_conversion cb_conversion
lb_conversion lb_conversion
end type

on tabpg_conversion.create
this.st_conversion=create st_conversion
this.st_number=create st_number
this.sle_number=create sle_number
this.st_boolean=create st_boolean
this.sle_boolean=create sle_boolean
this.cb_conversion=create cb_conversion
this.lb_conversion=create lb_conversion
this.Control[]={this.st_conversion,&
this.st_number,&
this.sle_number,&
this.st_boolean,&
this.sle_boolean,&
this.cb_conversion,&
this.lb_conversion}
end on

on tabpg_conversion.destroy
destroy(this.st_conversion)
destroy(this.st_number)
destroy(this.sle_number)
destroy(this.st_boolean)
destroy(this.sle_boolean)
destroy(this.cb_conversion)
destroy(this.lb_conversion)
end on

type st_conversion from statictext within tabpg_conversion
integer x = 32
integer y = 24
integer width = 2350
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "n_cst_measureconversion converts temperatures, distances, weights and pressures; n_cst_pbunitconversion converts PowerBuilder units to inches, centimeters and pixels; and n_cst_conversion converts between strings, booleans and enumerated values."
boolean focusrectangle = false
end type

type st_number from statictext within tabpg_conversion
integer x = 32
integer y = 252
integer width = 251
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Number:"
boolean focusrectangle = false
end type

type sle_number from singlelineedit within tabpg_conversion
integer x = 297
integer y = 240
integer width = 366
integer height = 84
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "100"
borderstyle borderstyle = stylelowered!
end type

type st_boolean from statictext within tabpg_conversion
integer x = 699
integer y = 252
integer width = 375
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Yes or no:"
boolean focusrectangle = false
end type

type sle_boolean from singlelineedit within tabpg_conversion
integer x = 1083
integer y = 240
integer width = 366
integer height = 84
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "yes"
borderstyle borderstyle = stylelowered!
end type

type cb_conversion from u_cb within tabpg_conversion
integer x = 1824
integer y = 236
integer width = 558
integer taborder = 30
string text = "&Show the Results"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;n_cst_measureconversion	lnv_measure
n_cst_pbunitconversion	lnv_units
n_cst_conversion	lnv_conv
double	ldbl_value
boolean	lb_value
windowstate	le_state

lb_conversion.Reset()
If Not IsNumber(sle_number.Text) Then
	lb_conversion.AddItem("Enter a number.")
	Return
End If
ldbl_value = Double(sle_number.Text)

lb_conversion.AddItem("of_Temperature_CelsiusToFahrenheit:  " + String(Round(lnv_measure.of_Temperature_CelsiusToFahrenheit(ldbl_value), 2)))
lb_conversion.AddItem("of_Temperature_FahrenheitToCelsius:  " + String(Round(lnv_measure.of_Temperature_FahrenheitToCelsius(ldbl_value), 2)))
lb_conversion.AddItem("of_Distance_KilometersToMiles:  " + String(Round(lnv_measure.of_Distance_KilometersToMiles(ldbl_value), 2)))
lb_conversion.AddItem("of_Distance_MilesToKilometers:  " + String(Round(lnv_measure.of_Distance_MilesToKilometers(ldbl_value), 2)))
lb_conversion.AddItem("of_Distance_InchesToCentimeters:  " + String(Round(lnv_measure.of_Distance_InchesToCentimeters(ldbl_value), 2)))
lb_conversion.AddItem("of_Weight_KilogramsToPounds:  " + String(Round(lnv_measure.of_Weight_KilogramsToPounds(ldbl_value), 2)))
lb_conversion.AddItem("of_Weight_PoundsToKilograms:  " + String(Round(lnv_measure.of_Weight_PoundsToKilograms(ldbl_value), 2)))
lb_conversion.AddItem("of_Pressure_AtmToPSI:  " + String(Round(lnv_measure.of_Pressure_AtmToPSI(ldbl_value), 2)))

// PowerBuilder units depend on the system font, so the results vary with the display
lb_conversion.AddItem("of_PBUnitsToInchesX:  " + String(Round(lnv_units.of_PBUnitsToInchesX(Long(ldbl_value)), 2)))
lb_conversion.AddItem("of_PBUnitsToCentimetersX:  " + String(Round(lnv_units.of_PBUnitsToCentimetersX(Long(ldbl_value)), 2)))
lb_conversion.AddItem("of_ConvertUnitsX (PB units to pixels):  " + String(lnv_units.of_ConvertUnitsX(ldbl_value, lnv_units.PBUNITS, lnv_units.PIXELS)))
lb_conversion.AddItem("of_ConvertUnitsX (pixels to PB units):  " + String(lnv_units.of_ConvertUnitsX(ldbl_value, lnv_units.PIXELS, lnv_units.PBUNITS)))

// of_Boolean reads true/false, yes/no, y/n, t/f, on/off and 1/0; anything else is null
lb_value = lnv_conv.of_Boolean(sle_boolean.Text)
If IsNull(lb_value) Then
	lb_conversion.AddItem("of_Boolean:  null (not a boolean value)")
Else
	lb_conversion.AddItem("of_Boolean:  " + lnv_conv.of_String(lb_value) + ",  of_String (as 1 or 0):  " + lnv_conv.of_String(lb_value, "ZEROONE"))
End If

// of_String names an enumerated value, and functions like of_WindowState read one back
lb_conversion.AddItem("of_String (enumerated values):  this list's BorderStyle is " + lnv_conv.of_String(lb_conversion.BorderStyle) + &
	",  the label's Alignment is " + lnv_conv.of_String(st_number.Alignment))
lnv_conv.of_WindowState("maximized!", le_state)
lb_conversion.AddItem("of_WindowState (~"maximized!~"), and back with of_String:  " + lnv_conv.of_String(le_state))
end event

type lb_conversion from listbox within tabpg_conversion
integer x = 32
integer y = 464
integer width = 2350
integer height = 772
integer taborder = 40
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

type tabpg_color from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1284
long backcolor = 67108864
string text = "Colors"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_color st_color
st_named st_named
ddlb_named ddlb_named
st_red st_red
sle_red sle_red
st_green st_green
sle_green sle_green
st_blue st_blue
sle_blue sle_blue
st_swatch st_swatch
cb_color cb_color
lb_color lb_color
end type

on tabpg_color.create
this.st_color=create st_color
this.st_named=create st_named
this.ddlb_named=create ddlb_named
this.st_red=create st_red
this.sle_red=create sle_red
this.st_green=create st_green
this.sle_green=create sle_green
this.st_blue=create st_blue
this.sle_blue=create sle_blue
this.st_swatch=create st_swatch
this.cb_color=create cb_color
this.lb_color=create lb_color
this.Control[]={this.st_color,&
this.st_named,&
this.ddlb_named,&
this.st_red,&
this.sle_red,&
this.st_green,&
this.sle_green,&
this.st_blue,&
this.sle_blue,&
this.st_swatch,&
this.cb_color,&
this.lb_color}
end on

on tabpg_color.destroy
destroy(this.st_color)
destroy(this.st_named)
destroy(this.ddlb_named)
destroy(this.st_red)
destroy(this.sle_red)
destroy(this.st_green)
destroy(this.sle_green)
destroy(this.st_blue)
destroy(this.sle_blue)
destroy(this.st_swatch)
destroy(this.cb_color)
destroy(this.lb_color)
end on

type st_color from statictext within tabpg_color
integer x = 32
integer y = 24
integer width = 2350
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "n_cst_color names the standard and Windows system colors and splits a color into red, green and blue; n_cst_colorconv converts colors between RGB, HSL, HSV, CMYK and other color models."
boolean focusrectangle = false
end type

type st_named from statictext within tabpg_color
integer x = 32
integer y = 252
integer width = 251
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Color:"
boolean focusrectangle = false
end type

type ddlb_named from dropdownlistbox within tabpg_color
integer x = 297
integer y = 240
integer width = 1152
integer height = 700
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean sorted = false
boolean vscrollbar = true
string item[] = {"Orange","Navy","Teal","Maroon","Sky","Mint","Cream","Yellow Sticky","Button Face (a system color)","Highlight (a system color)","Window Text (a system color)"}
borderstyle borderstyle = stylelowered!
end type

event selectionchanged;// The color's value, split into red, green and blue (of_UnRGB)
n_cst_color	lnv_color
long	ll_color
integer	li_red, li_green, li_blue

Choose Case index
	Case 1
		ll_color = lnv_color.of_Orange()
	Case 2
		ll_color = lnv_color.of_Navy()
	Case 3
		ll_color = lnv_color.of_Teal()
	Case 4
		ll_color = lnv_color.of_Maroon()
	Case 5
		ll_color = lnv_color.of_Sky()
	Case 6
		ll_color = lnv_color.of_Mint()
	Case 7
		ll_color = lnv_color.of_Cream()
	Case 8
		ll_color = lnv_color.of_YellowSticky()
	Case 9
		ll_color = lnv_color.of_ButtonFace()
	Case 10
		ll_color = lnv_color.of_Hilight()
	Case 11
		ll_color = lnv_color.of_WindowText()
	Case Else
		Return
End Choose
lnv_color.of_UnRGB(ll_color, li_red, li_green, li_blue)
sle_red.Text = String(li_red)
sle_green.Text = String(li_green)
sle_blue.Text = String(li_blue)
cb_color.event clicked()
end event

type st_red from statictext within tabpg_color
integer x = 32
integer y = 352
integer width = 251
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Red:"
boolean focusrectangle = false
end type

type sle_red from singlelineedit within tabpg_color
integer x = 297
integer y = 340
integer width = 201
integer height = 84
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "255"
borderstyle borderstyle = stylelowered!
end type

type st_green from statictext within tabpg_color
integer x = 530
integer y = 352
integer width = 174
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Green:"
boolean focusrectangle = false
end type

type sle_green from singlelineedit within tabpg_color
integer x = 709
integer y = 340
integer width = 201
integer height = 84
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "165"
borderstyle borderstyle = stylelowered!
end type

type st_blue from statictext within tabpg_color
integer x = 942
integer y = 352
integer width = 142
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Blue:"
boolean focusrectangle = false
end type

type sle_blue from singlelineedit within tabpg_color
integer x = 1083
integer y = 340
integer width = 201
integer height = 84
integer taborder = 40
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "0"
borderstyle borderstyle = stylelowered!
end type

type st_swatch from statictext within tabpg_color
integer x = 1495
integer y = 236
integer width = 293
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
boolean border = true
borderstyle borderstyle = styleshadowbox!
boolean focusrectangle = false
end type

type cb_color from u_cb within tabpg_color
integer x = 1824
integer y = 336
integer width = 558
integer taborder = 50
string text = "&Show the Results"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;n_cst_color	lnv_color
n_cst_colorconv	lnv_colorconv
s_rgb_colorattrib	lstr_rgb
s_hsl_colorattrib	lstr_hsl
s_hsv_colorattrib	lstr_hsv
s_cmy_colorattrib	lstr_cmy
s_cmyk_colorattrib	lstr_cmyk
s_xyz_colorattrib	lstr_xyz
long	ll_color

lb_color.Reset()
If Not IsNumber(sle_red.Text) Or Not IsNumber(sle_green.Text) Or Not IsNumber(sle_blue.Text) Then
	lb_color.AddItem("Enter red, green and blue values from 0 to 255.")
	Return
End If
If Integer(sle_red.Text) < 0 Or Integer(sle_red.Text) > 255 Or Integer(sle_green.Text) < 0 Or Integer(sle_green.Text) > 255 &
		Or Integer(sle_blue.Text) < 0 Or Integer(sle_blue.Text) > 255 Then
	lb_color.AddItem("Enter red, green and blue values from 0 to 255.")
	Return
End If
lstr_rgb.r = Byte(Integer(sle_red.Text))
lstr_rgb.g = Byte(Integer(sle_green.Text))
lstr_rgb.b = Byte(Integer(sle_blue.Text))

ll_color = lnv_colorconv.of_RGB(lstr_rgb)
st_swatch.BackColor = ll_color
lb_color.AddItem("of_RGB (the PowerBuilder color value):  " + String(ll_color))
lb_color.AddItem("of_Convert_ColorToRGBString:  " + lnv_color.of_Convert_ColorToRGBString(ll_color, ","))

// The color models' values run from 0 to 1
lnv_colorconv.of_RGB2HSL(lstr_rgb, lstr_hsl)
lb_color.AddItem("of_RGB2HSL:  hue " + String(lstr_hsl.h * 360, "0") + " degrees, saturation " + String(lstr_hsl.s * 100, "0") + &
	"%, lightness " + String(lstr_hsl.l * 100, "0") + "%")
lnv_colorconv.of_RGB2HSV(lstr_rgb, lstr_hsv)
lb_color.AddItem("of_RGB2HSV:  hue " + String(lstr_hsv.h * 360, "0") + " degrees, saturation " + String(lstr_hsv.s * 100, "0") + &
	"%, value " + String(lstr_hsv.v * 100, "0") + "%")
lnv_colorconv.of_RGB2CMY(lstr_rgb, lstr_cmy)
lnv_colorconv.of_CMY2CMYK(lstr_cmy, lstr_cmyk)
lb_color.AddItem("of_RGB2CMY, of_CMY2CMYK:  cyan " + String(lstr_cmyk.c * 100, "0") + "%, magenta " + String(lstr_cmyk.m * 100, "0") + &
	"%, yellow " + String(lstr_cmyk.y * 100, "0") + "%, black " + String(lstr_cmyk.k * 100, "0") + "%")
lnv_colorconv.of_RGB2XYZ(lstr_rgb, lstr_xyz)
lb_color.AddItem("of_RGB2XYZ:  x " + String(lstr_xyz.x, "0.00") + ", y " + String(lstr_xyz.y, "0.00") + ", z " + String(lstr_xyz.z, "0.00"))
end event

type lb_color from listbox within tabpg_color
integer x = 32
integer y = 464
integer width = 2350
integer height = 772
integer taborder = 60
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

type tabpg_platform from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1284
long backcolor = 67108864
string text = "Platform"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_platform st_platform
cb_platform cb_platform
lb_platform lb_platform
end type

on tabpg_platform.create
this.st_platform=create st_platform
this.cb_platform=create cb_platform
this.lb_platform=create lb_platform
this.Control[]={this.st_platform,&
this.cb_platform,&
this.lb_platform}
end on

on tabpg_platform.destroy
destroy(this.st_platform)
destroy(this.cb_platform)
destroy(this.lb_platform)
end on

type st_platform from statictext within tabpg_platform
integer x = 32
integer y = 24
integer width = 2350
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "The platform service (n_cst_platform, created with f_SetPlatform) calls the Windows API for information about the computer, and n_cst_environment describes the operating system, screen and PowerBuilder run time."
boolean focusrectangle = false
end type

type cb_platform from u_cb within tabpg_platform
integer x = 1824
integer y = 236
integer width = 558
integer taborder = 10
string text = "&Refresh"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;n_cst_platform	lnv_platform
n_cst_environment	lnv_env
string	ls_names[], ls_values[]
long	ll_count, ll_i

lb_platform.Reset()
f_SetPlatform(lnv_platform, True)
lb_platform.AddItem("of_GetComputerName:  " + lnv_platform.of_GetComputerName())
lb_platform.AddItem("of_GetUserID:  " + lnv_platform.of_GetUserID())
lb_platform.AddItem("of_GetWindowsDirectory:  " + lnv_platform.of_GetWindowsDirectory())
lb_platform.AddItem("of_GetSystemDirectory:  " + lnv_platform.of_GetSystemDirectory())
lb_platform.AddItem("of_GetDPIX, of_GetDPIY:  " + String(lnv_platform.of_GetDPIX()) + " x " + String(lnv_platform.of_GetDPIY()) + " dots per inch")
lb_platform.AddItem("of_GetPhysicalMemory:  " + String(lnv_platform.of_GetPhysicalMemory() / 1048576, "#,##0") + " MB")
lb_platform.AddItem("of_GetFreeMemory:  " + String(lnv_platform.of_GetFreeMemory() / 1048576, "#,##0") + " MB")
f_SetPlatform(lnv_platform, False)

lb_platform.AddItem("")
lb_platform.AddItem("n_cst_environment, of_ListProperties:")
ll_count = lnv_env.of_ListProperties(ls_names, ls_values)
For ll_i = 1 To ll_count
	lb_platform.AddItem("      " + ls_names[ll_i] + ":  " + ls_values[ll_i])
Next
end event

type lb_platform from listbox within tabpg_platform
integer x = 32
integer y = 464
integer width = 2350
integer height = 772
integer taborder = 20
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

type tabpg_collections from userobject within tab_1
integer x = 18
integer y = 100
integer width = 2422
integer height = 1284
long backcolor = 67108864
string text = "Collections"
long tabtextcolor = 33554432
long tabbackcolor = 67108864
long picturemaskcolor = 536870912
st_collections st_collections
st_items st_items
sle_items sle_items
cb_collections cb_collections
lb_collections lb_collections
end type

on tabpg_collections.create
this.st_collections=create st_collections
this.st_items=create st_items
this.sle_items=create sle_items
this.cb_collections=create cb_collections
this.lb_collections=create lb_collections
this.Control[]={this.st_collections,&
this.st_items,&
this.sle_items,&
this.cb_collections,&
this.lb_collections}
end on

on tabpg_collections.destroy
destroy(this.st_collections)
destroy(this.st_items)
destroy(this.sle_items)
destroy(this.cb_collections)
destroy(this.lb_collections)
end on

type st_collections from statictext within tabpg_collections
integer x = 32
integer y = 24
integer width = 2350
integer height = 192
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "The collections hold nodes, each with a key and data: n_cst_stack (last in, first out), n_cst_queue (first in, first out), n_cst_list (a linked list, which can keep its nodes sorted) and n_cst_tree (a balanced binary tree).  Type some items to add to each of them."
boolean focusrectangle = false
end type

type st_items from statictext within tabpg_collections
integer x = 32
integer y = 252
integer width = 251
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "&Items:"
boolean focusrectangle = false
end type

type sle_items from singlelineedit within tabpg_collections
integer x = 297
integer y = 240
integer width = 1491
integer height = 84
integer taborder = 10
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
string text = "pear, apple, fig, cherry, apple, banana"
borderstyle borderstyle = stylelowered!
end type

type cb_collections from u_cb within tabpg_collections
integer x = 1824
integer y = 236
integer width = 558
integer taborder = 20
string text = "&Add to Each"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;n_cst_string	lnv_string
n_cst_stack	lnv_stack
n_cst_queue	lnv_queue
n_cst_list	lnv_list, lnv_uniquelist
n_cst_tree	lnv_tree
n_cst_linkedlistnode	lnv_node, lnv_nodes[], lnv_empty[]
n_cst_treenode	lnv_treenode, lnv_treenodes[], lnv_found
string	ls_items[], ls_order
long	ll_count, ll_i, ll_nodes, ll_rejected
any	la_key

lb_collections.Reset()
ll_count = lnv_string.of_ParseToArray(sle_items.Text, ",", ls_items)
For ll_i = 1 To ll_count
	ls_items[ll_i] = Trim(ls_items[ll_i])
Next
If ll_count = 0 Then Return

// A stack gives its nodes back last first (of_Push, of_Pop)
For ll_i = 1 To ll_count
	lnv_node = Create n_cst_linkedlistnode
	lnv_node.of_SetKey(ls_items[ll_i])
	lnv_stack.of_Push(lnv_node)
Next
ls_order = ""
Do While lnv_stack.of_Pop(lnv_node) = 1
	lnv_node.of_GetKey(la_key)
	ls_order += ", " + String(la_key)
	Destroy lnv_node
Loop
lb_collections.AddItem("n_cst_stack, of_Push then of_Pop:  " + Mid(ls_order, 3))

// A queue gives them back in the order they came (of_Put, of_Get)
For ll_i = 1 To ll_count
	lnv_node = Create n_cst_linkedlistnode
	lnv_node.of_SetKey(ls_items[ll_i])
	lnv_queue.of_Put(lnv_node)
Next
ls_order = ""
Do While lnv_queue.of_Get(lnv_node) = 1
	lnv_node.of_GetKey(la_key)
	ls_order += ", " + String(la_key)
	Destroy lnv_node
Loop
lb_collections.AddItem("n_cst_queue, of_Put then of_Get:  " + Mid(ls_order, 3))

// A sorted list puts each node in order of its key (of_SetSorted, of_Add, of_Get)
lnv_list.of_SetSorted(True)
For ll_i = 1 To ll_count
	lnv_node = Create n_cst_linkedlistnode
	lnv_node.of_SetKey(ls_items[ll_i])
	lnv_list.of_Add(lnv_node)
Next
ll_nodes = lnv_list.of_Get(lnv_nodes)
ls_order = ""
For ll_i = 1 To ll_nodes
	lnv_nodes[ll_i].of_GetKey(la_key)
	ls_order += ", " + String(la_key)
Next
lnv_list.of_Destroy()
lb_collections.AddItem("n_cst_list, sorted (of_SetSorted):  " + Mid(ls_order, 3))

// Without duplicates, of_Add rejects a node whose key is already in the list
lnv_uniquelist.of_SetSorted(True)
lnv_uniquelist.of_SetDuplicatesAllowed(False)
ll_rejected = 0
For ll_i = 1 To ll_count
	lnv_node = Create n_cst_linkedlistnode
	lnv_node.of_SetKey(ls_items[ll_i])
	If lnv_uniquelist.of_Add(lnv_node) <> 1 Then
		Destroy lnv_node
		ll_rejected++
	End If
Next
lnv_nodes = lnv_empty
ll_nodes = lnv_uniquelist.of_Get(lnv_nodes)
ls_order = ""
For ll_i = 1 To ll_nodes
	lnv_nodes[ll_i].of_GetKey(la_key)
	ls_order += ", " + String(la_key)
Next
lnv_uniquelist.of_Destroy()
lb_collections.AddItem("n_cst_list, sorted without duplicates (of_SetDuplicatesAllowed):  " + Mid(ls_order, 3) + &
	"  (" + String(ll_rejected) + " rejected)")

// The tree keeps itself balanced, and doesn't take duplicate keys (of_Create, of_Add, of_Get)
ll_rejected = 0
For ll_i = 1 To ll_count
	lnv_tree.of_Create(lnv_treenode)
	lnv_treenode.of_SetKey(ls_items[ll_i])
	If lnv_tree.of_Add(lnv_treenode) <> 1 Then
		Destroy lnv_treenode
		ll_rejected++
	End If
Next
ll_nodes = lnv_tree.of_Get(lnv_treenodes)
ls_order = ""
For ll_i = 1 To ll_nodes
	lnv_treenodes[ll_i].of_GetKey(la_key)
	ls_order += ", " + String(la_key)
Next
lb_collections.AddItem("n_cst_tree, of_Get:  " + Mid(ls_order, 3) + "  (" + String(lnv_tree.of_Count()) + " nodes, " + &
	String(ll_rejected) + " rejected)")
lnv_tree.of_GetRoot(lnv_found)
lnv_found.of_GetKey(la_key)
lb_collections.AddItem("n_cst_tree, of_GetRoot (the top node; the tree rebalances itself as nodes are added):  " + String(la_key))

// of_Find looks for a node with the same key
lnv_tree.of_Create(lnv_treenode)
lnv_treenode.of_SetKey(ls_items[ll_count])
If lnv_tree.of_Find(lnv_found, lnv_treenode) = 1 Then
	lb_collections.AddItem("n_cst_tree, of_Find (~"" + ls_items[ll_count] + "~"):  found")
Else
	lb_collections.AddItem("n_cst_tree, of_Find (~"" + ls_items[ll_count] + "~"):  not found")
End If
Destroy lnv_treenode
lnv_tree.of_Destroy()
end event

type lb_collections from listbox within tabpg_collections
integer x = 32
integer y = 464
integer width = 2350
integer height = 772
integer taborder = 30
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
boolean hscrollbar = true
boolean vscrollbar = true
boolean sorted = false
borderstyle borderstyle = stylelowered!
end type

type cb_close from u_cb within w_utilityserv
integer x = 2121
integer y = 1684
integer taborder = 20
string text = "Close"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
