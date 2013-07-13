function! s:owl_begin()
	let g:owl_success_message_format = ""
endfunction

function! s:owl_end()
	let g:owl_success_message_format = "%f:%l:[Success] %e"
endfunction


function! s:test_make1()
	let list = milfeulle#make()
	
	OwlCheck list.size() == 0
	OwlThrow list.front(), E684
	OwlThrow list.back(), E684

	call list.push_back(0)
	OwlCheck list.size() == 1
	OwlCheck list.get() == 0
	OwlCheck list.back() == 0

	call list.push_back(1)
	OwlCheck list.size() == 2
	OwlCheck list.get()  == 1
	OwlCheck list.back() == 1
endfunction

function! s:test_make2()
	let list = milfeulle#make()

	call list.push_back(1)
	call list.push_back(2)
	call list.push_back(3)
	call list.push_back(4)

	OwlCheck list.size() == 4
	call list.remove_index()
	OwlCheck list.size() == 3
	OwlCheck list.get() == 3
	call list.previous()
	call list.previous()
	call list.previous()
	OwlCheck list.get() == 1
	call list.remove(2)
	OwlCheck list.size() == 2
	
	call list.next()
	OwlCheck list.get() == 2
	call list.remove_index()
	OwlCheck list.size() == 1
	OwlCheck list.get() == 1
endfunction


function! s:test_make3()
	let list = milfeulle#make()
	call list.push_back(1)
	OwlCheck list.get() == 1

	call list.insert(2)
	OwlCheck list.get() == 1
	OwlCheck list.list == [2, 1]

	call list.insert(3, 10)
	OwlCheck list.get() == 1
	OwlCheck list.list == [2, 1, 3]

	call list.insert(4, 0)
	OwlCheck list.get() == 1
	OwlCheck list.list == [4, 2, 1, 3]
endfunction


function! s:test_make4()
	let list = milfeulle#make()
	call list.push_back(10)
	call list.insert(0, list.size()-1)
	call list.insert(1, list.size()-1)
	call list.insert(2, list.size()-1)
	call list.insert(3, list.size()-1)
	OwlCheck list.list == [0, 1, 2, 3, 10]
endfunction


function! s:test_make5()
	let list = milfeulle#make()
	call list.insert(1)
	call list.insert(2)
	call list.insert(3)
" 	OwlCheck list.get() == 1
endfunction

