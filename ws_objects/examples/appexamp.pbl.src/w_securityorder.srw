$PBExportHeader$w_securityorder.srw
$PBExportComments$Window secured by the Security Service example (w_securityserv)
forward
global type w_securityorder from w_response
end type
type st_who from statictext within w_securityorder
end type
type cb_new from u_cb within w_securityorder
end type
type cb_save from u_cb within w_securityorder
end type
type cb_delete from u_cb within w_securityorder
end type
type cb_approve from u_cb within w_securityorder
end type
type cb_print from u_cb within w_securityorder
end type
type st_restrict from statictext within w_securityorder
end type
type cb_enableall from u_cb within w_securityorder
end type
type cbx_apply from checkbox within w_securityorder
end type
type cb_close from u_cb within w_securityorder
end type
end forward

global type w_securityorder from w_response
integer width = 2240
integer height = 1064
string title = "Order"
st_who st_who
cb_new cb_new
cb_save cb_save
cb_delete cb_delete
cb_approve cb_approve
cb_print cb_print
st_restrict st_restrict
cb_enableall cb_enableall
cbx_apply cbx_apply
cb_close cb_close
end type
global w_securityorder w_securityorder

event pfc_preopen;call super::pfc_preopen;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			pfc_preopen
//
//	Description:	Applies the signed-in user's security settings to the window, as an
//						application does for each window it secures.  The opener passes who
//						signed in, to show.
//
//////////////////////////////////////////////////////////////////////////////
st_who.Text = Message.StringParm

If IsValid(gnv_app.inv_security) Then
	If Not gnv_app.inv_security.of_SetSecurity(this) Then
		MessageBox(this.Title, "Unable to set security.", StopSign!)
	End If
End If
end event

on w_securityorder.create
int iCurrent
call super::create
this.st_who=create st_who
this.cb_new=create cb_new
this.cb_save=create cb_save
this.cb_delete=create cb_delete
this.cb_approve=create cb_approve
this.cb_print=create cb_print
this.st_restrict=create st_restrict
this.cb_enableall=create cb_enableall
this.cbx_apply=create cbx_apply
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_who
this.Control[iCurrent+2]=this.cb_new
this.Control[iCurrent+3]=this.cb_save
this.Control[iCurrent+4]=this.cb_delete
this.Control[iCurrent+5]=this.cb_approve
this.Control[iCurrent+6]=this.cb_print
this.Control[iCurrent+7]=this.st_restrict
this.Control[iCurrent+8]=this.cb_enableall
this.Control[iCurrent+9]=this.cbx_apply
this.Control[iCurrent+10]=this.cb_close
end on

on w_securityorder.destroy
call super::destroy
destroy(this.st_who)
destroy(this.cb_new)
destroy(this.cb_save)
destroy(this.cb_delete)
destroy(this.cb_approve)
destroy(this.cb_print)
destroy(this.st_restrict)
destroy(this.cb_enableall)
destroy(this.cbx_apply)
destroy(this.cb_close)
end on

type st_who from statictext within w_securityorder
integer x = 37
integer y = 32
integer width = 2130
integer height = 140
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

type cb_new from u_cb within w_securityorder
integer x = 37
integer y = 212
integer width = 389
integer taborder = 10
string text = "&New"
end type

type cb_save from u_cb within w_securityorder
integer x = 462
integer y = 212
integer width = 389
integer taborder = 20
string text = "&Save"
end type

type cb_delete from u_cb within w_securityorder
integer x = 887
integer y = 212
integer width = 389
integer taborder = 30
string text = "&Delete"
end type

type cb_approve from u_cb within w_securityorder
integer x = 1312
integer y = 212
integer width = 389
integer taborder = 40
string text = "&Approve"
end type

type cb_print from u_cb within w_securityorder
integer x = 1737
integer y = 212
integer width = 389
integer taborder = 50
string text = "&Print"
end type

type st_restrict from statictext within w_securityorder
integer x = 37
integer y = 380
integer width = 2130
integer height = 260
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Code that sets Enabled or Visible after of_SetSecurity can undo the settings.  Enable All Buttons does what such code might do; with the box checked, it then calls of_ApplyRestrictions, which applies the Disable and Invisible settings again (and the default) but never enables or shows anything."
boolean focusrectangle = false
end type

type cb_enableall from u_cb within w_securityorder
integer x = 37
integer y = 676
integer width = 640
integer taborder = 60
string text = "&Enable All Buttons"
end type

event clicked;call super::clicked;// What application code might do, for example after refreshing the data
cb_new.Enabled = True
cb_save.Enabled = True
cb_delete.Enabled = True
cb_approve.Enabled = True
cb_print.Enabled = True
cb_new.Visible = True
cb_save.Visible = True
cb_delete.Visible = True
cb_approve.Visible = True
cb_print.Visible = True

If cbx_apply.Checked And IsValid(gnv_app.inv_security) Then
	gnv_app.inv_security.of_ApplyRestrictions(parent)
End If
end event

type cbx_apply from checkbox within w_securityorder
integer x = 709
integer y = 684
integer width = 1458
integer height = 76
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "MS Sans Serif"
long textcolor = 33554432
long backcolor = 67108864
string text = "Then call of_A&pplyRestrictions"
boolean checked = true
end type

type cb_close from u_cb within w_securityorder
integer x = 1792
integer y = 824
integer taborder = 70
string text = "Close"
boolean cancel = true
end type

event clicked;call super::clicked;Close(parent)
end event
