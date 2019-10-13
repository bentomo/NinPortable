#include <stdlib.h>
#include "Vtop_np.h"
#include "verilated.h"

int main(int argc, char **argv) {

	printf("Built with %s %s.\n", Verilated::productName(), Verilated::productVersion());
	printf("Recommended: Verilator 4.0 or later.\n");

	// Initialize Verilators variables
	Verilated::commandArgs(argc, argv);

	// Create an instance of our top_np under test
	Vtop_np *tb = new Vtop_np;

	// Tick the clock until we are done
	while(!Verilated::gotFinish()) {
		tb->CLK = 1;
		tb->eval();
		tb->CLK = 0;
		tb->eval();
	} exit(EXIT_SUCCESS);
}

/*
#include "Vpicorv32_wrapper.h"
#include "verilated_vcd_c.h"

int main(int argc, char **argv, char **env)
{
	printf("Built with %s %s.\n", Verilated::productName(), Verilated::productVersion());
	printf("Recommended: Verilator 4.0 or later.\n");

	Verilated::commandArgs(argc, argv);
	Verilated::traceEverOn(true);
	Vpicorv32_wrapper* top = new Vpicorv32_wrapper;

	VerilatedVcdC* tfp = new VerilatedVcdC;
	top->trace (tfp, 99);
        tfp->open ("testbench.vcd");
	top->clk = 0;
	int t = 0;
	while (!Verilated::gotFinish()) {
		if (t > 200)
			top->resetn = 1;
		top->clk = !top->clk;
		top->eval();
		tfp->dump (t);
		t += 5;
	}
	tfp->close();
	delete top;
	exit(0);
}
*/