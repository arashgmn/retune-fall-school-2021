/*
This file parameterically makes a 2D mesh of an EEG/ECoG array of
electrodes, placed on the sculp or dura.  All electrodes are palced
on the top edge of the box in x direction.

The parameters in control are:

L:          (half) length of the box
lx:         size of each electrode
dx:         distance between the electrodes
Nx:         (half) number of electodes in x-direction 

NOTE: lx >= 2*R
*/


SetFactory("Built-in");
lc = 0.001; //charactersitic length of the mesh

L = 1; 
lx = 0.01; 
dx = 5*lx; 
Nx = 5;  

//////// DOMAIN ////////
Point(1) = {-L, -L, 0, 100*lc};
Point(2) = {-L, L, 0, 100*lc};
Point(3) = {L, L, 0, 100*lc};
Point(4) = {L, -L, 0, 100*lc};

Line(1) = {2, 1};
Line(2) = {1, 4};
Line(3) = {4, 3};

back_point = 2;
electrodes = {};
gaps = {};
For t In {-Nx:Nx}
    Printf("t= %g, t*Nx=%g",t,t*lx);
    
    p = newp;
    Point(p)= {t*dx -lx/2, L, 0, lc};
    Point(p+1)= {t*dx +lx/2, L, 0,  lc};
    
    //electrode
    l = newl;
    Line(l) ={p,p+1};
    electrodes += {l};
    
    //intra-electrode isolation area
    Line(l+1) ={back_point,p};
    back_point = p+1;
    
    If (t > -Nx)
        Printf("I'm in if");
        gaps+= {l+1};
    EndIf

EndFor
last_line = newl;
Line(last_line) ={back_point,3};


// make domain
Curve Loop(1) = {13, 12, 15, 14, 17, 16, 19, 18, 21, 20, 23, 22, 25, 24, 26, -3, -2, -1, 5, 4, 7, 6, 9, 8, 11, 10};
Plane Surface(1) = {1};

////// MESHING ////////
// transfinites
For idx In {0:2*Nx}
    Printf("electrode=%g", electrodes[idx]);
    Transfinite Curve electrodes[idx] = 30 Using Bump 1/10;
    
    If (idx<(2*Nx-1))
        Printf("gap= %g",gaps[idx]);
        Transfinite Curve gaps[idx] = 15*Ceil(dx/lx) Using Bump 1/10;
    EndIf
    
EndFor
Transfinite Curve {-5,last_line} = 50 Using Progression 1.15;


//////// BOUNDARY CONDITIONS ////////
Physical Curve("left", 1) = {1};
Physical Curve("right", 2) = {3};
Physical Curve("bottom", 3) = {2};
Physical Curve("top", 5) = {5, last_line};

// each contact must have a differenct physical group 
For idx In {0:2*Nx}
    name = news;
    Physical Curve(name) = {electrodes[idx]};
EndFor

Physical Surface("domain", 1) = {1};
Mesh 3;

