set nocompatible                " choose no compatibility with 
"set legacy vi

set ttyfast
set ttyscroll=3
set lazyredraw

syntax enable
set encoding=utf-8
set showcmd                     " display incomplete commands
filetype plugin indent on       " load file type plugins + indentation

"" Whitespace
set wrap                      " don't wrap lines
set linebreak
set nolist
set backspace=indent,eol,start  " backspace through everything in insert mode
set textwidth=0
set wrapmargin=0

set tabstop=2 
set softtabstop=2
set shiftwidth=2
set expandtab



"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter
set smartindent
set number     " show line numbers!
set ai          " Auto identing

"" No more arrow keys
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" Easy Resize
map <up> <c-w>-
map <down> <c-w>+
map <right> <c-w>>
map <left> <c-w><

" Smooth scrolling
map <PageDown> :call SmoothPageScrollDown()<CR> 
map <PageDown> :call SmoothPageScrollDown()<CR> 

map! <Ctrl-B>   :call SmoothPageScrollUp()<CR> 
map! <Ctrl-F>   :call SmoothPageScrollUp()<CR> 





" 256 Colors with Wombat
set t_Co=256
colorscheme louver
"colorscheme Mustang


" set list!
set listchars=tab:+-
" trail:.,precedes:<,extends:>,eol:$
"

function Dark()
	:colorscheme Mustang 
endfunction

command Light colorscheme summerfruit256 
command Dark exec Dark() 




"command Dark  colorscheme custom 
command XlibFunctions syn keyword Directory XDraw XRebindKeysym XrmLocaleOfDatabase XDrawArc XRecolorCursor XrmMergeDatabases XDrawArcs XReconfigureWMWindow XrmNameToString XDrawDashed XRectInRegion XrmParseCommand XDrawFilled XRefreshKeyboardMapping XrmPermStringToQuark XDrawImageString XRemoveConnectionWatch XrmPutFileDatabase XDrawImageString16 XRemoveFromSaveSet XrmPutLineResource XDrawLine XRemoveHost XrmPutResource XDrawLines XRemoveHosts XrmPutStringResource XDrawPatterned XReparentWindow XrmQGetResource XDrawPoint XResetScreenSaver XrmQGetSearchList XDrawPoints XResizeWindow XrmQGetSearchResource XDrawRectangle XResourceManagerString XrmQPutResource XDrawRectangles XRestackWindows XrmQPutStringResource XDrawSegments XRootWindow XrmQuarkToString XDrawString XRootWindowOfScreen XrmRepresentationToString XDrawString16 XRotateBuffers XrmSetDataBase XDrawText XRotateWindowProperties XrmSetDatabase XDrawText16 XRotateWindowProperties XrmStringToBindingQuarkList XDrawTiled XSaveContext XrmStringToClass XESetBeforeFlush XScreenCount XrmStringToClassList XESetCloseDisplay XScreenNumberOfScreen XrmStringToName XESetCloseDisplay XScreenResourceString XrmStringToNameList XESetCopyGC XScreensOfDisplay XrmStringToQuark XESetCreateFont XSelectInput XrmStringToQuarkList XESetCreateGC XSendEvent XrmStringToRepresentation XESetCreateGC XServerVendor XrmUniqueQuark XESetError XSetAccessControl XwcFreeStringList XESetErrorString XSetAfterFunction XwcTextListToTextProperty XESetEventToWire XSetArcMode XwcTextPropertyToTextList XESetFlushGC XSetBackground _XSetLastRequestRead XESetFreeFont XSetClassHint _XSetLastRequestRead XESetFreeGC XSetClipMask XESetPrintErrorValues XSetClipOrigin XCirculateSubwindowsUp XListFonts XcmsCIELabToCIEXYZ XClearArea XListFontsWithInfo XcmsCIELuvQueryMaxC XClearVertexFlag XListHosts XcmsCIELuvQueryMaxL XClearWindow XListInstalledColormaps XcmsCIELuvQueryMaxLC XClipBox XListPixmapFormats XcmsCIELuvQueryMinL XCloseDisplay XListProperties XcmsCIELuvToCIEuvY XConfigureWindow XListProperties XcmsCIEXYZToCIELab XConnectionNumber XLoadFont XcmsCIEXYZToCIEuvY XConvertCase XLoadQueryFont XcmsCIEXYZToCIExyY XConvertSelection XLockDisplay XcmsCIEXYZToRGBi XCopyArea XLookUpAssoc XcmsCIEuvYToCIELuv XCopyColormapAndFree XLookupColor XcmsCIEuvYToCIEXYZ XCopyGC XLookupKeysym XcmsCIEuvYToTekHVC XCopyPlane XLookupString XcmsCIExyYToCIEXYZ XCreateAssocTable XLowerWindow XcmsClientWhitePointOfCCC XCreateBitmapFromData XMakeAssoc XcmsClientWhitePointOfCCC XCreateColormap XMapRaised XcmsConvertColors XCreateFontCursor XMapSubwindows XcmsCreateCCC XCreateFontSet XMapWindow XcmsDefaultCCC XCreateGC XMaskEvent XcmsDisplayOfCCC XCreateGlyphCursor XMatchVisualInfo XcmsFormatOfPrefix XCreateImage XMaxCmapsOfScreen XcmsFreeCCC XCreatePixmap XMaxRequestSize XcmsLookupColor XCreatePixmapCursor XMinCmapsOfScreen XcmsPrefixOfFormat XCreatePixmapFromBitmapData XMoveResizeWindow XcmsQueryBlack XCreateRegion XMoveWindow XcmsQueryBlue XCreateSimpleWindow XNewModifiermap XcmsQueryColor XCreateWindow XNextEvent XcmsQueryColors XDefaultColormapOfScreen XNextRequest XcmsQueryGreen XDefaultDepthOfScreen XNoOp XcmsQueryRed XDefaultGC XOffsetRegion XcmsQueryWhite XDefaultGCOfScreen XOpenDisplay XcmsRGBToRGBi XDefaultRootWindow XParseColor XcmsRGBiToCIEXYZ XDefaultScreen XParseGeometry XcmsRGBiToRGB XDefaultScreenOfDisplay XPeekEvent XcmsScreenNumberOfCCC XDefaultString XPeekIfEvent XcmsScreenWhitePointOfCCC XDefaultVisual XPending XcmsSetCCCOfColormap XDefaultVisualOfScreen XPlanesOfScreen XcmsSetCompressionProc XDefineCursor XPointInRegion XcmsSetWhiteAdjustProc XDeleteAssoc XPolygonRegion XcmsSetWhitePoint XDeleteContext XProcessInternalConnection XcmsStoreColor XDeleteModifiermapEntry XProtocolRevision XcmsStoreColors XDeleteProperty XProtocolVersion XcmsTekHVCQueryMaxC XDeleteProperty XPutBackEvent XcmsTekHVCQueryMaxV XDestroyAssocTable XPutImage XcmsTekHVCQueryMaxVC XDestroyImage XPutPixel XcmsTekHVCQueryMaxVSamples XDestroyRegion XQLength XcmsTekHVCQueryMinV XDestroySubwindows XQueryBestCursor XcmsTekHVCToCIEuvY XDestroyWindow XQueryBestSize XcmsVisualOfCCC XDisableAccessControl XQueryBestStipple XmbSetWMProperties XDisplayCells XQueryBestTile XmbTextListToTextProperty XDisplayHeight XQueryColor XmbTextPropertyToTextList XDisplayHeightMM XQueryColors Xpermalloc XDisplayKeycodes XQueryExtension XrmClassToString XDisplayMotionBufferSize XQueryFont XrmCombineDatabase XDisplayName XQueryKeymap XrmCombineFileDatabase XDisplayOfScreen XQueryPointer XrmDestroyDatabase XDisplayPlanes XQueryTextExtents XrmEnumerateDatabase XDisplayString XQueryTextExtents16 XrmGetDatabase XDisplayWidth XQueryTree XrmGetFileDatabase XDisplayWidthMM XRaiseWindow XrmGetResource XDoesBackingStore XReadBitmapFile XrmGetStringDatabase XDoesSaveUnders XReadBitmapFileData XrmInitialize ProtocolVersion XGetImage XSetWindowBorderPixmap QLength XGetInputFocus XSetWindowBorderWidth RootWindow XGetKeyboardControl XSetWindowColormap RootWindowOfScreen XGetKeyboardMapping XSetZoomHints ScreenCount XGetModifierMapping XShrinkRegion ScreenNumberOfCCC XGetMotionEvents XStoreBuffer ScreenWhitePointOfCCC XGetNormalHints XStoreBytes ScreensOfDisplay XGetPixel XStoreColor ServerVendor XGetPointerControl XStoreColors VendorRelease XGetPointerMapping XStoreName VertexDrawLastPoint XGetRGBColormap XStoreNamedColor VisualOfCCC XGetRGBColormaps XStringListToTextProperty WhitePixel XGetScreenSaver XStringToKeysym WhitePixelOfScreen XGetSelectionOwner XSubImage WidthMMOfScreen XGetSizeHints XSubtractRegion WidthOfScreen XGetStandardColormap XSync XActivateScreenSaver XGetSubImage XSynchronize XAddConnectionWatch XGetTextProperty XTextExtents XAddExtension XGetTransientForHint XTextExtents16 XAddHost XGetVisualInfo XTextListToTextProperty XAddHosts XGetWMClientMachine XTextPropertyToStringList XAddPixel XGetWMColormapWindows XTextWidth XAddToSaveSet XGetWMHints XTextWidth16 XAllPlanes XGetWMIconName XTranslateCoordinates XAllocClassHint XGetWMName XUndefineCursor XAllocColor XGetWMNormalHints XUngrabButton XAllocColorCells XGetWMProtocols XUngrabKey XAllocColorPlanes XGetWMSizeHints XUngrabKeyboard XAllocIconSize XGetWindowAttributes XUngrabPointer XAllocNamedColor XGetWindowProperty XUngrabServer XAllocSizeHints XGetWindowProperty XUninstallColormap XAllocStandardColormap XGetZoomHints XUnionRectWithRegion XAllocWMHints XGrabButton XUnionRegion XAllowEvents XGrabKey XUniqueContext XAppendVertex XGrabKeyboard XUnloadFont XAutoRepeatOff XGrabPointer XUnlockDisplay XAutoRepeatOn XGrabServer XUnmapSubwindows XBell XHeightMMOfScreen XUnmapWindow XBitmapBitOrder XHeightOfScreen XVendorRelease XBitmapPad XIconifyWindow XVisualIDFromVisual XBitmapUnit XIfEvent XWMGeometry XBlackPixel  XIfEvent XWarpPointer XBlackPixelOfScreen XImageByteOrder XWhitePixel XCellsOfScreen XInitExtension XWhitePixelOfScreen XChangeActivePointerGrab XInitImage XWidthMMOfScreen XChangeGC XInitThreads XWidthOfScreen XChangeKeyboardControl XInsertModifiermapEntry XWindowEvent XChangeKeyboardMapping XInstallColormap XWithdrawWindow XChangePointerControl XInternAtom XWriteBitmapFile XChangeProperty XInternAtoms XXorRegion XChangeSaveSet XInternalConnectionNumbers XcmsAddColorSpace XChangeWindowAttributes XIntersectRegion XcmsAddFunctionSet XCheckIfEvent XKeycodeToKeysym XcmsAllocColor XCheckMaskEvent XKeysymToKeycode XcmsAllocNamedColor XCheckTypedEvent XKeysymToString XcmsCCCOfColormap XCheckTypedWindowEvent XKillClient XcmsCIELabQueryMaxC XCheckWindowEvent XLastKnownRequestProcessed XcmsCIELabQueryMaxL XCirculateSubwindows XListDepths XcmsCIELabQueryMaxLC XCirculateSubwindowsDown XListExtensions XcmsCIELabQueryMinL AllPlanes XESetWireToError XSetClipRectangles BitmapBitOrder XESetWireToEvent XSetCloseDownMode BitmapPad XEmptyRegion XSetCommand BitmapUnit XEnableAccessControl XSetDashes BlackPixel XEqualRegion XSetErrorHandler BlackPixelOfScreen XEventMaskOfScreen XSetFillRule CellsOfScreen XEventsQueued XSetFillStyle ClientWhitePointOfCCC XExtendedMaxRequestSize XSetFont ConnectionNumber XFetchBuffer XSetFontPath DefaultColormap XFetchBytes XSetForeground DefaultColormapOfScreen XFetchName XSetFunction DefaultDepth XFillArc XSetGraphicsExposures DefaultDepthOfScreen XFillArcs XSetIOErrorHandler DefaultGC XFillPolygon XSetIconName DefaultGCOfScreen XFillRectangle XSetIconSizes DefaultRootWindow XFillRectangles XSetInputFocus DefaultScreen XFindContext XSetLineAttributes DefaultScreenOfDisplay XFlush XSetModifierMapping DefaultVisual XFlushGC XSetNormalHints DefaultVisualOfScreen XForceScreenSaver XSetPlaneMask DisplayCells XFree XSetPointerMapping DisplayHeight XFreeColormap XSetProperty DisplayHeightMM XFreeColors XSetRGBColormaps DisplayOfCCC XFreeCursor XSetRGBColormaps DisplayOfScreen XFreeExtensionList XSetRegion DisplayPlanes XFreeFont XSetScreenSaver DisplayString XFreeFontInfo XSetSelectionOwner DisplayWidth XFreeFontNames XSetSizeHints DisplayWidthMM XFreeFontPath XSetStandardColormap DoesBackingStore XFreeGC XSetStandardProperties DoesSaveUnders XFreeModifiermap XSetState EventMaskOfScreen XFreeModifiermap XSetStipple HeightMMOfScreen XFreePixmap XSetSubwindowMode HeightOfScreen XFreeStringList XSetTSOrigin ImageByteOrder XGContextFromGC XSetTextProperty InitExtension XGeometry XSetTile IsCursorKey XGetAtomName XSetTransientForHint IsFunctionKey XGetAtomNames XSetWMClientMachine IsKeypadKey XGetClassHint XSetWMColormapWindows IsMiscFunctionKey XGetCommand XSetWMHints IsModifierKey XGetDefault XSetWMIconName IsPFKey XGetErrorDatabaseText XSetWMName IsPrivateKeypadKey XGetErrorText XSetWMNormalHints LastKnownRequestProcessed XGetFontPath XSetWMProperties MaxCmapsOfScreen XGetFontProperty XSetWMProtocols MinCmapsOfScreen XGetGCValues XSetWMSizeHints NextRequest XGetGeometry XSetWindowBackground PlanesOfScreen XGetIconName XSetWindowBackgroundPixmap ProtocolRevision XGetIconSizes XSetWindowBorder



"au VimEnter * RainbowParenthesesToggleAll
au VimEnter * syn keyword ErrorMsg Display Window XEvent Cursor XButtonEvent XWindowAttributes XMapRequestEvent GC True False
au VimEnter * syn keyword ErrorMsg xcb_connection_t xcb_screen_t xcb_drawable_t xcb_gcontext_t xcb_generic_event_t
au VimEnter * XlibFunctions

command XcbFunctions syn keyword Directory xcb_connect xcb_setup_roots_iterator xcb_generate_id xcb_create_gc xcb_rectangle_t


"au Syntax * RainbowParenthesesLoadRound
"au Syntax * RainbowParenthesesLoadSquare
"au Syntax * RainbowParenthesesLoadBraces



" Cursorline 
set cursorline
"set cursorcolumn

" Mouse for Normal and Visual Mode only
set mouse=nv

set backup
set backupdir=~/.vim/backup
set directory=~/.vim/tmp  

" Fix the * Clipboard
set clipboard=unnamed

set wildmenu "Tab completion status bar

call pathogen#helptags()
call pathogen#runtime_append_all_bundles()
call pathogen#infect()


" Colored Statusbar for Inser/Command
" first, enable status line always
set laststatus=2

" now set it up to change the status line based on mode
if version >= 700
	au InsertEnter * hi StatusLine term=reverse ctermbg=4 gui=undercurl guisp=Magenta
	au InsertEnter * silent ! insertMode & 
	au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
	au InsertLeave * silent ! clearMode &

	au FocusLost * silent !clearMode &

endif


" Status Bar
set laststatus=2  " always show the status bar
set statusline=%<%f\ %h%w%m%r%y\ %{&ff}\ %=L:%l/%L\ (%p%%)\ C:%c%V\ B:%o\ F:%{foldlevel('.')} 

set foldlevel=3000
"set mouse=a
"

hi CSVColumnEven term=bold ctermbg=0 ctermfg=10
hi CSVColumnOdd term=bold ctermbg=2 ctermfg=0

"highlight OverLength ctermbg=none ctermfg=red
"match OverLength /\%81v.\+/




fixdel
imap <Del> <BS>

autocmd FileType plaintext setlocal spell spelllang=en_us
autocmd FileType markdown setlocal spell spelllang=en_us
