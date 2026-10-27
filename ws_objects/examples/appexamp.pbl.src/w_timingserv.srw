$PBExportHeader$w_timingserv.srw
$PBExportComments$Example of the timing services (n_tmg with n_cst_tmgsingle and n_cst_tmgmultiple)
forward
global type w_timingserv from w_main
end type
type st_intro from statictext within w_timingserv
end type
type gb_single from groupbox within w_timingserv
end type
type st_clock from statictext within w_timingserv
end type
type cb_single from u_cb within w_timingserv
end type
type gb_multiple from groupbox within w_timingserv
end type
type st_every2 from statictext within w_timingserv
end type
type st_every4 from statictext within w_timingserv
end type
type st_every8 from statictext within w_timingserv
end type
type st_interval from statictext within w_timingserv
end type
type cb_multiple from u_cb within w_timingserv
end type
type cb_unregister from u_cb within w_timingserv
end type
type cb_close from u_cb within w_timingserv
end type
end forward

global type w_timingserv from w_main
integer x = 594
integer y = 400
integer width = 2240
integer height = 1500
string title = "PFC Example - Timing Service"
event ue_tick ( )
event ue_every2 ( )
event ue_every4 ( )
event ue_every8 ( )
st_intro st_intro
gb_single gb_single
st_clock st_clock
cb_single cb_single
gb_multiple gb_multiple
st_every2 st_every2
st_every4 st_every4
st_every8 st_every8
st_interval st_interval
cb_multiple cb_multiple
cb_unregister cb_unregister
cb_close cb_close
end type
global w_timingserv w_timingserv

type variables
Protected:
// One timer for one object (the clock), and one shared by several (the counters)
n_tmg	itmg_single
n_tmg	itmg_multiple
long	il_count2, il_count4, il_count8
end variables

forward prototypes
protected subroutine of_showinterval ()
end prototypes

protected subroutine of_showinterval ();//////////////////////////////////////////////////////////////////////////////
//
//	Function:		of_ShowInterval
//
//	Access:			Protected
//
//	Arguments:		None
//
//	Description:	Shows the interval of the shared timer: the greatest common divisor
//						of the registered intervals (of_GetInterval).
//
//////////////////////////////////////////////////////////////////////////////
If itmg_multiple.inv_multiple.of_IsDisabled() Then
	st_interval.Text = "The shared timer is stopped"
Else
	st_interval.Text = "The shared timer runs every " + String(itmg_multiple.inv_multiple.of_GetInterval()) + &
		" seconds for " + String(itmg_multiple.inv_multiple.of_GetCount()) + " counters (of_GetInterval, of_GetCount)"
End If
end subroutine

event ue_tick();// Notified every second by the single-object service
st_clock.Text = String(Now(), "hh:mm:ss")
end event

event ue_every2();il_count2++
st_every2.Text = "Every 2 seconds: " + String(il_count2)
end event

event ue_every4();il_count4++
st_every4.Text = "Every 4 seconds: " + String(il_count4)
end event

event ue_every8();il_count8++
st_every8.Text = "Every 8 seconds: " + String(il_count8)
end event

event open;call super::open;//////////////////////////////////////////////////////////////////////////////
//
//	Event:			open
//
//	Description:	Creates the two timers with their services and registers the
//						window's events; registering starts a timer.
//
//////////////////////////////////////////////////////////////////////////////
itmg_single = Create n_tmg
itmg_single.of_SetSingle(True)
itmg_single.inv_single.of_Register(this, "ue_tick", 1, itmg_single.inv_single.POSTEVENT)
this.event ue_tick()

itmg_multiple = Create n_tmg
itmg_multiple.of_SetMultiple(True)
itmg_multiple.inv_multiple.of_Register(this, "ue_every2", 2, itmg_multiple.inv_multiple.POSTEVENT)
itmg_multiple.inv_multiple.of_Register(this, "ue_every4", 4, itmg_multiple.inv_multiple.POSTEVENT)
itmg_multiple.inv_multiple.of_Register(this, "ue_every8", 8, itmg_multiple.inv_multiple.POSTEVENT)
of_ShowInterval()
end event

event close;call super::close;// Stop the timers before the window goes away
If IsValid(itmg_single) Then
	itmg_single.inv_single.of_Unregister()
	Destroy itmg_single
End If
If IsValid(itmg_multiple) Then
	itmg_multiple.inv_multiple.of_Unregister()
	Destroy itmg_multiple
End If
end event

on w_timingserv.create
int iCurrent
call super::create
this.st_intro=create st_intro
this.gb_single=create gb_single
this.st_clock=create st_clock
this.cb_single=create cb_single
this.gb_multiple=create gb_multiple
this.st_every2=create st_every2
this.st_every4=create st_every4
this.st_every8=create st_every8
this.st_interval=create st_interval
this.cb_multiple=create cb_multiple
this.cb_unregister=create cb_unregister
this.cb_close=create cb_close
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.st_intro
this.Control[iCurrent+2]=this.st_clock
this.Control[iCurrent+3]=this.cb_single
this.Control[iCurrent+4]=this.st_every2
this.Control[iCurrent+5]=this.st_every4
this.Control[iCurrent+6]=this.st_every8
this.Control[iCurrent+7]=this.st_interval
this.Control[iCurrent+8]=this.cb_multiple
this.Control[iCurrent+9]=this.cb_unregister
this.Control[iCurrent+10]=this.cb_close
this.Control[iCurrent+11]=this.gb_single
this.Control[iCurrent+12]=this.gb_multiple
end on

on w_timingserv.destroy
call super::destroy
destroy(this.st_intro)
destroy(this.gb_single)
destroy(this.st_clock)
destroy(this.cb_single)
destroy(this.gb_multiple)
destroy(this.st_every2)
destroy(this.st_every4)
destroy(this.st_every8)
destroy(this.st_interval)
destroy(this.cb_multiple)
destroy(this.cb_unregister)
destroy(this.cb_close)
end on

type st_intro from statictext within w_timingserv
integer x = 37
integer y = 32
integer width = 2130
integer height = 172
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "PFC's timing object, n_tmg, triggers or posts an event in the objects registered with it: one object, with the single-object service (n_cst_tmgsingle), or several, each at its own interval, with the multiple-object service (n_cst_tmgmultiple)."
boolean focusrectangle = false
end type

type gb_single from groupbox within w_timingserv
integer x = 37
integer y = 208
integer width = 2130
integer height = 300
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Single-object service: the window's ue_tick event, every second"
end type

type st_clock from statictext within w_timingserv
integer x = 82
integer y = 300
integer width = 640
integer height = 120
integer textsize = -16
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 67108864
boolean focusrectangle = false
end type

type cb_single from u_cb within w_timingserv
integer x = 1600
integer y = 316
integer width = 517
integer taborder = 10
string text = "&Stop the Clock"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// of_SetDisabled stops the timer and starts it again
If itmg_single.inv_single.of_IsDisabled() Then
	itmg_single.inv_single.of_SetDisabled(False)
	this.Text = "&Stop the Clock"
Else
	itmg_single.inv_single.of_SetDisabled(True)
	this.Text = "&Start the Clock"
End If
end event

type gb_multiple from groupbox within w_timingserv
integer x = 37
integer y = 532
integer width = 2130
integer height = 620
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Multiple-object service: three events, each at its own interval, on one timer"
end type

type st_every2 from statictext within w_timingserv
integer x = 82
integer y = 620
integer width = 1000
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Every 2 seconds: 0"
boolean focusrectangle = false
end type

type st_every4 from statictext within w_timingserv
integer x = 82
integer y = 696
integer width = 1000
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Every 4 seconds: 0"
boolean focusrectangle = false
end type

type st_every8 from statictext within w_timingserv
integer x = 82
integer y = 772
integer width = 1000
integer height = 64
integer textsize = -8
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Segoe UI"
long textcolor = 33554432
long backcolor = 67108864
string text = "Every 8 seconds: 0"
boolean focusrectangle = false
end type

type st_interval from statictext within w_timingserv
integer x = 82
integer y = 868
integer width = 2040
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

type cb_multiple from u_cb within w_timingserv
integer x = 82
integer y = 980
integer width = 640
integer taborder = 20
string text = "Stop the &Counters"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;If itmg_multiple.inv_multiple.of_IsDisabled() Then
	itmg_multiple.inv_multiple.of_SetDisabled(False)
	this.Text = "Stop the &Counters"
Else
	itmg_multiple.inv_multiple.of_SetDisabled(True)
	this.Text = "Start the &Counters"
End If
parent.of_ShowInterval()
end event

type cb_unregister from u_cb within w_timingserv
integer x = 745
integer y = 980
integer width = 1010
integer taborder = 30
string text = "&Unregister the 2-Second Counter"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;// The service recalculates the timer's interval from the events still registered:
// from 2 seconds to 4
itmg_multiple.inv_multiple.of_Unregister(parent, "ue_every2")
st_every2.Text = "Every 2 seconds: unregistered"
this.Enabled = False
parent.of_ShowInterval()
end event

type cb_close from u_cb within w_timingserv
integer x = 1792
integer y = 1196
integer taborder = 40
string text = "Close"
string facename = "Segoe UI"
end type

event clicked;call super::clicked;parent.event pfc_close()
end event
