# AGC
 this repo contain implementation of digital AGC using matlab and vhdl.
 this agc is implemented based on 
 https://wirelesspi.com/how-automatic-gain-control-agc-works/ 


 ![agc diagram](./imags/agcdiagram.PNG) 



# how to build 
to build the project using vivado, first open vivado, using tcl console which located in the botom of the vivado go to the build folder and run following command: 
```tcl 
source vivado_build2.tcl 
```
source directory is equal to 
```
./FPGA/build
```

there is a Test bench file that you can run it and see the result. in the following image an input with range between -2000:2000 converter to -200 : 200. 

![converted image](./imags/converted_sig.png)


considered power in the code is `targetLevel` which is a fixed point number with 16 bit integer part and 0 bits fraction parts. here target level is equal to `hex(200)`. 

## Simulation 
the simulation file of the project written with matlab that you can see it in the matlab folder.








