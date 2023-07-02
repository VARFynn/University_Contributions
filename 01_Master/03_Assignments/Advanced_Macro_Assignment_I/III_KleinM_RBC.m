% Assignment I, Tijani & Lohre
%
%
% Percentage Deviation + First Shock (Productivity Increase)
%
% We first had to log-binarize and then set up the matrix. 
% Then, call solab.m (by Paul Klein) to do generalized Schur decomposition on model  A * E(t)[z(t+1)] = B * z(t)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

format compact;
 clc; clear all; close all;


% Set parameter values
alfa    = 0.3; 
betta   = 0.99;
sigma   = 1;
sigmap  = 0.00001;
sigmaa  = 0.007;
theta   = 3.48;
gama    = 0.65;
delta   = 0.025;
rhoa    = 0.95;
rhop    = 0.5;

% Set steady state values
ASS     = 1;
PSS     = 1;
YSS     = 0.1627;
KSS     = 1.391;
NSS     = 0.2020;
CSS     = 0.1198;
ENSS    = 0.008; 
ISS     = 2.747;

% construct matrices A and B:
A  = zeros(8,8); 
B  = zeros(8,8);

ik	        = 1;
ia	        = 2; 
ip 	        = 3;
ic 	        = 4; 
iinve	   	= 5;
iy	        = 6;
in	        = 7;
ien	        = 8; 
 
% Matrix A (8x8 everything else is zero) 
A(1,ik) 	= (1-betta*(1-delta))*(alfa-1);
A(1,ia) 	= (1-betta*(1-delta));
A(1,ic)	 	= -sigma;
A(1,in) 	= (1-betta*(1-delta))*gama;
A(1,ien)	= (1-betta*(1-delta))*(1-alfa-gama);

A(4,ik) 	= KSS/YSS;

A(6,ik)		= 1/delta;

A(7,ia) 	= 1;

A(8,ip) 	= 1;


% Matrix B (8x8 everything else is zero) 
B(1,ic) 	= -sigma;

B(2,ic) 	= (theta/gama)*CSS*NSS;
B(2,iy) 	= -YSS+NSS*YSS;
B(2,in) 	= NSS*((theta/gama)*CSS+YSS);


B(3,ip) 	= PSS*ENSS;
B(3,iy) 	= -YSS*(1-alfa-gama);
B(3,ien)	= PSS*ENSS;

B(4,ik) 	= alfa + (1-delta)*(KSS/YSS);
B(4,ia) 	= 1;
B(4,ip) 	= -(PSS*ENSS)/YSS;
B(4,ic) 	= -CSS/YSS;
B(4,in) 	= gama;
B(4,ien) 	= -(PSS*ENSS/YSS)+1-alfa-gama;

B(6,ik) 	= (1-delta)/delta;
B(6,iinve)	 = 1;

B(5,ik) 	= -alfa;
B(5,ia) 	= (-1);
B(5,iy) 	= 1;
B(5,in) 	= -gama;
B(5,iinve) 	= -(1-alfa-gama)

B(7,ia) 	= rhoa;

B(8,ip) 	= rhop;

% call solab.m (by Paul Klein) to do generalized Schur decomposition on model  A * E(t)[z(t+1)] = B * z(t)
%
% solab.m need to be stored in same directory as "growth.m" or be set as path: in command bar: -> 'File' -> 'Set Path'
 
[G,H]		= solab(A,B,3)

