local l = require('lexer')
local token, word_match = l.token, l.word_match
local P, R, S, C = lpeg.P, lpeg.R, lpeg.S, lpeg.C
local M = {_NAME = 'lisp'}

local line_comment = ';' * l.nonnewline^0
local block_comment = '#_(' * (l.any - ')')^0 * P(')')
local comment = token(
  l.COMMENT, 
  line_comment + block_comment
);

local firstargchars = (
  l.any - ' ' - ')' - '('
);
local secondargchars = (
  l.any - ' ' - ')' - '(' - '[' - ']' - '"'
);

local fn_call_arg_one = token(
  l.KEYWORD, 
  lpeg.B('(') * (firstargchars)^1
);
local fn_call_arg_two  = token(
  l.TYPE, 
  (' ' * secondargchars^1)^-1
);

M._rules = {
  {'fn_call', fn_call_arg_one * fn_call_arg_two },
  {'comment', comment},
};

return M;
