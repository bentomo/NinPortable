//This is the test firmware for testing the uart interface

#include "../../common/firmware.h"

uint32_t *main(void) {

	//Needs to change to a uprintf
	print_str ("Hello World!\n\r");

	return 0;
}