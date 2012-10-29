" Vim syntax file
" Language:     Smalltalk
" Maintainer:   Jānis Rūcis <parasti@gmail.com>
" Last Change:  2007-03-31

" Initialization {{{
" -----------------------------------------------------------------------------

if exists("b:current_syntax")
    finish
endif

let s:cpo_save = &cpo
set cpo&vim

" -----------------------------------------------------------------------------

syn case match

" TODO:  do something intelligent here.
setlocal iskeyword=a-z,A-Z,48-57,_

" Still not perfect.
syn sync minlines=300

" Errors {{{1
" -----------------------------------------------------------------------------

syn match stError /\S/ contained
syn match stBangError /!/ contained

syn match stDelimError /)/
syn match stDelimError /\]/
syn match stDelimError /}/

" stMethodMembers holds groups that can appear in a method.
syn cluster stMethodMembers contains=stDelimError

" Comments {{{1
" -----------------------------------------------------------------------------

syn keyword stTodo FIXME TODO XXX contained
syn region stComment
    \ start=/"/ end=/"/
    \ contains=stTodo,@Spell
    \ fold

if exists("st_stx_style_end_of_line_comments")
    syn match stComment +"/.*$+ contains=stTodo,@Spell
endif

syn cluster stMethodMembers add=stComment

" Reserved keywords {{{1
" -----------------------------------------------------------------------------

syn keyword stNil nil
syn keyword stBoolean true false
syn keyword stKeyword self super

syn cluster stMethodMembers add=stNil,stBoolean,stKeyword

" Methods {{{1
" -----------------------------------------------------------------------------

syn region stMethods
    \ matchgroup=stMethodDelims
    \ start=
        \/!\%(\K\k*\%(\.\|::\)\)*
        \\K\k*\s\+\%(class\s\+\)\?
        \methodsFor:[^!]\+!/
    \ end=/\_s\@<=!/
    \ contains=stError,stMethod,stComment
    \ transparent fold

" -----------------------------------------------------------------------------

" Unary messages
syn region stMethod
    \ matchgroup=stMessagePattern
    \ start=/\K\k*\_s\@=/ end=/!/
    \ contains=@stMethodMembers
    \ contained transparent fold

" Binary messages

if !exists("st_three_character_binary_selectors")
    syn region stMethod
        \ matchgroup=stMessagePattern
        \ start=/[-+*/~|,<>=&@?\\%]\{1,2}\s*\K\k*\_s\@=/ end=/!/
        \ contains=@stMethodMembers
        \ contained transparent fold
else
    syn region stMethod
        \ matchgroup=stMessagePattern
        \ start=/[-+*/~|,<>=&@?\\%]\{1,3}\s*\K\k*\_s\@=/ end=/!/
        \ contains=@stMethodMembers
        \ contained transparent fold
endif

" Keyword messages
syn region stMethod
    \ matchgroup=stMessagePattern
    \ start=/\%(\K\k*:\s*\K\k*\_s\+\)*\K\k*:\s*\K\k*\%(\_s\+\)\@=/
    \ end=/!/
    \ contains=@stMethodMembers
    \ contained transparent fold

" Smalltalk/X-style primitives {{{1
" -----------------------------------------------------------------------------

if exists("st_stx_style_primitives")
    syn include @cCode syntax/c.vim

    syn region stStxPrimitive
        \ matchgroup=stStxPrimitiveDelims
        \ start=/%{/ end=/%}/
        \ contains=@cCode
        \ transparent fold

    syn cluster stMethodMembers add=stStxPrimitive

    syn region stPrimitiveDefinitions
        \ matchgroup=stMethodDelims
        \ start=
            \/!\%(\K\k*\%(\.\|::\)\)*
            \\K\k*\s\+\%(class\s\+\)\?
            \primitiveDefinitions\s*!/
        \ end=/!\_s\+!/
        \ contains=stError,stComment,stStxPrimitive
        \ transparent fold

    syn region stPrimitiveFunctions
        \ matchgroup=stMethodDelims
        \ start=
            \/!\%(\K\k*\%(\.\|::\)\)*
            \\K\k*\s\+\%(class\s\+\)\?
            \primitiveFunctions\s*!/
        \ end=/!\_s\+!/
        \ contains=stError,stComment,stStxPrimitive
        \ transparent fold
endif

" Strings and characters {{{1
" -----------------------------------------------------------------------------

" Format spec, yeah right.  :)
syn match stFormatSpec /%\d/ contained

syn match stSpecialChar /''/ contained

syn region stString
    \ matchgroup=stString
    \ start=/'/ skip=/''/ end=/'/
    \ contains=stSpecialChar,stFormatSpec,@Spell

syn match stCharacter /$./

" stLiterals holds all, uh, literals.
syn cluster stLiterals contains=stString,stCharacter
syn cluster stMethodMembers add=stString,stCharacter

" Symbols {{{1
" -----------------------------------------------------------------------------

syn region stSymbol
    \ matchgroup=stSymbol
    \ start=/#'/ skip=/''/ end=/'/
    \ contains=stSpecialChar

syn match stSelector display /#\K\k*/

if !exists("st_three_character_binary_selectors")
    syn match stSelector display /#[%&*+,/<=>?@\\~|-]\{1,2}/
else
    syn match stSelector display /#[%&*+,/<=>?@\\~|-]\{1,3}/
endif

syn match stSelector display /#\%(\K\k*:\)\+/

syn cluster stLiterals add=stSymbol,stSelector
syn cluster stMethodMembers add=stSymbol,stSelector

" Numbers {{{1
" -----------------------------------------------------------------------------

syn match stInteger display /\%(-\s*\)\?\<\d\+\>/
if !exists("st_sign_after_radix")
    syn match stRadixInteger display /\%(-\s*\)\?\<\d\+r[0-9A-Z]\+\>/
else
    syn match stRadixInteger display /\<\d\+r-\?[0-9A-Z]\+\>/
endif
syn match stFloat display /\%(-\s*\)\?\<\d\+\.\d\+\%([edq]-\?\d\+\)\?\>/
syn match stScaledDecimal display /\%(-\s*\)\?\<\d\+\%(\.\d\+\)\?s\%(\d\+\)\?\>/

" syn match stNumber
"     \ /-\?\<\d\+\%(\.\d\+\)\?\%([deqs]\%(-\?\d\+\)\?\)\?\>/
"     \ display
" syn match stNumber
"     \ /\<\d\+r-\?[0-9A-Z]\+\%(\.[0-9A-Z]\+\)\?\%([deqs]\%(-\?\d\+\)\?\)\?\>/
"     \ display

syn cluster stNumber contains=st\%(Radix\)\?Integer,stFloat,stScaledDecimal

syn cluster stLiterals add=@stNumber
syn cluster stMethodMembers add=@stNumber

" Highlighting mismatched parentheses {{{1
" -----------------------------------------------------------------------------

syn region stUnit matchgroup=stUnitDelims start=/(/ end=/)/ transparent

syn cluster stMethodMembers add=stUnit

" Arrays {{{1
" -----------------------------------------------------------------------------

" Its ugly look is entirely stEval's fault.
syn match stArrayConst /\%(#\[\|#\@<!#(\)/me=e-1 nextgroup=stArray,stByteArray

syn region stArray
    \ matchgroup=stArrayDelims
    \ start=/(/ end=/)/
    \ contains=@stLiterals,stComment,stArray,stByteArray,stNil,stBoolean
    \ contained transparent fold
syn region stByteArray
    \ matchgroup=stByteArrayDelims
    \ start=/\[/ end=/\]/
    \ contains=@stNumber,stComment
    \ contained transparent fold

syn cluster stLiterals add=stArrayConst
syn cluster stMethodMembers add=stArrayConst

" "Braced" Array literals {{{1
" -----------------------------------------------------------------------------

syn region stCollect
    \ matchgroup=stCollectDelims
    \ start=/{/ end=/}/
    \ contains=@stLiterals,stCollect,stBlock,stNil,stKeyword,stBoolean,stAssign,stComment,stBangError
    \ transparent fold

syn cluster stMethodMembers add=stCollect

" Variable binding and "eval" literals {{{1
" -----------------------------------------------------------------------------

syn match stBindingDelims /[{}]/ contained
syn match stBinding /#{\s*\%(\K\k*\.\)*\K\k*\s*}/ contains=stBindingDelims

syn region stEval
    \ matchgroup=stEvalDelims
    \ start=/##(/ end=/)/
    \ contains=@stMethodMembers
    \ transparent

syn cluster stLiterals add=stBinding,stEval
syn cluster stMethodMembers add=stBinding,stEval

" Pretty-printing for various groups {{{1
" -----------------------------------------------------------------------------

syn match stDelimiter /|/ contained display
syn match stIdentifier /\K\k*/ contained display

" Temporaries {{{1
" -----------------------------------------------------------------------------

" To FIXME or not to FIXME?  I will match at "boolean | boolean | boolean".
" syn region stTemps
"     \ matchgroup=stTempDelims
"     \ start=/|/ end=/|/
"     \ contains=stIdentifier,stError

syn match stTemps
    \ /|\s*\%(\K\k*\_s\+\)*\K\k*\s*|/
    \ contains=stIdentifier,stDelimiter

syn cluster stMethodMembers add=stTemps

" Blocks {{{1
" -----------------------------------------------------------------------------

" I made up the name.
syn match stBlockConditional /\<whileTrue\>:\?/ contained
syn match stBlockConditional /\<whileFalse\>:\?/ contained

syn match stBlockTemps
    \ /\[\@<=\_s*\%(:\K\k*\s\+\)*:\K\k*\s*|/
    \ contains=stIdentifier,stDelimiter
    \ contained transparent

syn region stBlock
    \ matchgroup=stBlockDelims
    \ start=/\[/ end=/\]/
    \ contains=@stMethodMembers,stBlockTemps,stBangError
    \ nextgroup=stBlockConditional skipempty skipwhite
    \ transparent fold

syn cluster stMethodMembers add=stBlock

" Assignment and return operators {{{1
" -----------------------------------------------------------------------------

syn match stAssign /\%(\<\K\k*\_s*\)\@<=:=/
syn match stAnswer /\^/

syn cluster stMethodMembers add=stAssign,stAnswer

" Common Boolean methods {{{1
" -----------------------------------------------------------------------------

syn match stConditional /\<ifTrue:/
syn match stConditional /\<ifFalse:/
syn match stConditional /\<and:/
syn match stConditional /\<eqv:/
syn match stConditional /\<or:/
syn match stConditional /\<xor:/
syn match stConditional /\<not\>/

syn cluster stMethodMembers add=stConditional

" Link syntax groups {{{1
" -----------------------------------------------------------------------------

hi def link stAnswer           Statement
hi def link stArrayConst       Constant
hi def link stArrayDelims      Delimiter
hi def link stAssign           Operator
hi def link stBangError        Error
hi def link stBinding          Constant
hi def link stBindingDelims    Delimiter
hi def link stBlockConditional Conditional
hi def link stBlockDelims      Delimiter
hi def link stBoolean          Boolean
hi def link stByteArrayDelims  Delimiter
hi def link stCharacter        Character
hi def link stCollectDelims    Delimiter
hi def link stComment          Comment
hi def link stConditional      Conditional
hi def link stDelimError       Error
hi def link stDelimiter        Delimiter
hi def link stError            Error
hi def link stEvalDelims       PreProc
hi def link stFloat            Float
hi def link stFormatSpec       Special
hi def link stIdentifier       Identifier
hi def link stInteger          Number
hi def link stKeyword          Keyword
hi def link stMessagePattern   Function
hi def link stMethodDelims     Statement
hi def link stNil              Keyword
hi def link stRadixInteger     Number
hi def link stScaledDecimal    Float
hi def link stSelector         Constant
hi def link stSpecialChar      SpecialChar
hi def link stString           String
hi def link stSymbol           Constant
hi def link stTempDelims       Delimiter
hi def link stTodo             Todo

if exists("st_stx_style_primitives")
    hi def link stStxPrimitiveDelims Delimiter
endif

" Finalization {{{1
" -----------------------------------------------------------------------------

let b:current_syntax = "st"

let &cpo = s:cpo_save
unlet s:cpo_save

" -----------------------------------------------------------------------------
"}}}1

" vim:set sts=4 et ff=unix fdm=marker:
