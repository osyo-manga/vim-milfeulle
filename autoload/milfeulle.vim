scriptencoding utf-8

let s:save_cpo = &cpo
set cpo&vim


function! milfeulle#make()
	let self = {
\		"index" : 0,
\		"list"  : []
\	}
	function! self.push_back(item)
		call add(self.list, a:item)
		let self.index = len(self.list) - 1
	endfunction

	function! self.size()
		return len(self.list)
	endfunction

	function! self.front()
		return self.list[0]
	endfunction

	function! self.back()
		return self.list[-1]
	endfunction

	function! self.empty()
		return empty(self.list)
	endfunction

	function! self.is_index_end()
		return self.index == self.size() - 1
	endfunction

	function! self.is_index_top()
		return self.index == 0
	endfunction

	function! self.next()
		if !self.is_index_end()
			let self.index += 1
		endif
		return self.index
	endfunction

	function! self.previous()
		if !self.is_index_top()
			let self.index -= 1
		endif
		return self.index
	endfunction

	function! self.get(...)
		let index = get(a:, 1, self.index)
		return self.list[index]
	endfunction
	
	function! self.insert(item, ...)
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

	function! self.remove(index)
		unlet self.list[a:index]
		if self.index >= a:index
			let self.index -= 1
		endif
	endfunction

	function! self.remove_index()
		return self.remove(self.index)
	endfunction

	function! self.clear()
		let self.list = []
		let self.index = 0
	endfunction

	function! self.filter(expr)
		let first = filter(copy(self.list[: self.index]), a:expr)
		let last  = filter(copy(self.list[self.index + 1 :]), a:expr)
		let self.index = len(first) - 1
		let self.list = first + last
	endfunction

	function! self.to_string()
		return join(map(copy(self.list), "printf('%s %2d %s', (self.index == v:key ? '> ' : '  '), v:key, v:val.to_string())"), "\n")
	endfunction

	return self
endfunction


function! milfeulle#clear()
	call s:jumplist.clear()
	call s:jumplist.push_back(milfeulle#jumper#dummy#make())
endfunction


let s:jumplist = milfeulle#make()
call milfeulle#clear()

function! s:debug_print()
	if !g:milfeulle_debug
		return
	endif
	let s = s:jumplist.to_string()
	Clog! s
endfunction


function! milfeulle#disp()
	echo s:jumplist.to_string()
endfunction

function! milfeulle#debug()
	return s:jumplist
endfunction


function! milfeulle#prev()
	let index = s:jumplist.index - 1
	while milfeulle#jump(index) == -1
		let index -= 1
	endwhile
endfunction


function! milfeulle#next()
	let index = s:jumplist.index + 1
	while milfeulle#jump(index) == -1
		let index += 1
	endwhile
endfunction


function! milfeulle#jump(...)
	let index = get(a:, 1, s:jumplist.index)
	if index < 0 || s:jumplist.size()-1 < index
		return
	endif
	if !s:jumplist.get(index).is_active()
		return -1
	endif
	let s:jumplist.index = index
	call s:jumplist.get().jump()
	call s:debug_print()
endfunction


function! s:jumplist_compact()
	call s:jumplist.filter("v:val.is_active()")
	call s:debug_print()
endfunction


function! s:resize()
	call s:jumplist_compact()
	if s:jumplist.size() > g:milfeulle_history_size
		if (s:jumplist.size()-1) <= s:jumplist.index
			call s:jumplist.remove(0)
		else
			call s:jumplist.remove(s:jumplist.size()-1)
		endif
	endif
endfunction


function! s:make_jumper()
	return milfeulle#jumper#default#make()
endfunction


function! milfeulle#overlay(...)
	if a:0 == 0
		return milfeulle#overlay(s:make_jumper())
	endif
	let jumper = a:1
	if empty(jumper)
		return
	endif
	if !s:jumplist.empty() && (s:jumplist.get().equal(jumper) || s:jumplist.get(s:jumplist.index-1).equal(jumper))
		return
	endif
	if s:jumplist.is_index_end()
		call s:jumplist.insert(jumper, s:jumplist.size()-1)
	else
		call s:jumplist.insert(jumper)
	endif
	call s:resize()
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
