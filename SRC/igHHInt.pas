unit igHHInt;

// HtmlHelpLibError variable added by Max Masyutin (February, 2000).



(*******************************************************************************
*                                  igHHInt.pas                                 *
* HTML Help API unit, translated from HtmlHelp.h by Igor Glukhov, developer of *
* ProHelp for Delphi & C++Builder.                                             *
* Using ProHelp you can make your app's context-sensitive help as professional *
* as it can be without additional coding.                                      *
* Last Update: May 19, 1999                                                    *
* Internet: http://www.igweb.pair.com                                          *
* Email: igbox@pair.com                                                        *
* Fell free to contact us.                                                     *
* HTML HELP home page:                                                         *
* http://msdn.microsoft.com/workshop/author/htmlhelp/default.asp               *
*******************************************************************************)

{***************************  CUSTOMISATION SECTION  **************************}

{.$DEFINE TRIAL} //Comment or delete this string to disable the Error Message                      //property and warning message.

{******************************************************************************}


interface

uses Windows,Graphics,Dialogs
{$IFDEF TRIAL}
  ,ShellApi,Controls
{$ENDIF}
  ;

// Commands to pass to HtmlHelp()
const

HH_DISPLAY_TOPIC        = $0000;
HH_HELP_FINDER          = $0000;  // WinHelp equivalent
HH_DISPLAY_TOC          = $0001;  // Selects the TOC tab in the Navigation pane
HH_DISPLAY_INDEX        = $0002;  // Selects the Index tab in the Navigation pane
HH_DISPLAY_SEARCH       = $0003;  // Selects the Search tab in the Navigation pane
HH_SET_WIN_TYPE         = $0004;
HH_GET_WIN_TYPE         = $0005;
HH_GET_WIN_HANDLE       = $0006;
HH_ENUM_INFO_TYPE       = $0007;  // Get Info type name, call repeatedly to enumerate, -1 at end
HH_SET_INFO_TYPE        = $0008;  // Add Info type to filter.
HH_SYNC                 = $0009;
HH_ADD_NAV_UI           = $000A;  // not currently implemented
HH_ADD_BUTTON           = $000B;  // not currently implemented
HH_GETBROWSER_APP       = $000C;  // not currently implemented
HH_KEYWORD_LOOKUP       = $000D;
HH_DISPLAY_TEXT_POPUP   = $000E;  // display string resource id or text in a popup window
HH_HELP_CONTEXT         = $000F;  // display mapped numeric value in dwData
HH_TP_HELP_CONTEXTMENU  = $0010;  // text popup help, same as WinHelp HELP_CONTEXTMENU
HH_TP_HELP_WM_HELP      = $0011;  // text popup help, same as WinHelp HELP_WM_HELP
HH_CLOSE_ALL            = $0012;  // close all windows opened directly or indirectly by the caller
HH_ALINK_LOOKUP         = $0013;  // ALink version of HH_KEYWORD_LOOKUP
HH_GET_LAST_ERROR       = $0014;  // not currently implemented // See HHERROR.h
HH_ENUM_CATEGORY        = $0015;  // Get category name, call repeatedly to enumerate, -1 at end
HH_ENUM_CATEGORY_IT     = $0016;  // Get category info type members, call repeatedly to enumerate, -1 at end
HH_RESET_IT_FILTER      = $0017;  // Clear the info type filter of all info types.
HH_SET_INCLUSIVE_FILTER = $0018;  // set inclusive filtering method for untyped topics to be included in display
HH_SET_EXCLUSIVE_FILTER = $0019;  // set exclusive filtering method for untyped topics to be excluded from display
HH_SET_GUID             = $001A;  // For Microsoft Installer -- dwData is a pointer to the GUID string
HH_INITIALIZE           = $001C;  // Initializes the help system.
HH_UNINITIALIZE         = $001D;  // Uninitializes the help system.
HH_PRETRANSLATEMESSAGE  = $00fd;  // Pumps messages. (NULL, NULL, MSG*).
HH_SET_GLOBAL_PROPERTY  = $00fc;  // Set a global property. (NULL, NULL, HH_GPROP)


HH_INTERNAL             = $00FF;  // Used internally.

HHWIN_PROP_TAB_AUTOHIDESHOW =(1 shl 0);    // Automatically hide/show tri-pane window
HHWIN_PROP_ONTOP            =(1 shl 1);    // Top-most window
HHWIN_PROP_NOTITLEBAR       =(1 shl 2);    // no title bar
HHWIN_PROP_NODEF_STYLES     =(1 shl 3);    // no default window styles (only HH_WINTYPE.dwStyles)
HHWIN_PROP_NODEF_EXSTYLES   =(1 shl 4);    // no default extended window styles (only HH_WINTYPE.dwExStyles)
HHWIN_PROP_TRI_PANE         =(1 shl 5);    // use a tri-pane window
HHWIN_PROP_NOTB_TEXT        =(1 shl 6);    // no text on toolbar buttons
HHWIN_PROP_POST_QUIT        =(1 shl 7);    // post WM_QUIT message when window closes
HHWIN_PROP_AUTO_SYNC        =(1 shl 8);    // automatically ssync contents and index
HHWIN_PROP_TRACKING         =(1 shl 9);    // send tracking notification messages
HHWIN_PROP_TAB_SEARCH       =(1 shl 10);   // include search tab in navigation pane
HHWIN_PROP_TAB_HISTORY      =(1 shl 11);   // include history tab in navigation pane
HHWIN_PROP_TAB_FAVORITES    =(1 shl 12);   // include favorites tab in navigation pane
HHWIN_PROP_CHANGE_TITLE     =(1 shl 13);   // Put current HTML title in title bar
HHWIN_PROP_NAV_ONLY_WIN     =(1 shl 14);   // Only display the navigation window
HHWIN_PROP_NO_TOOLBAR       =(1 shl 15);   // Don't display a toolbar
HHWIN_PROP_MENU             =(1 shl 16);   // Menu
HHWIN_PROP_TAB_ADVSEARCH    =(1 shl 17);   // Advanced FTS UI.
HHWIN_PROP_USER_POS         =(1 shl 18);   // After initial creation, user controls window size/position
HHWIN_PROP_TAB_CUSTOM1      =(1 shl 19);   // Use custom tab #1
HHWIN_PROP_TAB_CUSTOM2      =(1 shl 20);   // Use custom tab #2
HHWIN_PROP_TAB_CUSTOM3      =(1 shl 21);   // Use custom tab #3
HHWIN_PROP_TAB_CUSTOM4      =(1 shl 22);   // Use custom tab #4
HHWIN_PROP_TAB_CUSTOM5      =(1 shl 23);   // Use custom tab #5
HHWIN_PROP_TAB_CUSTOM6      =(1 shl 24);   // Use custom tab #6
HHWIN_PROP_TAB_CUSTOM7      =(1 shl 25);   // Use custom tab #7
HHWIN_PROP_TAB_CUSTOM8      =(1 shl 26);   // Use custom tab #8
HHWIN_PROP_TAB_CUSTOM9      =(1 shl 27);   // Use custom tab #9
HHWIN_TB_MARGIN             =(1 shl 28);   // the window type has a margin

HHWIN_PARAM_PROPERTIES    = (1 shl 1);   // valid fsWinProperties
HHWIN_PARAM_STYLES        = (1 shl 2);   // valid dwStyles
HHWIN_PARAM_EXSTYLES      = (1 shl 3);   // valid dwExStyles
HHWIN_PARAM_RECT          = (1 shl 4);   // valid rcWindowPos
HHWIN_PARAM_NAV_WIDTH     = (1 shl 5);   // valid iNavWidth
HHWIN_PARAM_SHOWSTATE     = (1 shl 6);   // valid nShowState
HHWIN_PARAM_INFOTYPES     = (1 shl 7);   // valid apInfoTypes
HHWIN_PARAM_TB_FLAGS      = (1 shl 8);   // valid fsToolBarFlags
HHWIN_PARAM_EXPANSION     = (1 shl 9);   // valid fNotExpanded
HHWIN_PARAM_TABPOS        = (1 shl 10);  // valid tabpos
HHWIN_PARAM_TABORDER      = (1 shl 11);  // valid taborder
HHWIN_PARAM_HISTORY_COUNT = (1 shl 12);  // valid cHistory
HHWIN_PARAM_CUR_TAB       = (1 shl 13);  // valid curNavType

HHWIN_BUTTON_EXPAND       = (1 shl 1);   // Expand/contract button
HHWIN_BUTTON_BACK         = (1 shl 2);   // Back button
HHWIN_BUTTON_FORWARD      = (1 shl 3);   // Forward button
HHWIN_BUTTON_STOP         = (1 shl 4);   // Stop button
HHWIN_BUTTON_REFRESH      = (1 shl 5);   // Refresh button
HHWIN_BUTTON_HOME         = (1 shl 6);   // Home button
HHWIN_BUTTON_BROWSE_FWD   = (1 shl 7);   // not implemented
HHWIN_BUTTON_BROWSE_BCK   = (1 shl 8);   // not implemented
HHWIN_BUTTON_NOTES        = (1 shl 9);   // not implemented
HHWIN_BUTTON_CONTENTS     = (1 shl 10);  // not implemented
HHWIN_BUTTON_SYNC         = (1 shl 11);  // Sync button
HHWIN_BUTTON_OPTIONS      = (1 shl 12);  // Options button
HHWIN_BUTTON_PRINT        = (1 shl 13);  // Print button
HHWIN_BUTTON_INDEX        = (1 shl 14);  // not implemented
HHWIN_BUTTON_SEARCH       = (1 shl 15);  // not implemented
HHWIN_BUTTON_HISTORY      = (1 shl 16);  // not implemented
HHWIN_BUTTON_BOOKMARKS    = (1 shl 17);  // not implemented
HHWIN_BUTTON_JUMP1        = (1 shl 18);
HHWIN_BUTTON_JUMP2        = (1 shl 19);
HHWIN_BUTTON_ZOOM         = (1 shl 20);
HHWIN_BUTTON_TOC_NEXT     = (1 shl 21);
HHWIN_BUTTON_TOC_PREV     = (1 shl 22);

HHWIN_DEF_BUTTONS =  HHWIN_BUTTON_EXPAND
                  or HHWIN_BUTTON_BACK
                  or HHWIN_BUTTON_OPTIONS
                  or HHWIN_BUTTON_PRINT;

// Button IDs

IDTB_EXPAND      = 200;
IDTB_CONTRACT    = 201;
IDTB_STOP        = 202;
IDTB_REFRESH     = 203;
IDTB_BACK        = 204;
IDTB_HOME        = 205;
IDTB_SYNC        = 206;
IDTB_PRINT       = 207;
IDTB_OPTIONS     = 208;
IDTB_FORWARD     = 209;
IDTB_NOTES       = 210; // not implemented
IDTB_BROWSE_FWD  = 211;
IDTB_BROWSE_BACK = 212;
IDTB_CONTENTS    = 213; // not implemented
IDTB_INDEX       = 214; // not implemented
IDTB_SEARCH      = 215; // not implemented
IDTB_HISTORY     = 216; // not implemented
IDTB_BOOKMARKS   = 217; // not implemented
IDTB_JUMP1       = 218;
IDTB_JUMP2       = 219;
IDTB_CUSTOMIZE   = 221;
IDTB_ZOOM        = 222;
IDTB_TOC_NEXT    = 223;
IDTB_TOC_PREV    = 224;

// Notification codes

HHN_FIRST = -860;
HHN_LAST  = -879;

HHN_NAVCOMPLETE   = (HHN_FIRST-0);
HHN_TRACK         = (HHN_FIRST-1);
HHN_WINDOW_CREATE = (HHN_FIRST-2);

type

HH_POPUP = packed record
  cbStruct:      integer;  // sizeof this structure
  hinst:         HINST;    // instance handle for string resource
  idString:      cardinal; // string resource id, or text id if pszFile is specified in HtmlHelp call
  pszText:       PChar;    // used if idString is zero
  pt:            TPoint;   // top center of popup window
  clrForeground: TColor;   // use -1 for default
  clrBackground: TColor;   // use -1 for default
  rcMargins:     TRect;    // amount of space between edges of window and text, -1 for each member to ignore
  pszFont:       PChar;    // facename, point size, char set, BOLD ITALIC UNDERLINE
end;
THHPopUp = HH_POPUP;

HH_AKLINK = packed record
  cbStruct:     integer;  // sizeof this structure
  fReserved:    BOOL;     // must be FALSE (really!)
  pszKeywords:  PChar;    // semi-colon separated keywords
  pszUrl:       PChar;    // URL to jump to if no keywords found (may be NULL)
  pszMsgText:   PChar;    // Message text to display in MessageBox if pszUrl is NULL and no keyword match
  pszMsgTitle:  PChar;    // Message text to display in MessageBox if pszUrl is NULL and no keyword match
  pszWindow:    PChar;    // Window to display URL in
  fIndexOnFail: Bool;     // Displays index if keyword lookup fails.
end;
THHAKLink = HH_AKLINK;

const

HHWIN_NAVTYPE_TOC          = 0;
HHWIN_NAVTYPE_INDEX        = 1;
HHWIN_NAVTYPE_SEARCH       = 2;
HHWIN_NAVTYPE_BOOKMARKS    = 3;
HHWIN_NAVTYPE_HISTORY      = 4;    // not implemented
HHWIN_NAVTYPE_AUTHOR       = 5;
HHWIN_NAVTYPE_CUSTOM_FIRST = 11;

// Information types

IT_INCLUSIVE = 0;
IT_EXCLUSIVE = 1;
IT_HIDDEN    = 2;

type

TITType = (
  ITInclusive,
  ITExclusive,
  ITHidden
);

HH_ENUM_IT = packed record
  cbStruct:         integer;   // size of this structure
  iType:            integer;   // the type of the information type ie. Inclusive, Exclusive, or Hidden
//  iType:            TITType; // the type of the information type ie. Inclusive, Exclusive, or Hidden
  pszCatName:       PChar;     // Set to the name of the Category to enumerate the info types in a category; else NULL
  pszITName:        PChar;     // volitile pointer to the name of the infotype. Allocated by call. Caller responsible for freeing
  pszITDescription: PChar;     // volitile pointer to the description of the infotype.
end;

THHEnumIT = HH_ENUM_IT;
PHH_ENUM_IT =^HH_ENUM_IT;
PTHHEnumIT = PHH_ENUM_IT;

HH_ENUM_CAT = packed record
  cbStruct:          integer;  // size of this structure
  pszCatName:        PChar;    // volitile pointer to the category name
  pszCatDescription: PChar;    // volitile pointer to the category description
end;

THHEnumCat = HH_ENUM_CAT;
PTHH_ENUM_CAT = ^HH_ENUM_CAT;
PTHHEnumCat = PTHH_ENUM_CAT;

HH_SET_INFOTYPE = packed record
  cbStruct: integer;       // the size of this structure
  pszCatName: PChar;       // the name of the category, if any, the InfoType is a member of.
  pszInfoTypeName: PChar;  // the name of the info type to add to the filter
end;

THHSetInfoType = HH_SET_INFOTYPE;
PHH_SET_INFOTYPE = ^HH_SET_INFOTYPE;
PTHHSetInfoType = PHH_SET_INFOTYPE;

HH_INFOTYPE = DWORD;
THHInfoType = DWORD;
PHH_INFOTYPE = ^HH_INFOTYPE;
PTHHInfoType = PHH_INFOTYPE;

const
HHWIN_NAVTAB_TOP    = 0;
HHWIN_NAVTAB_LEFT   = 1;
HHWIN_NAVTAB_BOTTOM = 2;

type

THHWinNavTabPos =(
  Top,
  Left,
  Bottom
);

const

HH_MAX_TABS         = 19;  // maximum number of tabs
HH_TAB_CONTENTS     = 0;
HH_TAB_INDEX        = 1;
HH_TAB_SEARCH       = 2;
HH_TAB_BOOKMARKS    = 3;
HH_TAB_HISTORY      = 4;
HH_TAB_CUSTOM_FIRST = 11;
HH_TAB_CUSTOM_LAST  = 19;

HH_MAX_TABS_CUSTOM = (ord(HH_TAB_CUSTOM_LAST) - ord(HH_TAB_CUSTOM_FIRST) + 1);

// HH_DISPLAY_SEARCH Command Related Structures and Constants

  HH_FTS_DEFAULT_PROXIMITY = (-1);

type

HH_FTS_QUERY = packed record
  cbStruct:        integer; // Sizeof structure in bytes.
  fUniCodeStrings: BOOL;    // TRUE if all strings are unicode.
  pszSearchQuery:  PChar;   // String containing the search query.
  iProximity:      integer; // Word proximity.
  fStemmedSearch:  BOOL;    // TRUE for StemmedSearch only.
  fTitleOnly:      BOOL;    // TRUE for Title search only.
  fExecute:        BOOL;    // TRUE to initiate the search.
  pszWindow:       PChar;   // Window to display in
end;

PHH_FTS_QUERY = ^HH_FTS_QUERY;
THHFTSQuery = HH_FTS_QUERY;
PHHFTSQuery = ^HH_FTS_QUERY;

// HH_WINTYPE Structure

HH_WINTYPE = packed record
  cbStruct: integer;      // IN: size of this structure including all Information Types
  fUniCodeStrings: BOOL;  // IN/OUT: TRUE if all strings are in UNICODE
  pszType: PChar;         // IN/OUT: Name of a type of window
  fsValidMembers:  DWORD; // IN: Bit flag of valid members (HHWIN_PARAM_)
  fsWinProperties: DWORD; // IN/OUT: Properties/attributes of the window (HHWIN_)

  pszCaption: PChar;      // IN/OUT: Window title
  dwStyles: DWORD;        // IN/OUT: Window styles
  dwExStyles: DWORD;      // IN/OUT: Extended Window styles
  rcWindowPos: TRECT;     // IN: Starting position, OUT: current position
  nShowState: integer;    // IN: show state (e.g., SW_SHOW)

  hwndHelp: HWND;         // OUT: window handle create window
  hwndCaller: HWND;       // OUT: who called this window

  paInfoTypes: PHH_INFOTYPE;  // IN: Pointer to an array of Information Types

  // The following members are only valid if HHWIN_PROP_TRI_PANE is set

  hwndToolBar: HWND;     // OUT: toolbar window in tri-pane window
  hwndNavigation: HWND;  // OUT: navigation window in tri-pane window
  hwndHTML: HWND;        // OUT: window displaying HTML in tri-pane window
  iNavWidth: integer;    // IN/OUT: width of navigation window
  rcHTML: TRect;         // OUT: HTML window coordinates
  pszToc: PChar;         // IN: Location of the table of contents file
  pszIndex: PChar;       // IN: Location of the index file
  pszFile: PChar;        // IN: Default location of the html file
  pszHome: PChar;        // IN/OUT: html file to display when Home button is clicked
  fsToolBarFlags: DWORD; // IN: flags controling the appearance of the toolbar
  fNotExpanded: BOOL;    // IN: TRUE/FALSE to contract or expand, OUT: current state
  curNavType: integer;   // IN/OUT: UI to display in the navigational pane
  tabpos: integer;       // IN/OUT: HHWIN_NAVTAB_TOP, HHWIN_NAVTAB_LEFT, or HHWIN_NAVTAB_BOTTOM
  idNotify: integer;     // IN: ID to use for WM_NOTIFY messages
  TabOrder : array[0 .. HH_MAX_TABS + 1] of byte; // IN/OUT: tab order: Contents, Index, Search, History, Favorites, Reserved 1-5, Custom tabs
  cHistory: integer;     // IN/OUT: number of history items to keep (default is 30)
  pszJump1: PChar;       // Text for HHWIN_BUTTON_JUMP1
  pszJump2: PChar;       // Text for HHWIN_BUTTON_JUMP2
  pszUrlJump1: PChar;    // URL for HHWIN_BUTTON_JUMP1
  pszUrlJump2: PChar;    // URL for HHWIN_BUTTON_JUMP2
  rcMinSize: TRect;      // Minimum size for window (ignored in version 1)
  cbInfoTypes: integer;  // size of paInfoTypes;
  pszCustomTabs: PChar;  // multiple zero-terminated strings
end;

THHWinType = HH_WINTYPE;
PHHWintype = ^HH_WINTYPE;

HHNNAVCOMPLETE = packed record
  hdr : TNMHdr;
  pszUrl : PChar; // Multi-byte, null-terminated string
end;

PHHNNavComplete = ^HHNNAVCOMPLETE;
THHNNavComplete = HHNNAVCOMPLETE;


THHActTypes = (
    HHACT_TAB_CONTENTS,
    HHACT_TAB_INDEX,
    HHACT_TAB_SEARCH,
    HHACT_TAB_HISTORY,
    HHACT_TAB_FAVORITES,
    HHACT_EXPAND,
    HHACT_CONTRACT,
    HHACT_BACK,
    HHACT_FORWARD,
    HHACT_STOP,
    HHACT_REFRESH,
    HHACT_HOME,
    HHACT_SYNC,
    HHACT_OPTIONS,
    HHACT_PRINT,
    HHACT_HIGHLIGHT,
    HHACT_CUSTOMIZE,
    HHACT_JUMP1,
    HHACT_JUMP2,
    HHACT_ZOOM,
    HHACT_TOC_NEXT,
    HHACT_TOC_PREV,
    HHACT_NOTES,
    HHACT_LAST_ENUM
);

HHNTRACK = packed record
  hdr: TNMHdr;
  pszCurUrl: PChar;             // Multi-byte, null-terminated string
  idAction: THHActTypes;        // HHACT_ value
  phhWinType: ^HH_WINTYPE;      // Current window type structure
end;

THHNTrack = HHNTRACK;
PHHNTRACK = ^HHNTRACK;
type THtmlHelp = function(hwndCaller : THandle; pszFile : PChar; uCommand : cardinal; dwData : longint) : integer; stdcall;
function HtmlHelp(hwndCaller : THandle; pszFile : string; uCommand : cardinal; dwData : longint) : integer;

var
  HtmlHelpLibError: Boolean;

implementation

const
// Use the following for GetProcAddress to load from hhctrl.ocx
   ATOM_HTMLHELP_API_ANSI   =  PChar(DWORD(WORD(14)));
   ATOM_HTMLHELP_API_UNICODE = PChar(DWORD(WORD(15)));

var
  HtmlHelpProc : THtmlHelp;
  HHCtrlHandle : THandle;

(*******************************************************************************
*                                  HtmlHelp                                    *
*******************************************************************************)

{$IFDEF TRIAL}
  const
    HH_CTRLOCX_ERROR = 'Unable to load "HHCtrl.ocx" library !!!'+ #13#10
           + 'Press OK Button to download and install the latest version'+ #13#10
           + 'of the HTML Help Workshop from the Microsoft Web Site.';
  var
    EF: Boolean;
{$ENDIF}

function HtmlHelp;
begin
  Result := -1;
  if HtmlHelpLibError then Exit;
  if (not Assigned(HtmlHelpProc)) then begin
    HHCtrlHandle := LoadLibrary('HHCtrl.ocx');
    if (HHCtrlHandle <> 0) then
      HtmlHelpProc := GetProcAddress(HHCtrlHandle, 'HtmlHelpA');
  end;
  if (not Assigned(HtmlHelpProc)) then begin
    HtmlHelpLibError := True;
//    beep(1000,100);
    {$IFDEF TRIAL}
      if not EF and (MessageDlg(HH_CTRLOCX_ERROR,mtError,[mbOk,mbCancel],0) = mrOK) then begin
        ShellExecute(0,'open','http://msdn.microsoft.com/workshop/author/htmlhelp/default.asp',nil,nil,SW_SHOWNORMAL);
        EF := True;
      end;
    {$ENDIF}
  end
  else
    Result := HtmlHelpProc(hwndCaller, PChar(pszFile), uCommand, dwData);
end;

initialization
begin
end;

finalization
begin
   if (HHCtrlHandle <> 0) then FreeLibrary(HHCtrlHandle);
end;

end.

