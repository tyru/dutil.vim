" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



function! dutil#load()
    " dummy
endfunction

function! s:echomsg(hl, msg)
    execute 'echohl' a:hl
    try
        echomsg a:msg
    finally
        echohl None
    endtry
endfunction



" Debug macros


" NOTE: Do not make this function.
" Evaluate arguments at same scope.

" :Dump {{{1
command!
\   -bang -nargs=+ -complete=expression
\   Dump
\
\   echohl Debug
\   | redraw
\   | echomsg printf("  %s = %s", <q-args>, string(<args>))
\   | if <bang>0
\   |   try
\   |     throw ''
\   |   catch
\   |     ShowStackTrace
\   |   endtry
\   | endif
\   | echohl None


" :ShowStackTrace {{{1
command!
\   -bar -bang
\   ShowStackTrace
\   call s:cmd_show_stack_trace()

function! s:cmd_show_stack_trace()
    if <bang>0
        try
            throw ':ShowStackTrace!'
        catch
            ShowStackTrace
        endtry
    else
        call s:echomsg('Debug',
        \   printf('[%s] at [%s]', v:exception, v:throwpoint))
    endif
endfunction

" :Assert {{{1
command!
\   -nargs=+
\   Assert
\
\   if !eval(<q-args>)
\   |   throw dutil#assertion_failure(<q-args>)
\   | endif

function! dutil#assertion_failure(msg)
    return 'assertion failure: ' . a:msg
endfunction


" :Decho "{{{1
command!
\   -nargs=+
\   Decho
\
\   echohl Debug
\   | echomsg <args>
\   | echohl None

" :Eecho {{{1
command!
\   -nargs=+
\   Eecho
\
\   echohl ErrorMsg
\   | echomsg <args>
\   | echohl None



" End.
" }}}1





" Functions

function! dutil#log(path, msg) "{{{1
    let path = expand(a:path)
    let msg = printf('[%s]::%s', strftime('%c'), a:msg)

    execute 'redir >>' path
    silent echo msg
    redir END
endfunction

function! dutil#logf(path, fmt, ...) "{{{1
    return dutil#log(a:path, call('printf', [a:fmt] + a:000))
endfunction

function! dutil#logstrf(path, fmt, ...) "{{{1
    return dutil#log(a:path, call('printf', [a:fmt] + map(copy(a:000), 'string(v:val)')))
endfunction


" }}}1



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
