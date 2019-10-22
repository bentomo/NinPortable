#include "Vnp_top_tb.h"
#include "verilated_vcd_c.h"
//There's probably a better way to link this library in but meh ¯\_(ツ)_/¯
//#include "../../../../wbuart32/bench/cpp/uartsim.h"
//#include "../../../../wbuart32/bench/cpp/uartsim.cpp"

#define OHK 100000
#define OMN 1000000

int evalSerialRXer (int SERIALTX, unsigned char* serialByte, int prevSerial, int *bitCnt, unsigned long int *clkCnt, unsigned long int baudRate);

int main(int argc, char **argv, char **env)
{
	printf("Built with %s %s.\n", Verilated::productName(), Verilated::productVersion());
	printf("Recommended: Verilator 4.0 or later.\n");

	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	Vnp_top_tb* top = new Vnp_top_tb;

	unsigned char serialByte = 0x00;
	int prevSerial = 1;
	int bitCnt = 0;
	unsigned long int clkCnt = 0;
	unsigned long int baudRate = 870;

	printf("Baud rate is %lu ticks.\n\r", baudRate);

	VerilatedVcdC* tfp = new VerilatedVcdC;
	top->trace (tfp, 99);
        tfp->open ("np_top_tb.vcd");
	top->CLK = 0;
	int t = 0;
	int cycleCntMax= 10*(OMN);
	top->SERIAL_RX = 1;
	while (1) {
		if (t > 200){
			top->RST = 1;
		}
		if (t > 205 && (top->CLK)){
			evalSerialRXer(top->SERIAL_TX, &serialByte, prevSerial, &bitCnt, &clkCnt, baudRate);
			prevSerial = top->SERIAL_TX;
		}
		top->CLK = !top->CLK;
		top->eval();
		tfp->dump (t);
		t += 5;

		if (top->CLK) ++clkCnt;
	}
	tfp->close();
	delete top;
	exit(0);
}

//This function acts like a serial receiver that prints to the console. It could be updated to interact with
//a tcp IP port so the verilog display functions aren't stomping on it.
int evalSerialRXer(int SERIALTX, unsigned char* serialByte, int prevSerial, int* bitCnt, unsigned long int* clkCnt, unsigned long int baudRate){
	int rc = 0;
	unsigned char serialData = 0x00;

	//Start on falling edge of first bit
	if (prevSerial != SERIALTX && (*bitCnt == 0)){
		//Start counting clocks
		*clkCnt = 0;
		*serialByte = 0x00;
		++(*bitCnt);
	} else {
		if (*bitCnt > 0) {
			//Delay for start bit
			if (*bitCnt == 1) {
				if (*clkCnt == baudRate){
					++(*bitCnt);
					*clkCnt = 0;
				}
			} else if (*bitCnt < 10) {
				if (*clkCnt == (baudRate/2)) {
					//sample half way through baud rate and shift in data to buffer
					serialData = (SERIALTX << (*bitCnt-2));
					*serialByte = (*serialByte | serialData);
					//printf("SERIALTX: %d at bitCnt: %d serialData: 0x%08X at clkCnt: %lu \
					//	serialByte: 0x%02X\n\r", SERIALTX, *bitCnt-2, serialData, *clkCnt, *serialByte);
				} else if (*clkCnt == baudRate) {
					//reset clock counter
					*clkCnt = 0;
					++(*bitCnt);
				}
			} else {
				//reset bit counter for next byte
				*bitCnt = 0;
				//print out character to console
				//printf("serialByte: 0x%02X ", *serialByte);
				printf("%c", *serialByte);
			}
		}
	}


	return rc;
}