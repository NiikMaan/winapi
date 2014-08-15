--ffi/wcs: utf8 to wide character string and back.
setfenv(1, require'winapi.namespace')
require'winapi.ffi'
require'winapi.util'
require'winapi.wintypes'

ffi.cdef[[
size_t wcslen(const wchar_t *str);
wchar_t *wcsncpy(wchar_t *strDest, const wchar_t *strSource, size_t count);

int WideCharToMultiByte(
	  UINT     CodePage,
	  DWORD    dwFlags,
	  LPCWSTR  lpWideCharStr,
	  int      cchWideChar,
	  LPSTR    lpMultiByteStr,
	  int      cbMultiByte,
	  LPCSTR   lpDefaultChar,
	  LPBOOL   lpUsedDefaultChar);

int MultiByteToWideChar(
	  UINT     CodePage,
	  DWORD    dwFlags,
	  LPCSTR   lpMultiByteStr,
	  int      cbMultiByte,
	  LPWSTR   lpWideCharStr,
	  int      cchWideChar);
]]

CP_INSTALLED      = 0x00000001  -- installed code page ids
CP_SUPPORTED      = 0x00000002  -- supported code page ids
CP_ACP            = 0           -- default to ANSI code page
CP_OEMCP          = 1           -- default to OEM  code page
CP_MACCP          = 2           -- default to MAC  code page
CP_THREAD_ACP     = 3           -- current thread's ANSI code page
CP_SYMBOL         = 42          -- SYMBOL translations
CP_UTF7           = 65000       -- UTF-7 translation
CP_UTF8           = 65001       -- UTF-8 translation

MB_PRECOMPOSED            = 0x00000001  -- use precomposed chars
MB_COMPOSITE              = 0x00000002  -- use composite chars
MB_USEGLYPHCHARS          = 0x00000004  -- use glyph chars, not ctrl chars
MB_ERR_INVALID_CHARS      = 0x00000008  -- error for invalid chars

ERROR_INSUFFICIENT_BUFFER = 122

local checknz = checknz
local WCS_ctype = ffi.typeof'WCHAR[?]'
local MB2WC = C.MultiByteToWideChar
local CP = CP_UTF8  --CP_* flags
local MB = 0        --MB_* flags

function wcs_sz(s) --accept and convert a utf8-encoded Lua string to a wcs cdata
	if type(s) ~= 'string' then return s end
	local sz = #s + 1 --assume 1 byte per character + null terminator
	local buf = WCS_ctype(sz)
	sz = MB2WC(CP, MB, s, #s + 1, buf, sz)
	if sz == 0 then
		if GetLastError() ~= ERROR_INSUFFICIENT_BUFFER then checknz(0) end
		sz = checknz(MB2WC(CP, MB, s, #s + 1, nil, 0))
		buf = WCS_ctype(sz)
		sz = checknz(MB2WC(CP, MB, s, #s + 1, buf, sz))
	end
	return buf, sz
end

function wcs(s)
	return (wcs_sz(s))
end

W = wcs --fancy sugar to use on string constants

DEFAULT_WCS_BUFFER_SIZE = 2048 --some APIs don't have a way to tell us how much to allocate

--wcs buffer constructor: allocates a WCHAR[?] buffer and returns the buffer
--and its size in WCHARs, minus the null-terminator.
--given a number, allocate a WCHAR buffer of size n + 1 (default n = 2048).
--given a WCHAR[?] cdata, return it back along with its size in WCHARs minus the null terminator.
function WCS(n)
	if type(n) == 'number' then
		return WCS_ctype(n+1), n
	elseif ffi.istype(WCS_ctype, n) then
		return n, sizeof(n) / 2 - 1
	elseif n == nil then
		return WCS_ctype(DEFAULT_WCS_BUFFER_SIZE+1), DEFAULT_WCS_BUFFER_SIZE
	end
	assert(false)
end

WC_COMPOSITECHECK         = 0x00000200  -- convert composite to precomposed
WC_DISCARDNS              = 0x00000010  -- discard non-spacing chars
WC_SEPCHARS               = 0x00000020  -- generate separate chars
WC_DEFAULTCHAR            = 0x00000040  -- replace w/ default char
WC_NO_BEST_FIT_CHARS      = 0x00000400  -- do not use best fit chars

local MBS_ctype = ffi.typeof'CHAR[?]'
local PWCS_ctype = ffi.typeof'WCHAR*'
local WC2MB = C.WideCharToMultiByte
local WC = 0 --WC_* flags

function mbs(ws) --accept and convert a wcs or pwcs buffer to a Lua string
	if ffi.istype(WCS_ctype, ws) or ffi.istype(PWCS_ctype, ws) then
		local sz = checknz(WC2MB(CP_UTF8, WC, ws, -1, nil, 0, nil, nil))
		local buf = MBS_ctype(sz)
		checknz(WC2MB(CP_UTF8, WC, ws, -1, buf, sz, nil, nil))
		return ffi.string(buf, sz-1) --sz includes null terminator
	else
		return ws
	end
end

wcslen = C.wcslen

function wcsncpy(dest, src, count) --wcsncpy variant that null-terminates even on truncation
	C.wcsncpy(dest, src, count)
	dest[count-1] = 0
end

--convert and store a utf8-encoded Lua string into a user-provided, fixed size wcs cdata.
function wcs_to(s, ws)
	if s == nil then s = '' end
	if type(s) ~= 'string' then return s end
	local sz = checknz(MB2WC(CP, MB, s, #s + 1, nil, 0))
	if sz > ffi.sizeof(ws) / 2 then
		error('string too long. max chars: '..(ffi.sizeof(ws) / 2 - 1))
	end
	checknz(MB2WC(CP_UTF8, 0, s, #s + 1, ws, ffi.sizeof(ws)))
end

