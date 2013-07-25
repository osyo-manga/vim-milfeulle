scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:jumper = {
\	"type" : "bufnr_pos"
\}

function! s:jumper.is_active()
	return buflisted(self.bufnr)
endfunction


function! s:jumper.jump()
	if !self.is_active()
		return 0
	endif
	execute "buffer" self.bufnr
	call setpos(".", self.pos)
	return 1
endfunction


function! s:jumper.to_string()
	return printf("%s lnum:%d col:%d", fnamemodify(bufname(self.bufnr), ":t"), self.pos[1], self.pos[2])
endfunction


function! s:jumper.equal(rhs)
 	return self.type  == a:rhs.type
\		&& self.pos   == a:rhs.pos
\		&& self.bufnr == a:rhs.bufnr
endfunction


function! s:make(bufnr, pos)
	let result = deepcopy(s:jumper)
	let result.bufnr = a:bufnr
	let result.pos   = a:pos
	return result
endfunction


function! milfeulle#jumper#bufnr_pos#make()
	return s:make(bufnr("%"), getpos("."))
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
