
// show_rndDlg.h : header file
//

#pragma once
#include "afxwin.h"


// Cshow_rndDlg dialog
class Cshow_rndDlg : public CDialogEx
{
// Construction
public:
	Cshow_rndDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	enum { IDD = IDD_SHOW_RND_DIALOG };

	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support


// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	DECLARE_MESSAGE_MAP()
public:
	CComboBox m_combo_ports;
	afx_msg void OnCbnSelchangeCombo1();
	BOOL SearchComPorts();
	afx_msg void OnTimer(UINT_PTR nIDEvent);
	afx_msg void OnBnClickedButton1();
	CStatic m_num_recv;
	afx_msg void OnBnClickedButton2();
};
