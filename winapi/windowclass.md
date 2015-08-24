---
tagline: top-level windows
---

## `require'winapi.windowclass'`

This module implements the `Window` class for creating top-level windows.
`Window` inherits from `BaseWindow` from [winapi.basewindowclass] module.

## Usage

~~~{.lua}
local winapi = require'winapi'
require'winapi.windowclass'

local win = winapi.Window{
	w = 500,                --these are initial fields
	h = 300,
	title = 'Lua rulez',
	autoquit = true,
	visible = false,        --this field is from BaseWindow
}

function win:on_close()    --this is an event handler
	print'Bye'
end

print(win.title)           --this is reading the value of a property
win.title = 'Lua rulez!'   --this is setting the value of a property
win:show()                 --this is a method call

MessageLoop()					--start the message loop
~~~

## API

The tables below list all initial fields, properties, methods and events
specific to the `Window` class. Everything listed for `BaseWindow` in
[winapi.basewindowclass] is available too.


### Initial fields and properties

<div class=small>

__NOTE:__ the table below `i` means initial field, `r` means read-only property,
`rw` means read-write property.

----------------------- -------- ----------------------------------------- -------------- ---------------------
__field/property__		__irw__	__description__									__default__		__reference__
noclose						irw		remove the close button							false				CS_NOCLOSE
dropshadow					irw		(for non-movable windows)						false				CS_DROPSHADOW
own_dc						irw		own the DC											false				CS_OWNDC
receive_double_clicks	irw		enable double click events						true				CS_DBLCLKS
border						irw		add a border										true				WS_BORDER
frame 						irw		add a titlebar	(needs border)					true				WS_DLGFRAME
minimize_button			irw		add a minimize button							true				WS_MINIMIZEBOX
maximize_button			irw		add a maximize button							true				WS_MAXIMIZEBOX
sizeable						irw		enable resizing 									true				WS_SIZEBOX
sysmenu						irw		add a system menu									true				WS_SYSMENU
vscroll						irw		add a vertical scrollbar						false				WS_VSCROLL
hscroll						irw		add a horizontal scrollbar						false				WS_HSCROLL
clip_children				irw		clip children										true				WS_CLIPCHILDREN
clip_siblings				irw		clip siblings										true				WS_CLIPSIBLINGS
child							irw		(for non-activable tool windows)	 			false				WS_CHILD
topmost						irw		stay above all windows							false				WS_EX_TOPMOST
window_edge					irw		(needs to be the same as frame)				true				WS_EX_WINDOWEDGE
dialog_frame				irw		double border and no sysmenu icon			false				WS_EX_DLGMODALFRAME
help_button					irw		add a help button									false				WS_EX_CONTEXTHELP
tool_window					irw		tool window frame									false				WS_EX_TOOLWINDOW
transparent					irw		(use layered instead)		 					false				WS_EX_TRANSPARENT
layered						irw		layered mode								 		false				WS_EX_LAYERED
control_parent				irw		recursive tabbing	between controls			true				WS_EX_CONTROLPARENT
activatable					irw		activate and show on taskbar					true				WS_EX_NOACTIVATE
taskbar_button				irw		force showing on taskbar						false				WS_EX_APPWINDOW
background					irw		background color									COLOR_WINDOW
cursor						irw		default cursor										IDC_ARROW
title							irw		titlebar												''
x, y							irw		frame position										CW_USEDEFAULT
w, h							irw		frame size											CW_USEDEFAULT
autoquit						irw		stop the loop when closed						false
menu							irw		menu bar
remember_maximized_pos	irw		maximize to last known position				false
minimized					ir			minimized state									false				WS_MINIMIZE
maximized					ir			maximized state									false				WS_MAXIMIZE
icon							irw		window's icon
small_icon					irw		window's small icon
owner							irw		window's owner
foreground					 r			foreground state
normal_rect					 rw		frame rect in normal state
restore_to_maximized		 rw		unminimize to maximized state
accelerators				 rw		list of of accelerators
----------------------- -------- ----------------------------------------- -------------- ---------------------
</div>


### Methods

<div class=small>
-------------------------------- -------------------------------------------- ----------------------------
__state__								__description__										__reference__
close()									destroy the window									CloseWindow
activate()								activate the window if the app is active		SetActiveWindow
setforeground()						activate the window anyway							SetForegroundWindow
minimize([deactivate], [async])	minimize (deactivate: true)						ShowWindow
maximize(nil, [async])				maximize and activate								ShowWindow
shownormal([activate], [async])	show in normal state (activate: true)			ShowWindow
restore(nil, [async])				restore from minimized or maximized state		ShowWindow
set_normal_rect(x, y, w, h)		set the normal_rect discretely					SetWindowPlacement
__z-order__								__description__										__reference__
send_to_back([rel_to_win])			move below other windows/specific window		SetWindowPos
bring_to_front([rel_to_win])		move above other windows/specific window		SetWindowPos
-------------------------------- -------------------------------------------- ----------------------------
</div>


### Events

<div class=small>
-------------------------------- -------------------------------------------- ----------------------
__event__								__description__										__reference__
on_close()								was closed												WM_CLOSE
on_activate()							was activated											WM_ACTIVATE
on_deactivate()						was deactivated										WM_ACTIVATE
on_activate_app()						the app was activated								WM_ACTIVATEAPP
on_deactivate_app()					the app was deactivated								WM_ACTIVATEAPP
on_nc_activate()						the non-client area was activated				WM_NCACTIVATE
on_nc_deactivate()					the non-client area was deactivated				WM_NCACTIVATE
on_minimizing(x, y)					minimizing: return false to prevent				SC_MINIMIZE
on_unminimizing()						unminimizing: return false to prevent			WM_QUERYOPEN
on_maximizing(x, y)					maximizing: return false to prevent				SC_MAXIMIZE
on_restoring(x, y) 					unmaximizing: return false to prevent			SC_RESTORE
on_menu_key(char_code)				get the 'f' in Alt+F on a '&File' menu			SC_KEYMENU
on_get_minmax_info(MINMAXINFO)	set the min/max size constraints					WM_GETMINMAXINFO
__system event__						__description__										__winapi message__
on_query_end_session()				logging off (return false to prevent)			WM_QUERYENDSESSION
on_end_session()						logging off	(after all apps agreed)				WM_ENDSESSION
on_system_color_change()			system colors changed								WM_SYSCOLORCHANGE
on_settings_change()					system parameters info changed					WM_SETTINGCHANGE
on_device_mode_change()				device-mode settings changed						WM_DEVMODECHANGE
on_fonts_change()						installed fonts changed								WM_FONTCHANGE
on_time_change()						system time changed									WM_TIMECHANGE
on_spooler_change()					spooler's status changed							WM_SPOOLERSTATUS
on_input_language_change()			input language changed								WM_INPUTLANGCHANGE
on_user_change()						used has logged off									WM_USERCHANGED
on_display_change()					display resolution changed							WM_DISPLAYCHANGE
----------------------- --------	-------------------------------------------- ---------------------
</div>
