#---------------------------------------------------------
#
# Advanced Micro and Macro Models of the Labor Market 
#
#---------------------------------------------------------

# Equation Solving [I typically used SymPy for Math Solving]
# see: https://docs.sympy.org/latest/guides/solving/index.html
# Meurer A, Smith CP, Paprocki M, Čertík O, Kirpichev SB, Rocklin M, Kumar A,
# Ivanov S, Moore JK, Singh S, Rathnayake T, Vig S, Granger BE, Muller RP,
# Bonazzi F, Gupta H, Vats S, Johansson F, Pedregosa F, Curry MJ, Terrel AR,
# Roučka Š, Saboo A, Fernando I, Kulal S, Cimrman R, Scopatz A. (2017) SymPy:
# symbolic computing in Python. *PeerJ Computer Science* 3:e103
# https://doi.org/10.7717/peerj-cs.103

# Install; If needed
# pip install sympy
# 
# import sympy
# print(sympy.__version__)

import sympy as sp

x = sp.Symbol('x')

# Define the equation to be solved as x^3 = 5
equation = sp.Eq(x**3, 5)

# Solve for x
solution = sp.solve(equation, x)
print(f"Exact Solution: {solution}")

numerical_solution = [sol.evalf() for sol in solution]
print(f"Numerical Solution: {numerical_solution}")



#%% Define Path 
import os
current_dir = os.path.dirname(os.path.abspath(__file__))
print(current_dir)

from pathlib import Path

current_dir = Path(__file__).resolve().parent
plotfolder = current_dir / 'Plots'
plotfolder.mkdir(parents=True, exist_ok=True)
print(f'Plotfolder created at: {plotfolder}')

#%% 
## divide into cells 
# Triple "" in Spyder; for note
def function(x):
    y = x**3 - 5
    return y
function(5)

func = lambda x: x**3 - 5 ## Lamda anonymous function
func(5)


from scipy.optimize import fsolve, least_squares  
import numpy as np 
import matplotlib.pyplot as plt

guess = 1
root = fsolve(func, guess)
print(root)

x = np.linspace(-10, 10, 1000)  # 100 points from -10 to 10
y = func(x)
plt.plot(x, y)


fig1,ax1 = plt.subplots()
ax1.plot(x,y)
ax1.set_title("Test Title")
fig1.savefig( os.path.join(plotfolder, "Graph_Test.pdf"))


#%% Gonna Solve a standard DMP here
import numpy as np
from scipy.optimize import fsolve, least_squares

def dmp_equilibrium(params):
    """
    Solve for (w, u, v) in a simple DMP model with:
    
      1) Beveridge curve: u = delta / [ lambda(theta) + delta ]
      2) Free Entry: (p - w) / (r + delta) = c / q(theta)
      3) The Nash Bargaining Solution: w = b + beta * (p - b) + beta * c * theta
      
    We further assume a CRTS CD: 
    M(v,u) = alpha * v^(alpha1) * u^(1-alpha1)
      
    Parameters
    ----------
    params : dict with keys:
        alpha   : Parameter in lambda(theta)
        alpha1  : Exponent in lambda(theta)
        delta   : Exogenous separation rate
        r       : Discount rate
        c       : Vacancy posting cost
        p       : Productivity
        b       : Unemployment benefit
        beta    : Bargaining power of workers
    
    Returns
    -------
    w_star : Equilibrium wage
    u_star : Equilibrium unemployment rate
    v_star : Equilibrium vacancy rate
    """

    alpha   = params['alpha']       # Factor in the matching function
    alpha1  = params['alpha1']      # Exponent in the matching function
    delta   = params['delta']       # Job destruction rate
    r       = params['r']           # Discount rate
    c       = params['c']           # Cost of posting a vacancy
    p       = params['p']           # Productivity
    b       = params['b']           # Unemployment benefit
    beta    = params['beta']        # Bargaining power

    guess_u = 0.1
    guess_v = 0.1
    guess_w = 0.5

    def equilibrium_equations(vars_):
        u, v, w = vars_
        
        # Ensure non-negativity
        if u < 0 or v < 0:
            return (1e6, 1e6, 1e6)

        # We know lamda(theta) is (M/v):
        def q(theta):
            return (alpha * u **(alpha1) * v **(1-alpha1))/v

        # And further q(theta) is theta * lam(theta):
        def lam(theta):
            return theta* q(theta)
        
        #And theta, the market tightness, is defined as:
        theta = v / u  

        # Equation 1: Beveridge curve
        # u = delta / [lambda(theta) + delta]
        lhs = u
        rhs = (delta / (lam(theta) + delta))
        eq1 = lhs - rhs

        # Equation 2: free-entry condition (job creation)
        # (p - w)/(r + delta) = c / q(theta)
        lhs  = (p - w) / (r + delta)
        rhs  = c / q(theta)
        eq2  = lhs - rhs 

        # Equation 3: wage from Nash bargaining
        # w = b + beta(p - b) + beta*c*theta
        lhs = w
        rhs = b + beta * (p - b) + beta * c * theta
        eq3 = lhs - rhs

        return (eq1, eq2, eq3)
    
    # Return optimals *
    u_star, v_star, w_star = fsolve(equilibrium_equations, (guess_u, guess_v, guess_w))
    return w_star, u_star, v_star

# Calibration
params = {
    'alpha' : 0.55,     # param in Matching function
    'alpha1' : 0.5,    # exponent in Matching function
    'delta' : 0.01,    # job destruction rate
    'r'     : 0.0025,  # discount rate
    'c'     : 0.21,    # vacancy posting cost
    'p'     : 1.0,     # productivity
    'b'     : 0.4,     # unempl benefit
    'beta'  : 0.5      # worker's bargaining power
}

w_star, u_star, v_star = dmp_equilibrium(params)

print("Equilibrium results:")
print(f"  w* = {w_star:.4f}")
print(f"  u* = {u_star:.4f}")
print(f"  v* = {v_star:.4f}")
print(f"  θ* = v/u = {v_star/u_star:.4f}")



# %% 

## This basically solves it graphically => theta matches

def wage_func(params,theta):
    alpha   = params['alpha']       # Factor in the matching function
    alpha1  = params['alpha1']      # Exponent in the matching function
    delta   = params['delta']       # Job destruction rate
    r       = params['r']           # Discount rate
    c       = params['c']           # Cost of posting a vacancy
    p       = params['p']           # Productivity
    b       = params['b']           # Unemployment benefit
    beta    = params['beta']        # Bargaining power
    return b + beta * (p - b) + beta * c * theta

def job_creation_func(params, theta):
    alpha   = params['alpha']       # Factor in the matching function
    alpha1  = params['alpha1']      # Exponent in the matching function
    delta   = params['delta']       # Job destruction rate
    r       = params['r']           # Discount rate
    c       = params['c']           # Cost of posting a vacancy
    p       = params['p']           # Productivity
    b       = params['b']           # Unemployment benefit
    beta    = params['beta']        # Bargaining power

    # Normalize unemployment to 1.
    u = 0.5
    # Given that theta = v/u, we have v = theta * u (and u=1 so v = theta)
    v = theta / u  

    # Define q(theta) as in your original code:
    def q(theta):
        return (alpha * u **(alpha1) * v **(1-alpha1))/v

    # And further lam(theta) is theta * q(theta):
    def lam(theta):
        return theta* q(theta)
    
    # Return the job creation condition:
    # Original: (p - w)/(r+delta) = c / q(theta)
    return p - c*(r+delta)/q(theta)


theta_vals = np.linspace(0.01, 10.0, 1000)
wage_func_vals = wage_func(params, theta_vals)
job_creation_func_vals = job_creation_func(params, theta_vals)

plt.figure(figsize=(8, 6))
plt.plot(theta_vals, wage_func_vals, label="Wage Curve", color='blue')
plt.plot(theta_vals, job_creation_func_vals, label="Job Creation Curve", color='red')
plt.ylim(0, 2)  # Set y-axis limits from 0 to 2
plt.xlabel("Theta")
plt.ylabel("Wage")
plt.title("Wage and Job Creation Curve")
plt.legend()
plt.show()

# %%

# We could also solve it with least squares and bounds (0,0,0) (1,1,1)

# %%

# Libraries


#import Functions.Steady_State as steady 

import numpy as np
import sys
import matplotlib.pyplot as plt

def production_function(x, y):
    return x * y

def solve_model(n, delta, rho, r, production_function, tol):
    theta = rho / (2 * (r + delta))
    
    grid = np.linspace(1 / n / 2, 1 - 1 / n / 2, n)
    l_density = 1 
    alphas = np.ones((n, n))
    u_density = np.repeat(0., n)  
    
    payoffs = np.empty([n, n])
    for i in range(n):
        x = grid[i]
        for j in range(n):
            y = grid[j]
            payoffs[i, j] = production_function(x, y)
    
    keep_iterating = True
    iteration = 0
    max_iterations = 10000
    
    while keep_iterating and iteration < max_iterations:
        alphas_old = alphas.copy()
        u_prev = u_density.copy()
        
        # Iterate on unemployment density
        e = sys.float_info.max
        while e > tol:
            u_density = delta * l_density / (delta + rho * np.dot(alphas, u_prev) / n)
            e = np.linalg.norm(u_prev - u_density)
            u_prev = u_density.copy()
        
        # Update alphas based on surplus comparison
        surplus = payoffs / (r + delta)
        alphas = (surplus > theta).astype(float)
        
        # Check convergence
        if np.all(np.abs(alphas - alphas_old) < tol):
            keep_iterating = False
        
        iteration += 1
    
    return grid, alphas, payoffs

# Run the model
n = 500
delta = 1
rho = 100
r = 1
tol = 1e12

grid, alphas, payoffs = solve_model(n, delta, rho, r, production_function, tol)

# Create the plot
plt.figure(figsize=(8, 8))
X, Y = np.meshgrid(grid, grid)
plt.pcolormesh(X, Y, alphas.T, cmap='Greys', shading='auto')
plt.xlabel('x')
plt.ylabel('y')
plt.title('Equilibrium Matching Sets')
plt.axis('square')
plt.xlim(0, 1)
plt.ylim(0, 1)
plt.grid(True)
plt.show()