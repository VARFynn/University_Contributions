% Assignment I, Tijani & Lohre
%
%
% Percentage Deviation + First Shock (Productivity Increase)
%
% To compute percentage deviations, we changed everything to logs.
% The shock part changes to a positive price increase. 
% 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Declare variables and shocks
var log_c log_k log_n log_y log_inve log_en log_a log_p;
varexo ea ep;

% Declare parameters
parameters alfa betta gama delta sigma theta rhoa rhop sigmaa sigmap;

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


% Model block
model;
    % Household's consumption Euler equation
    exp(log_c)^(-sigma)  = (theta/(1-exp(log_n)))*(1/(exp(log_a)*(exp(log_k(-1)))^alfa * gama * exp(log_n)^(gama-1)*exp(log_en)^(1-alfa-gama)));

    % Household's intertemporal budget constraint
    exp(log_c)^(-sigma)  = betta * exp(log_c(+1))^(-sigma)*(exp(log_a(+1))*alfa*exp(log_k)^(alfa-1)*exp(log_n(+1))^gama*exp(log_en(+1))^(1-alfa-gama)+(1-delta));

    % Energy price determination
    exp(log_p)           = exp(log_a)*exp(log_k(-1))^(alfa)*exp(log_n)^(gama)*(1-alfa-gama)*exp(log_en)^(-alfa-gama);

    % Resource constraint
    exp(log_a)*exp(log_k(-1))^alfa*exp(log_n)^gama*exp(log_en)^(1-alfa-gama)+(1-delta)*exp(log_k(-1)) = exp(log_c) + exp(log_k) + exp(log_p)*exp(log_en);

    % Investment equation
    exp(log_inve)        = exp(log_k) - (1-delta)*exp(log_k(-1));

    % Production function
    exp(log_y)           = exp(log_a)*exp(log_k(-1))^alfa*exp(log_n)^gama*exp(log_en)^(1-alfa-gama);

    % Exogenous processes for total factor productivity and energy price
    log(exp(log_a))      = rhoa * log(exp(log_a(-1))) + ea;
    log(exp(log_p))      = rhop * log(exp(log_p(-1))) + ep;
end;

% Set initial values for variables
initval;
  log_k     = log(KSS);
  log_c     = log(CSS);
  log_a     = log(ASS);
  log_y     = log(YSS);
  log_inve  = log(ISS);
  log_en    = log(ENSS);
  log_n     = log(NSS);
  log_p     = log(PSS);
end;

% Set shocks
shocks;
var ep;               % Variance of the energy price shock
stderr 10;            % 10 % 
var ea = 0;           % Variance of the productivity shock shock = 0 -> to exclude
end;

% Perform stochastic simulation
stoch_simul(periods=2100,irf=20,order=1) log_y log_c log_inve log_k log_n log_en log_a log_p;

