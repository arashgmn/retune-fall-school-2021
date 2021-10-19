/*
This file parameterically makes a 2D mesh of an (intracortical) 
microelectrode array, immersed in a box. The length of the
electrode matches the (half) length of the box. All electrodes 
are elongated in y direction. Electrodes are approximated by a
cone.

The parameters in control are:

L:          (half) length of the box
R:          the radius of the electrode at the base
lx:         distance between the electrodes
Nx:         (half) number of electodes in x-direction 

NOTE: lx >= 2*R
*/


SetFactory("Built-in");
lc = 0.01; //charactersitic length of the mesh

L = 1; 
R = 0.01; 
lx = 10*R; 
Nx = 3;  

//////// DOMAIN ////////
Point(1) = {-L, -L, 0, 10*lc};
Point(2) = {-L, L, 0, 10*lc};
Point(3) = {L, L, 0, 10*lc};
Point(4) = {L, -L, 0, 10*lc};

Line(1) = {2, 1};
Line(2) = {1, 4};
Line(3) = {4, 3};

back_point = 2;
electrodes = {};
For t In {-Nx:Nx}
    Printf("t= %g, t*Nx=%g",t,t*lx);
    
    p = newp;
    Point(p)  = {t*lx   , 0, 0,  lc};
    Point(p+1)= {t*lx -R, L, 0, lc};
    Point(p+2)= {t*lx +R, L, 0,  lc};
    
    //electrode
    l = newl;
    Line(l) ={p+1,p};
    Line(l+1) ={p,p+2};
    electrodes += {l,l+1};
    
    //cap
    Line(l+3) ={back_point,p+1};
    back_point = p+2;   
EndFor    
last_line = newl;
Line(last_line) ={back_point,3};
// make domain
Curve Loop(1) = {1, 2, 3, -32, -29, -28, -31, -25, -24, -27, -21, -20, -23, -17, -16, -19, -13, -12, -15, -9, -8, -11, -5, -4, -7};
Plane Surface(1) = {1};


////// MESHING ////////
// transfinites
For idx In {0:2*Nx}
    Printf("line 1= %g   line 2 = %g", electrodes[2*idx],electrodes[2*idx+1]);
    Transfinite Curve electrodes[2*idx] = 50 Using Bump 1/10;
    Transfinite Curve electrodes[2*idx+1] = 50 Using Bump 1/10;
EndFor

//////// BOUNDARY CONDITIONS ////////

Physical Curve("left", 1) = {1};
Physical Curve("right", 2) = {3};
Physical Curve("bottom", 3) = {2};
Physical Curve("top", 5) = {7, last_line};

// each contact must have a differenct physical group 
For idx In {0:2*Nx}
    name = news;
    Physical Curve(name) = {electrodes[2*idx], electrodes[2*idx+1]};
EndFor

Physical Surface("domain", 1) = {1};
Mesh 3;


