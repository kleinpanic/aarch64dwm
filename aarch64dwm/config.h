/* See LICENSE file for copyright and license details. */

#include "colors/space.h"
#include "keys.h"

#define ICONSIZE 16 /* icon size */
#define ICONSPACING 5 /* Space between icon and title */

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft  = 0;   /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;        /* 0 means no systray */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const int user_bh            = 0;        /* 0 means that dwm will calculate bar height, >= 1 means dwm will user_bh as bar height */
static const char *fonts[]          = { "monospace:size=9", "DroidSansMono Nerd Font:size=9", "Noto Color Emoji:size=9", "Cairo:size=9" };

/* tagging */
//static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };
static const char *tags[] = { "\uf17c", "\uf1d8", "\uf0ac", "\uf109", "\uf09b", "\uf02d", "\uf044", "\uf1bc", "\uf120" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      	     instance    title    tags mask     isfloating   CenterThisWindow?     monitor */
	{ "st",              NULL,       NULL,    0,            0,     	     1,		           -1 },
	{ "Gimp",            NULL,       NULL,    0,            1,           0,                    -1 },
};
