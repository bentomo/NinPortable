This folder contains the source code for the fpga
The code will be all verilog in order to support OSS tools
This means that gcvideo will be converted to verilog

#gc_ontroller
---
This module handles the logic to act as a nintendo gamecube controller and communicate with the spi A/D converters for the joysticks
A/D spi is still under development. SAR through LVDS comparators isn't very accurate
MAX11662ABU+ is a good candidate for this
<https://www.digikey.com/product-detail/en/maxim-integrated/MAX11662AUB-T/MAX11662AUB-TCT-ND/2776886>