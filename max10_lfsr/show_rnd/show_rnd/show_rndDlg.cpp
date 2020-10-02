
// show_rndDlg.cpp : implementation file
//

#include "stdafx.h"
#include "show_rnd.h"
#include "show_rndDlg.h"
#include "afxdialogex.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

#include "serial.h"

// CAboutDlg dialog used for App About

class CAboutDlg : public CDialogEx
{
public:
	CAboutDlg();

// Dialog Data
	enum { IDD = IDD_ABOUTBOX };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Implementation
protected:
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialogEx(CAboutDlg::IDD)
{
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialogEx)
END_MESSAGE_MAP()


// Cshow_rndDlg dialog
#define IMG_WIDTH 256
#define IMG_HEIGHT 256
CImage g_img;
char* g_ppixels = NULL;

#define RBUF_SIZE (1024*32)
unsigned int g_array[256];
unsigned int g_received = 0;
unsigned int g_received_wnd = 0;
unsigned int g_num_ticks = 0;

Cshow_rndDlg::Cshow_rndDlg(CWnd* pParent /*=NULL*/)
	: CDialogEx(Cshow_rndDlg::IDD, pParent)
{
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void Cshow_rndDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialogEx::DoDataExchange(pDX);
	DDX_Control(pDX, IDC_COMBO1, m_combo_ports);
	DDX_Control(pDX, IDC_STATIC_RECV, m_num_recv);
}

BEGIN_MESSAGE_MAP(Cshow_rndDlg, CDialogEx)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_CBN_SELCHANGE(IDC_COMBO1, &Cshow_rndDlg::OnCbnSelchangeCombo1)
	ON_WM_TIMER()
	ON_BN_CLICKED(IDC_BUTTON1, &Cshow_rndDlg::OnBnClickedButton1)
	ON_BN_CLICKED(IDC_BUTTON2, &Cshow_rndDlg::OnBnClickedButton2)
END_MESSAGE_MAP()


// Cshow_rndDlg message handlers

BOOL Cshow_rndDlg::OnInitDialog()
{
	CDialogEx::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	if (pSysMenu != NULL)
	{
		BOOL bNameValid;
		CString strAboutMenu;
		bNameValid = strAboutMenu.LoadString(IDS_ABOUTBOX);
		ASSERT(bNameValid);
		if (!strAboutMenu.IsEmpty())
		{
			pSysMenu->AppendMenu(MF_SEPARATOR);
			pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
		}
	}

	SearchComPorts();
	SetTimer(0,25,NULL);

	g_img.Create(IMG_WIDTH,-IMG_HEIGHT,24);
	g_ppixels = (char*)g_img.GetBits();
	OnBnClickedButton1();

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon

	// TODO: Add extra initialization here

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void Cshow_rndDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialogEx::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void Cshow_rndDlg::OnPaint()
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, reinterpret_cast<WPARAM>(dc.GetSafeHdc()), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		for(int x=0; x<256; x++)
		{
			unsigned int h=g_array[x];
			if(h>IMG_HEIGHT-1) h=IMG_HEIGHT-1;
			unsigned char* ppixel = (unsigned char*)g_ppixels+(x+IMG_WIDTH*(IMG_HEIGHT-1))*3; 
			for(int y=0; y<h; y++)
			{
				ppixel[0]=0xFF;
				ppixel[1]=0x00;
				ppixel[2]=0x00;
				ppixel-=IMG_WIDTH*3;
			}
		}

		CPaintDC dc(this);
		g_img.BitBlt(dc,16,64,SRCCOPY);
		g_received_wnd=0;
		memset(g_array,0,sizeof(g_array));
		memset(g_ppixels,0xFF,IMG_WIDTH*IMG_HEIGHT*3);

		CDialogEx::OnPaint();
	}
}

// The system calls this function to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR Cshow_rndDlg::OnQueryDragIcon()
{
	return static_cast<HCURSOR>(m_hIcon);
}


BOOL Cshow_rndDlg::SearchComPorts()
{
	m_combo_ports.Clear();
	for( int i=0; i< 32; i++)
	{
		WCHAR port_name[256];
		wsprintf(port_name,_T("\\\\.\\COM%d"),i);
		if( g_serial.Init(port_name)==0 )
			m_combo_ports.AddString(port_name);
	}
	return TRUE;
}

void Cshow_rndDlg::OnCbnSelchangeCombo1()
{
	//serial port changed
	WCHAR port_name[256];
	int idx = m_combo_ports.GetCurSel();
	if(idx>=0)
	{
		m_combo_ports.GetLBText(idx,port_name);
		g_serial.Init( port_name );
	}
}

unsigned char rbuffer[RBUF_SIZE];

void Cshow_rndDlg::OnTimer(UINT_PTR nIDEvent)
{
	//get data from serial port, from FPGA board
	int sz = g_serial.Read(rbuffer,RBUF_SIZE);
	if(sz>0)
	{
		g_received=g_received+sz;
		g_received_wnd=g_received_wnd+sz;
		//accumulate statistics
		for(int i=0; i<sz; i++)
		{
			unsigned char random_from_board = rbuffer[i];
			g_array[random_from_board]++;
		}
	}

	g_num_ticks++;
	if( g_num_ticks>10 )
	{
		g_num_ticks=0;
		WCHAR str[512];
		wsprintf(str,_T("Received %d/%d"),g_received_wnd,g_received);
		m_num_recv.SetWindowTextW(str);
		Invalidate(FALSE);
	}
	CDialogEx::OnTimer(nIDEvent);
}

void Cshow_rndDlg::OnBnClickedButton1()
{
	//clear statistics
	g_received=0;
	g_received_wnd=0;
	memset(g_array,0,sizeof(g_array));
	memset(g_ppixels,0xFF,IMG_WIDTH*IMG_HEIGHT*3);
}

#define NUM_SAMPLES (1024)
void Cshow_rndDlg::OnBnClickedButton2()
{
	FILE * pFile;
	errno_t err = fopen_s(&pFile,"samples_rnd.bin","wb");
	fwrite(rbuffer,1,NUM_SAMPLES,pFile);
    fclose (pFile);

}
