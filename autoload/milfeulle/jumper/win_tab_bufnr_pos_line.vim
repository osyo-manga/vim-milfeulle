scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


function! milfeulle#jumper#win_tab_bufnr_pos_line#make()
	let self = milfeulle#jumper#win_tab_bufnr_pos#make()
	let self.line = getline(".")
	let self.type = "win_tab_bufnr_pos_line"

	let self.base_is_active = self.is_active
	function! self.is_active()
		return self.base_is_active()
\			&& self.line ==# get(getbufline(self.bufnr, self.pos[1]), 0, "")
	endfunction

	let self.base_equal = self.equal
	function! self.equal(rhs)
		return self.base_equal(a:rhs)
\			&& self.line ==# get(getbufline(a:rhs.bufnr, a:rhs.pos[1]), 0, "")
	endfunction

	let self.base_to_string = self.to_string
	function! self.to_string()
		return self.base_to_string() . "  " . self.line
	endfunction

	return self
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
