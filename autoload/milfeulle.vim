scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim


let s:undolist = {}

function! s:undolist.push_back(item)
	call add(self.list, a:item)
	let self.index = len(self.list) - 1
endfunction

function! s:undolist.size()
	return len(self.list)
endfunction

function! s:undolist.front()
	return self.list[0]
endfunction

function! s:undolist.back()
	return self.list[-1]
endfunction

function! s:undolist.empty()
	return empty(self.list)
endfunction

function! s:undolist.is_index_end()
	return self.index == self.size() - 1
endfunction

function! s:undolist.is_index_top()
	return self.index == 0
endfunction

function! s:undolist.next()
	if !self.is_index_end()
		let self.index += 1
	endif
	return self.index
endfunction

function! s:undolist.previous()
	if !self.is_index_top()
		let self.index -= 1
	endif
	return self.index
endfunction

function! s:undolist.get(...)
	let index = get(a:, 1, self.index)
	return self.list[index]
endfunction

function! s:undolist.insert(item, ...)
	let index = get(a:, 1, self.index)
	if index <= 0
		let self.list = [a:item] + self.list
	else
		let self.list = self.list[: index-1] + [a:item] + self.list[index :]
	endif
	if self.index >= index
		let self.index += 1
	endif
endfunction

function! s:undolist.remove(index)
	unlet self.list[a:index]
	if self.index >= a:index
		let self.index -= 1
	endif
endfunction

function! s:undolist.remove_index()
	return self.remove(self.index)
endfunction

function! s:undolist.clear()
	let self.list = []
	let self.index = 0
endfunction

function! s:undolist.filter(expr)
	let first = filter(copy(self.list[: self.index]), a:expr)
	let last  = filter(copy(self.list[self.index + 1 :]), a:expr)
	let self.index = len(first) - 1
	let self.list = first + last
endfunction

function! s:undolist.to_string()
	return join(map(copy(self.list), "printf('%s %2d %s', (self.index == v:key ? '> ' : '  '), v:key, v:val.to_string())"), "\n")
endfunction

function! s:make_undolist()
	let self = copy(s:undolist)
	let self.index = 0
	let self.list = []
	return self
endfunction




let s:base_jumplist = {}

function! s:base_jumplist.get_default_jumper()
" 	return self.default_jumper
	return g:milfeulle_default_jumper_name
endfunction

function! s:base_jumplist.get_capacity()
	return g:milfeulle_history_size
endfunction

function! s:base_jumplist.jump(...)
	let index = get(a:, 1, self.index)
	if index < 0 || self.size()-1 < index
		return
	endif
	if !self.get(index).is_active()
		return -1
	endif
	let self.index = index
	call self.get().jump()
	call self.debug_print()
endfunction

function! s:base_jumplist.prev_jump()
	if self.is_index_top()
		return
	endif
	let now = milfeulle#make_jumper(self.get_default_jumper())
	let index = self.index - 1
	while self.jump(index) == -1
		let index -= 1
	endwhile

	" 同じ位置ならもう1つ前へ飛ぶ
	if self.get().equal(now)
		return self.prev_jump()
	endif
endfunction

function! s:base_jumplist.next_jump()
	if self.is_index_end()
		return
	endif
	let now = milfeulle#make_jumper(self.get_default_jumper())
	let index = self.index + 1
	while self.jump(index) == -1
		let index += 1
	endwhile

	" 同じ位置ならもう1つ次へ飛ぶ
	if self.get().equal(now)
		return self.next_jump()
	endif
endfunction

function! s:base_jumplist.refresh()
	call self.filter("v:val.is_active()")
endfunction

function! s:base_jumplist.resize()
	if self.size() > self.get_capacity()
		if (self.size()-1) <= self.index
			call self.remove(0)
		else
			call self.remove(self.size()-1)
		endif
	endif
endfunction

function! s:base_jumplist.overlay(...)
	if a:0 == 0
		return self.overlay(milfeulle#make_jumper(self.get_default_jumper()))
	endif
	let jumper = a:1
	if empty(jumper)
		return
	endif
	if !self.empty() && (self.get().equal(jumper) || (self.index > 0 && self.get(self.index-1).equal(jumper)))
		return
	endif
	if self.is_index_end()
		call self.insert(jumper, self.size()-1)
	else
		call self.insert(jumper)
	endif
	call self.resize()
	call self.debug_print()
endfunction

function! s:base_jumplist.clear()
	call self.base_clear()
	call self.push_back(milfeulle#jumper#dummy#make())
endfunction

function! s:base_jumplist.debug_print()
	if !g:milfeulle_debug
		return
	endif
	let s = self.to_string()
	Clog! s
endfunction


function! milfeulle#make_jumplist(capacity, default_jumper)
	let self = s:make_undolist()
	let self.base_clear = self.clear

	let self = extend(self, copy(s:base_jumplist))
	let self.default_jumper = a:default_jumper
	let self.capacity = a:capacity
	call self.clear()
	return self
endfunction



function! s:jumplist_global()
	if !exists("s:jumplist")
		let s:jumplist = milfeulle#make_jumplist(g:milfeulle_history_size, g:milfeulle_default_jumper_name)
	endif
	return s:jumplist
endfunction


function! s:jumplist_buffer(...)
	let bufnr = bufnr("%")
	let jumplist = getbufvar(bufnr, "milfeulle_jumplist", {})
	if empty(jumplist)
		let jumplist = milfeulle#make_jumplist(g:milfeulle_history_size, g:milfeulle_default_jumper_name)
		call setbufvar(bufnr, "milfeulle_jumplist", jumplist)
	endif
	return jumplist
endfunction


function! s:jumplist_window(...)
	let winnr = winnr()
	let jumplist = getwinvar(winnr, "milfeulle_jumplist", {})
	if empty(jumplist)
		let jumplist = milfeulle#make_jumplist(g:milfeulle_history_size, g:milfeulle_default_jumper_name)
		call setwinvar(winnr, "milfeulle_jumplist", jumplist)
	endif
	return jumplist
endfunction


function! s:jumplist_tabpage(...)
	let tabpagenr = tabpagenr()
	let jumplist = gettabvar(tabpagenr, "milfeulle_jumplist", {})
	if empty(jumplist)
		let jumplist = milfeulle#make_jumplist(g:milfeulle_history_size, g:milfeulle_default_jumper_name)
		call settabvar(tabpagenr, "milfeulle_jumplist", jumplist)
	endif
	return jumplist
endfunction


function! s:get_jumplist(kind)
	return s:jumplist_{a:kind}()
endfunction

function! milfeulle#clear(...)
	let kind = get(a:, 1, g:milfeulle_default_kind)
	return s:get_jumplist(kind).clear()
endfunction


function! milfeulle#disp(...)
	let kind = get(a:, 1, g:milfeulle_default_kind)
	echo s:get_jumplist(kind).to_string()
endfunction


" function! milfeulle#debug(...)
" 	return s:get_jumplist()
" endfunction


function! milfeulle#prev(...)
	let kind = get(a:, 1, g:milfeulle_default_kind)
	return s:get_jumplist(kind).prev_jump()
endfunction


function! milfeulle#next(...)
	let kind = get(a:, 1, g:milfeulle_default_kind)
	return s:get_jumplist(kind).next_jump()
endfunction


function! milfeulle#refresh(...)
	let kind = get(a:, 1, g:milfeulle_default_kind)
	call s:get_jumplist(kind).refresh()
endfunction


function! milfeulle#jump(...)
	let kind = get(a:, 1, g:milfeulle_default_kind)
	let jumplist = s:get_jumplist(kind)
	return call(jumplist.jump, a:000[1:], jumplist)
endfunction


function! milfeulle#overlay(...)
	let kind = get(a:, 1, g:milfeulle_default_kind)
	let jumplist = s:get_jumplist(kind)
	return call(jumplist.overlay, a:000[1:], jumplist)
endfunction


function! milfeulle#jumper_list()
	return filter(map(split(globpath(&rtp, "autoload/milfeulle/jumper/*.vim"), "\n"), "fnamemodify(v:val, ':t:r')"), "v:val !=# 'dummy'")
endfunction


function! milfeulle#jumper(name)
	let name = empty(a:name) ? g:milfeulle_default_jumper_name : a:name
	return milfeulle#jumper#{name}#make()
endfunction


function! milfeulle#make_jumper(name)
	let name = empty(a:name) ? g:milfeulle_default_jumper_name : a:name
	return milfeulle#jumper#{name}#make()
endfunction

function! s:make_jumper()
	return milfeulle#jumper("")
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
