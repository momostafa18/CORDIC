#CORDIC Project
This repository contains a project that implements the CORDIC (Coordinate Rotation Digital Computer) algorithm. The CORDIC algorithm is a well-known technique used for various mathematical computations, such as trigonometric functions, vector rotations, and coordinate transformations.ns
Implementation of the two modes vector and rotation mode has been finished 
The major difference is that vector mode is just to rotate the vector to be on the x-axis while the rotation mode is for rotating the vector with some specific angle
Since we need to deal with floating point so i dealt with fixed floating point where i assumed that there is some bits specified for the numbers before the decimal point and the other bits for the number behind the decimal point and this depends on the precision used 
Two concepts shall be so clear is the difference between the wordlength and the number of stages 
since that increasing the number of stages will increase the precision but it's constrained by the wordlength iam dealing with 
This block consists of Multiple adders , shifters and single LUT for the tan inverse 
The number of the adders and Shifters depends mainly on the number of stages used 

The refernce used for this project was "From Algorithms to hardware Architecture"
