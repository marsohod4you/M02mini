#include "stdafx.h"
#include "Serial.h"

CSerial g_serial;

CSerial::CSerial(void)
{
	m_dwError = 0;
	m_hPort = NULL;
}

CSerial::~CSerial(void)
{
}

int CSerial::Init(LPTSTR lpszPortName)
{
	if(m_hPort)
	{
		CloseHandle(m_hPort);
		m_hPort = NULL;
	}

	//DWORD dwThreadID;
	DCB PortDCB;
	COMMTIMEOUTS CommTimeouts;

	m_dwError=0;

	// Open the serial port.
	m_hPort = CreateFile (lpszPortName, // Pointer to the name of the port
                      GENERIC_READ | GENERIC_WRITE,
                                    // Access (read/write) mode
                      0,            // Share mode
                      NULL,         // Pointer to the security attribute
                      OPEN_EXISTING,// How to open the serial port
                      0, //FILE_FLAG_OVERLAPPED, // Port attributes
                      NULL);        // Handle to port with attribute
                                    // to copy

	// If it fails to open the port, return FALSE.
	if ( m_hPort == INVALID_HANDLE_VALUE ) 
	{
		// Could not open the port.
		m_dwError = GetLastError ();
		//MessageBox (NULL, TEXT("Unable to open the port specified..."),TEXT("Error"), MB_OK);
		return m_dwError;
	}

	PortDCB.DCBlength = sizeof (DCB);     

	// Get the default port setting information.
	GetCommState (m_hPort, &PortDCB);

	// Change the DCB structure settings.
	PortDCB.BaudRate = 12000000;         // Current baud 
	PortDCB.fBinary = TRUE;               // Binary mode; no EOF check 
	PortDCB.fParity = TRUE;               // Enable parity checking. 
	PortDCB.fOutxCtsFlow = FALSE;         // No CTS output flow control 
	PortDCB.fOutxDsrFlow = FALSE;         // No DSR output flow control 
	PortDCB.fDtrControl = DTR_CONTROL_DISABLE; 
										// DTR flow control type 
	PortDCB.fDsrSensitivity = FALSE;      // DSR sensitivity 
	PortDCB.fTXContinueOnXoff = TRUE;     // XOFF continues Tx 
	PortDCB.fOutX = FALSE;                // No XON/XOFF out flow control 
	PortDCB.fInX = FALSE;                 // No XON/XOFF in flow control 
	PortDCB.fErrorChar = FALSE;           // Disable error replacement. 
	PortDCB.fNull = FALSE;                // Disable null stripping. 
	PortDCB.fRtsControl = RTS_CONTROL_DISABLE; 
										// RTS flow control 
	PortDCB.fAbortOnError = FALSE;        // Do not abort reads/writes on 
										// error.
	PortDCB.ByteSize = 8;                 // Number of bits/bytes, 4-8 
	PortDCB.Parity = NOPARITY;            // 0-4=no,odd,even,mark,space 
	PortDCB.StopBits = ONESTOPBIT;        // 0,1,2 = 1, 1.5, 2 

	// Configure the port according to the specifications of the DCB 
	// structure.
	if (!SetCommState (m_hPort, &PortDCB))
	{
		// Could not configure the serial port.
    
		m_dwError = GetLastError ();
		//MessageBox (NULL, TEXT("Unable to configure the serial port"), TEXT("Error"), MB_OK);
		return m_dwError;
	}

	// Retrieve the time-out parameters for all read and write operations
	// on the port. 
	GetCommTimeouts (m_hPort, &CommTimeouts);

	// Change the COMMTIMEOUTS structure settings.
	CommTimeouts.ReadIntervalTimeout = MAXDWORD;  
	CommTimeouts.ReadTotalTimeoutMultiplier = 0;  
	CommTimeouts.ReadTotalTimeoutConstant = 0;    
	CommTimeouts.WriteTotalTimeoutMultiplier = 10;  
	CommTimeouts.WriteTotalTimeoutConstant = 1000;    

	// Set the time-out parameters for all read and write operations
	// on the port. 
	if (!SetCommTimeouts (m_hPort, &CommTimeouts))
	{
		// Could not set the time-out parameters.
    
		m_dwError = GetLastError ();
		//MessageBox (NULL, TEXT("Unable to set the time-out parameters"), TEXT("Error"), MB_OK);
		return m_dwError;
	}

	// Direct the port to perform extended functions SETDTR and SETRTS.
	// SETDTR: Sends the DTR (data-terminal-ready) signal.
	// SETRTS: Sends the RTS (request-to-send) signal. 
	EscapeCommFunction (m_hPort, SETDTR);
	EscapeCommFunction (m_hPort, SETRTS);
	return 0;
}

int CSerial::Read(unsigned char* pbuffer, int size)
{
	DWORD dwBytesTransferred = 0;
	if(m_hPort==0 || m_hPort==INVALID_HANDLE_VALUE)
		return -1;

	if( ReadFile (m_hPort, pbuffer, size, &dwBytesTransferred, NULL) )
		return dwBytesTransferred;
	else
		return -1;
}
