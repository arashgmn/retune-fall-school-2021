/*
This file parameterically makes a 2D mesh of a axisymmertic DBS electrode, immersed
in a box. The center of electrode tip is on the center, and the electrode is 
elongated in positive-y direction.

The parameters in control are:

L:          (half) length of the box
R:          the radius of the electrode shaft
gap:        distance between the contacts on the shaft
l:          the length of each contact
y_start:    the vertical coordinate of the first contact 
*/


SetFactory("Built-in");
lc = 0.0001; //charactersitic length of the mesh

// Medtronic 3387
L = 0.02; 
R = 0.00127/2; 
l = 0.0015; 
gap = l; 
y_start = gap-R;  


//////// DOMAIN ////////
Point(0) = {0, 0, 0, lc};

Point(1) = {-L, -L, 0, 10*lc};
Point(2) = {-L, L, 0, 10*lc};
Point(3) = {L, L, 0, 10*lc};
Point(4) = {L, -L, 0, 10*lc};

Point(5) = {-R, L, 0, 10*lc};
Point(6) = {+R, L, 0, 10*lc};
Point(7) = {-R, 0, 0, lc/5};
Point(8) = {+R, 0, 0, lc/5};

Line(1) = {5, 2};
Line(2) = {2, 1};
Line(3) = {1, 4};
Line(4) = {4, 3};
Line(5) = {3, 6};
Circle(6) = {7, 0, 8};


//////// ELECTRODE ////////
n_cnts = 4;//Floor((L-y_start)/(gap+l)); // numer of contcts
contact_list = {};   // contains contacts line tags
isolation_list = {}; // contains isolation line tags


//idx = 0;

y = y_start;
_p_old_l = 7; // tag of previous point on left
_p_old_r = 8; // tag of previous point on right

For t In {1:n_cnts}
    Printf("t= %g/%g   y=%g",t,n_cnts,y);
    _p = newp;
    Point(_p)   = {-R, y, 0, lc};
    Point(_p+1) = {-R, y+l, 0, lc};
    Point(_p+2) = {+R, y, 0, lc};
    Point(_p+3) = {+R, y+l, 0, lc};

    _l = newl;
    Line(_l)   = {_p_old_l, _p};
    Line(_l+1) = {_p, _p+1};
    Line(_l+2) = {_p_old_r, _p+2};
    Line(_l+3) = {_p+2, _p+3};
    
    isolation_list += _l;
    isolation_list += _l+2;
    
    contact_list += _l+1;
    contact_list += _l+3;
    
    y += gap+l;
    _p_old_l = _p+1;
    _p_old_r = _p+3;
EndFor

top_left = newl;
Line(top_left) = {_p_old_l, 5};
top_right = newl;
Line(top_right) = {_p_old_r, 6};


// make domain
Curve Loop(1) = {2, 3, 4, 5, -24, -22, -21, -18, -17, -14, -13, -10, -9, -6, 7, 8, 11, 12, 15, 16, 19, 20, 23, 1};
Plane Surface(1) = {1};


////// MESHING ////////
// transfinites
For _idx In {0:2*n_cnts-1}
    Printf("isolation= %g   contact = %g", isolation_list[_idx], contact_list[_idx]);
    Transfinite Curve isolation_list[_idx] = 40 Using Bump 1./10;
    Transfinite Curve contact_list[_idx] = 40 Using Bump 1./10;
    //Transfinite Curve isolation_list[_idx] = 50 Using Bump 1;
    //Transfinite Curve contact_list[_idx] = 3 Using Bump 1;
EndFor
Transfinite Curve {top_right,top_left} = 40 Using Progression 1.15;

//////// BOUNDARY CONDITIONS ////////
Physical Curve("isolation", 5) = isolation_list[];
Physical Curve("isolation", 5) += {top_right, top_left, 6};

Physical Curve("left", 1) = {2};
Physical Curve("right", 2) = {4};
Physical Curve("bottom", 3) = {3};
Physical Curve("top", 4) = {1, 5};

// each contact must have a differenct physical group 
For idx In {0:n_cnts-1}
    name = news;
    Physical Curve(name) = {contact_list[2*idx] , contact_list[2*idx+1]};
EndFor

Physical Surface("domain", 1) = {1};

Mesh 3;

