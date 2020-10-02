
// show_rnd.h : main header file for the PROJECT_NAME application
//

#pragma once

#ifndef __AFXWIN_H__
	#error "include 'stdafx.h' before including this file for PCH"
#endif

#include "resource.h"		// main symbols


// Cshow_rndApp:
// See show_rnd.cpp for the implementation of this class
//

class Cshow_rndApp : public CWinApp
{
public:
	Cshow_rndApp();

// Overrides
public:
	virtual BOOL InitInstance();

// Implementation

	DECLARE_MESSAGE_MAP()
};

extern Cshow_rndApp theApp;