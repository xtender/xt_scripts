REM Code 	Effect
REM ***********************************************************************
REM 0       Turn off all attributes
REM 1       Set bright mode
REM 4       Set underline mode
REM 5       Set blink mode
REM 7       Exchange foreground and background colors
REM 8       Hide text (foreground color would be the same as background)
REM ***********************************************************************
REM     COLORS:
REM 30      Black text
REM 31      Red text
REM 32      Green text
REM 33      Yellow text
REM 34      Blue text
REM 35      Magenta text
REM 36      Cyan text
REM 37      White text
REM 39      Default text color
REM ***********************************************************************
REM     Background COLORS:
REM 40      Black background
REM 41      Red background
REM 42      Green background
REM 43      Yellow background
REM 44      Blue background
REM 45      Magenta background
REM 46      Cyan background
REM 47      White background
REM 49      Default background color
REM ***********************************************************************

def _C_RESET        =""
-- _C_RESET can be simply  =[m

def _C_BOLD         =""
def _C_BOLD_OFF     =""

def _C_UNDERLINE    =""
def _C_UNDERLINE_OFF=""

def _C_BLINK        =""
def _C_BLINK_OFF    =""

def _C_REVERSE      =""
def _C_REVERSE_OFF  =""

def _C_HIDE         =""
def _C_HIDE_OFF     =""

def _C_BLACK        =""
def _C_RED          =""
def _C_GREEN        =""
def _C_YELLOW       =""
def _C_BLUE         =""
def _C_MAGENTA      =""
def _C_CYAN         =""
def _C_WHITE        =""
def _C_DEFAULT      =""

def _CB_BLACK       =""
def _CB_RED         =""
def _CB_GREEN       =""
def _CB_YELLOW      =""
def _CB_BLUE        =""
def _CB_MAGENTA     =""
def _CB_CYAN        =""
def _CB_WHITE       =""
def _CB_DEFAULT     =""

REM just addition variables for convenience:
def _ESC            =""
def _CLS            =""
