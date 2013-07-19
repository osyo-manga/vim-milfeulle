scriptencoding utf-8
if exists('g:loaded_milfeulle')
  finish
endif
let g:loaded_milfeulle = 1

let s:save_cpo = &cpo
set cpo&vim


command! -bar MilfeulleDisp    call milfeulle#disp()
command! -bar MilfeulleOverlay call milfeulle#overlay()
command! -bar MilfeullePrev    call milfeulle#prev()
command! -bar MilfeulleNext    call milfeulle#next()
command! -bar MilfeulleClear   call milfeulle#clear()
command! -bar MilfeulleRefresh call milfeulle#refresh()


let g:milfeulle_history_size = get(g:, "milfeulle_history_size", 50)
let g:milfeulle_debug = get(g:, "milfeulle_debug" , 0)


nnoremap <silent> <Plug>(milfeulle-overlay) :<C-u>MilfeulleOverlay<CR>
nnoremap <silent> <Plug>(milfeulle-prev)    :<C-u>MilfeullePrev<CR>
nnoremap <silent> <Plug>(milfeulle-next)    :<C-u>MilfeulleNext<CR>
nnoremap <silent> <Plug>(milfeulle-clear)   :<C-u>MilfeulleClear<CR>
nnoremap <silent> <Plug>(milfeulle-refresh) :<C-u>MilfeulleRefreshClear<CR>


let g:milfeulle_enable_CursorHold = get(g:, "milfeulle_enable_CursorHold", 1)
let g:milfeulle_enable_InsertLeave = get(g:, "milfeulle_enable_InsertLeave", 1)

augroup milfeulle
	autocmd!
	autocmd CursorHold *
\		if g:milfeulle_enable_CursorHold | :MilfeulleOverlay | endif

	autocmd InsertLeave *
\		if g:milfeulle_enable_InsertLeave | :MilfeulleOverlay | endif
augroup END


let &cpo = s:save_cpo
unlet s:save_cpo
