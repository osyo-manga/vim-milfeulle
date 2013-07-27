scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

let s:jumper = {
\	"type"   : "win_tab_bufnr_pos",
\}


function! s:jumper.is_active()
	let buflist = tabpagebuflist(self.tabnr)
	if type(buflist) == type(0) && buflist == 0
		return 0
	endif
	return get(buflist, self.winnr-1, -1) == self.bufnr
endfunction


function! s:jumper.jump()
	if !self.is_active()
		return 0
	endif
	execute "tabnext" self.tabnr
	execute self.winnr . "wincmd w"
	call setpos(".", self.pos)
	return 1
endfunction


function! s:jumper.to_string()
	return printf("tabpage:%2d  winnr:%2d  line:%4d bufnr:%2d  name:%s", self.tabnr, self.winnr, self.pos[1], self.bufnr, fnamemodify(bufname(self.bufnr), ":t"))
endfunction


function! s:jumper.equal(rhs)
	return self.type  == a:rhs.type
\			&& self.pos   == a:rhs.pos
\			&& self.winnr == a:rhs.winnr
\			&& self.tabnr == a:rhs.tabnr
\			&& self.bufnr == a:rhs.bufnr
endfunction


function! s:make(pos, winnr, tabnr, bufnr)
	let result = deepcopy(s:jumper)
	let result.pos = a:pos
	let result.winnr = a:winnr
	let result.tabnr = a:tabnr
	let result.bufnr = a:bufnr
	return result
endfunction


function! milfeulle#jumper#win_tab_bufnr_pos#make()
	return s:make(getpos("."), winnr(), tabpagenr(), bufnr("%"))
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
