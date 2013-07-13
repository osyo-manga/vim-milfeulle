scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim



let s:dummy_jumper = {
\	"type" : "dummy",
\}
function! s:dummy_jumper.is_active()
	return 1
endfunction

function! s:dummy_jumper.equal(...)
	return 0
endfunction

function! s:dummy_jumper.jump()
endfunction

function! s:dummy_jumper.to_string()
	return ""
endfunction


function! milfeulle#jumper#dummy#make()
	return s:dummy_jumper
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
