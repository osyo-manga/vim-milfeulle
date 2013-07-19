scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:make(pos)
	let self = {
\		"type" : "position",
\		"pos" : a:pos
\	}

	function! self.is_active()
		return self.pos[1] <= line("w$")
	endfunction

	function! self.equal(rhs)
		return self.type ==# get(a:rhs, "type", "")
\			&& self.pos[1] == a:rhs.pos[1]
\			&& self.pos[2] == a:rhs.pos[2]
	endfunction

	function! self.jump()
		call setpos(".", self.pos)
	endfunction

	function! self.to_string()
		return printf("lnum : %d  col : %d", self.pos[1], self.pos[2])
	endfunction
	return self
endfunction


function! milfeulle#jumper#position#make()
	return s:make(getpos("."))
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
