% Assignment I, Tijani & Lohre
%
%
% Computing Steady State
%
% This file computes the steady state values calculated in excercise II.
% Hence, we just set up the Model. 
% The command oo_.dr.ys allows to extract the respective part. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Declare variables and shocks
var c k n y inve en a p;
varexo ea ep;

% Declare parameters
parameters alfa betta gama delta sigma theta rhoa rhop sigmaa sigmap;

% Set parameter values
alfa    = 0.3; 
betta   = 0.99;
sigma   = 1;
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
sigmap  = 0.00001;
sigmaa  = 0.007;

% Model block
model;
    % Household's consumption Euler equation
    c^(-sigma)  = (theta/(1-n))*(1/(a*(k(-1))^alfa * gama * n^(gama-1)*en^(1-alfa-gama)));

    % Household's intertemporal budget constraint
    c^(-sigma)  = betta * c(+1)^(-sigma)*(a(+1)*alfa*k^(alfa-1)*n(+1)^gama*en(+1)^(1-alfa-gama)+(1-delta));

    % Energy price determination
    p           = a*k(-1)^(alfa)*n^(gama)*(1-alfa-gama)*en^(-alfa-gama);

    % Resource constraint
    a*k(-1)^alfa*n^gama*en^(1-alfa-gama)+(1-delta)*k(-1) = c + k + p*en;

    % Investment equation
    inve        = k - (1-delta)*k(-1);

    % Production function
    y           = a*k(-1)^alfa*n^gama*en^(1-alfa-gama);

    % Exogenous processes for total factor productivity and energy price
    log(a)      = rhoa * log(a(-1)) + ep;
    log(p)      = rhop * log(p(-1)) + ea;
end;

% Set initial values for variables
initval;
  k     = KSS;
  c     = CSS;
  a     = ASS;
  y     = YSS;
  inve  = ISS;
  en    = ENSS;
  n     = NSS;
  p     = PSS;
end;

stoch_simul(periods=5,order=1);