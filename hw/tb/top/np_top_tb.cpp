#include "Vnp_top_tb.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv, char **env)
{
	printf("Built with %s %s.\n", Verilated::productName(), Verilated::productVersion());
	printf("Recommended: Verilator 4.0 or later.\n");

	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	Vnp_top_tb* top = new Vnp_top_tb;

	VerilatedVcdC* tfp = new VerilatedVcdC;
	top->trace (tfp, 99);
        tfp->open ("np_top_tb.vcd");
	top->CLK = 0;
	int t = 0;
	while (!Verilated::gotFinish()) {
		if (t > 200)
			top->RST = 1;
		top->CLK = !top->CLK;
		top->SERIAL_RX = 1;
		top->eval();
		tfp->dump (t);
		t += 5;
	}
	tfp->close();
	delete top;
	exit(0);
}

