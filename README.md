# test-scripts

A number of bash scripts written to automate testing of file transfers over networks (unprotected or via VPN).

### Dependencies
For all scripts, the packages ```ifstat``` need to be installed beforehand. In addition, to lower the amount of text logged per call to top, modifying ```top```'s appearance beforehand helps. Remove everything but the very first menu line.

### ```top``` config
- ```m``` to make the memory info disappear (hit ~2 or 3 times)
- ```t``` to make the CPU info disappear (again, hit ~2 or 3 times)
- ``` shift + W``` to save the configuration
- these steps will also revert ```top``` back to the original configuration if you want to change it back.
