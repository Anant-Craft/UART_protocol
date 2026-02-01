--> UART Protocol Implementation in Verilog

Project Overview
This project implements a Universal Asynchronous Receiver Transmitter (UART) protocol in Verilog HDL.  
It includes both UART Transmitter (TX) and Receiver (RX) modules with loopback communication for verification.

*********---------*********

 Features
- UART Transmitter (TX)
- UART Receiver (RX)
- 8-bit serial communication
- Start and Stop bit framing
- Configurable baud rate
- Loopback testing (TX → RX)
- Testbench included

*********---------*********

 Architecture
UART Frame Format:
Start bit | 8 Data bits | Stop bit

TX converts parallel data → serial stream  
RX converts serial stream → parallel data


