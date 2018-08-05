# This folder contains references to supporting documentation
---
This repo will be stitching a lot of this prior, and exceptionally excellent, work together into a neat package.
Some sources will be backed up here

All sources are openly available and this repo will comply with their respective copyright requirements

## High Level Napkin
--- 
**napkin.pdf** is the start of it

## Prior Work

### CPU
---
CPU will be based on the excellent picorv32, this will be used for generating the GUI and controlling subsystems like sound and power monitoring, see repo
Copyright Owner Clifford Wolf
<https://github.com/cliffordwolf/picorv32>

This will updated to be a submodule later to pick up code directly from picorv32 development

### Video
---
Video and Audio will be based on the excellent gc-video lite, see repo
Copyright (C) 2014-2017, Ingo Korb <ingo@akana.de>
<https://github.com/ikorb/gcvideo>

The documentation for video encoding supporting the gc-video is found at this url and backed up to **gamesx.pdf**
The information from this wiki is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
<https://gamesx.com/wiki/doku.php?id=av:nintendodigitalav>

### GameCube controller
---
In order to save space a gamecube controller will be integrated into the FPGA
This will also be used to control the GUI and subsytems through the picorv32
The protocol for the serial interface between the gamecube was taken from the GC+ repository
Copyright (c) 2016 Aurelio Mannara
<https://github.com/Aurelio92/GCPlus>
See **gc-controller-protocol.odt** and **gc-controller-protocol.pdf** if you want to read about it