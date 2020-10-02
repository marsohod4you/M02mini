#pragma once
class CSerial
{
public:
	CSerial(void);
	~CSerial(void);
	int Init(LPTSTR lpszPortName);
	int Read(unsigned char* pbuffer, int size);

	HANDLE m_hPort;
	DWORD m_dwError;
};

extern CSerial g_serial;
