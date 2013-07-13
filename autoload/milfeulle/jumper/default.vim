scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! s:make(pos, winnr, tabnr, bufnr)
	let self = {
\		"type"   : "default",
\		"pos"    : a:pos,
\		"winnr"  : a:winnr,
\		"tabnr"  : a:tabnr,
\		"bufnr"  : a:bufnr,
\	}

	function! self.is_active()
		return get(tabpagebuflist(self.tabnr), self.winnr-1, -1) == self.bufnr
	endfunction

	function! self.jump()
		if !self.is_active()
			return 0
		endif
		execute "tabnext" self.tabnr
		execute self.winnr . "wincmd w"
		call setpos(".", self.pos)
		return 1
	endfunction
	
	function! self.to_string()
		return printf("tabpage:%2d  winnr:%2d  line:%4d bufnr:%2d  name:%s", self.tabnr, self.winnr, self.pos[1], self.bufnr, fnamemodify(bufname(self.bufnr), ":t"))
	endfunction

	function! self.equal(rhs)
		return self.type  == a:rhs.type
\			&& self.pos   == a:rhs.pos
\			&& self.winnr == a:rhs.winnr
\			&& self.tabnr == a:rhs.tabnr
\			&& self.bufnr == a:rhs.bufnr
	endfunction

	return self
endfunction


function! milfeulle#jumper#default#make()
	return s:make(getpos("."), winnr(), tabpagenr(), bufnr("%"))
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
