###############################################################################
# Filename: Model_Solver.py
# Author: Fynn Lohre
# Date: May 14, 2025
# V: 1.5
#
# Description:
#   This is the code for my term paper where I think about the students'
#   decision to enroll to Universities/programs. Basically, it is 
#   devided into two parts 1) Fricitionless Baseline and then 2) 
#   Directed Search. The models are explained in chapter 2 of the paper.
#
# Notes:
#   This is rather quick and dirty coded with no subfiles with functions, 
#   which are to be called or similar. Hence, it should just straight-up
#   run. 
#
# ToDo/Coding Assumptions: 
#   Are annotated in blue where useful for later. 
#
# AI USAGE: 
#   Used Claude 3.7 Sonnet to
#           Comment & Organize My (messy) Code 
#           Help On Specific Problems
#           For Help When Nothing Converged OR Slowly
#  
#  Used my few o3 runs for 
#       Feedback on the code given my latex model code: 
#       FYI: I noted this feedback down in the end of my code for myself, but also for readers of the code
#       # Feedback seems in line with code
#
#   Speedboost options available (acc. to Sonnet)
#       1 Vectorize more operations: Replace more of the explicit loops with NumPy operation (started):
#           Tried replacing the for‑loop in calculate_matching() by a vectorised draw (SO FAR NOT WORKED)
#       2 Use sparse matrices: If most students apply to only a few programs, p is a sparse matrix. Using scipy.sparse could save memory and computation. (not really)
#       3 Some sort of f type storage of numbers; tbh: I'm to afraid with floating numbers changes as this might lead to this same bias as the usual excel one 
#       4 I found online: Use broadcasts instead of nested for loops, e.g. I used it inside update_admission_probabilities,  "100× speed‑up for free" according to stack exchange

###############################################################################

#%%

## THIS IS THE PRE-TERMINAL; INSERT ASSUMPTIONS + RUN NAME HERE
## THEN RUN IT ALL
## THIS IS JUST FOR BETTER HANDLING, I (an AI) COMMENTED ALL THINGS LATER
# NOTE: I have not yet centralized functional forms like e.g. f(x,y)
# NOTE: This could be done at some point

# ORG
name_run                = "Costs"           
version                 = "1.5"
# scale                   =  1           # As this was computationally too heavy, I saw no reasonable matrix setup, I scale it down --> 1 is all normal
max_iter                = 200
tol                     = 1e-3
ten_sample              = 0             # set 1 for 10 % run 

# BASE
T_run                   = 54            # Folkepension 74
r_run                   = 0.03          # Typically somewhere 1--5; see Glenn Harrison papers huge hetereogenity
alpha_run               = 1             # Harmonized OSO to 1
beta_run                = 1.2           # Academics 1.2x outside option
gamma_run               = -0.15         # 15% of brutto wage
length_run              = 3             # 3 bach, 5 mast

# SEARCH
a_run                   = 8             # Loven
omega_run               = 0.5         
k_base_run              = 0.04      
# k_slope_run             = 0.005       # This was to play with increasing decreasing costs => taken out



## LIBRARIES
import os
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from datetime import date
from scipy.stats import norm 
from scipy.stats import gaussian_kde
from scipy.stats import truncnorm
import pandas as pd

np.random.seed(218) 

## FILE STRUCTURE
base_dir = os.path.dirname(os.path.abspath(__file__))
folder_name = f"{name_run}_{version}"
folder_path = os.path.join(base_dir, folder_name)

if not os.path.exists(folder_path):
    os.makedirs(folder_path)
    print(f"Folder '{folder_path}' created successfully.")
else:
    print(f"Folder '{folder_path}' already exists.")

os.chdir(folder_path)
print(f"Everything is going to be saved to: {os.getcwd()}")

#------------------------------------------------------------------------------
#
#
# PART I 
# FRICTIONLESS
#
#
#------------------------------------------------------------------------------


###############################################################################
# MODEL PARAMETERS
###############################################################################

# Main parameters
T        = T_run                # Planning horizon (years)
r        = r_run                # Annual discount rate
alpha    = alpha_run            # Outside-option wage parameter
beta     = beta_run             # College wage parameter
gamma    = gamma_run            # Tuition-cost parameter (gamma=0 ⇒ free college)
length   = length_run           # Used as a unique lenght for programs; basically tao instead of tao(y)

## N_x = 77300                  # This was the raw part; now loaded


# Unitype N_y removed

file_path = r'C:\Users\au738471\OneDrive - Aarhus universitet\Desktop\12_PhD_Courses\MicroMacroModels\RAW.xlsx'

df_uni = pd.read_excel(file_path, sheet_name="UNI", usecols=["END", "OBS", "RESCALED"])
x_uni = df_uni


# BOUNDS
upper_bounds = x_uni["END"].values
lower_bounds = [0] + list(upper_bounds[:-1])
bin_centers = [(l + u) / 2 for l, u in zip(lower_bounds, upper_bounds)]
bin_widths = [u - l for l, u in zip(lower_bounds, upper_bounds)]  # Thanks Claude for making the last bin correct size! :) 

plt.figure(figsize=(10, 5))


# OBS 
plt.bar(bin_centers, x_uni["OBS"], width=bin_widths, align='center',
        edgecolor='black', alpha=0.7, label="OBS (n = 1791)")

# RESCALED, now over obs
plt.bar(bin_centers, x_uni["RESCALED"], width=bin_widths, align='center',
        color='red', alpha=0.4, label="RESCALED (target n = 677; actual n = 679)")


plt.xlabel("University Types Value  (y; bin center)")
plt.ylabel("Count")
plt.title("University Type Distribution")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig('university_types.png')
plt.show()



# Create y_grid by drawing values from each bin proportional to RESCALED
y_grid = []

for low, high, count in zip(lower_bounds, upper_bounds, x_uni["RESCALED"]):
    n = int(count)  # RESCALED is already integer
    if n > 0:
        draws = np.random.uniform(low, high, size=n)
        y_grid.extend(draws)

y_grid = np.array(y_grid)

# Check
print(f"y_grid contains {len(y_grid)} programs (should be {x_uni['RESCALED'].sum()})")
print("Sample:", y_grid[:10])

# So, recreate prev used vars: 

# Number of programs; data determined just redefine -- because I used it later in the code
# NOTE: at some point harmonize
N_y = len(y_grid)

# Seats: We know public number is: 66676 - this is basically kappa
# NOTE: at some point harmonize, this is unnecessary confusing

# Compute average students per program
total_students = 66676

avg_per_program = int(total_students / len(y_grid))
print("Average students per program:", avg_per_program)

#  Draw seats per program from normal distribution
np.random.seed(218) ## NOTE: REMOVE LATER; had it here to run this chunk only
seats_per_program = np.random.normal(loc=avg_per_program, scale=10, size=len(y_grid))


# Round to integers
seats_per_program = np.round(seats_per_program).astype(int)

# Optional: check
print("Sample seat sizes:", seats_per_program[:10])
print("Total capacity:", seats_per_program.sum())


## NOTE: THIS DEFINTION IS aproximate
# mu_y
# sigma_y
## 
## def create_data_from_excel():
##     # Test Data
##     types = np.array([0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 
##                       0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1.0])
##     
##     num_programs = np.array([20, 20, 30, 30, 30, 30, 30, 30, 50, 50, 
##                              50, 50, 18, 14, 22, 20, 2, 40, 20, 20])
##     
##     mu_values = np.array([0, 0, 0, 0.1, 0.128154, 0.178829, 0.2286, 0.262716, 0.28475, 0.333543,
##                           0.354442, 0.403764, 0.438513, 0.462177, 0.509274, 0.533735, 0.570141, 0.609861, 0.625474, 0.8])
##     
##     sigma_values = np.array([0, 0, 0, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1,
##                              0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1])
##     
##     mean_capacity = np.array([116] * 20)  # All have the same mean capacity of 116
##     
##     # Calculate the total number of programs
##     N_y = np.sum(num_programs)
##     
##     # Initialize arrays
##     y_grid = np.zeros(N_y)
##     mu_y = np.zeros(N_y)
##     sigma_y = np.zeros(N_y)
##     seats_per_program = np.zeros(N_y)
##     
##     # Generate programs according to the specification
##     index = 0
##     for i in range(len(types)):
##         # For each type bin, generate the specified number of programs
##         for j in range(num_programs[i]):
##             # Assign a random y-value within the bin range
##             if i < len(types) - 1:
##                 y_grid[index] = np.random.uniform(types[i], types[i+1])
##             else:
##                 # For the last bin, use the exact value
##                 y_grid[index] = types[i]
##             
##             # Assign mu and sigma
##             mu_y[index] = mu_values[i]
##             sigma_y[index] = sigma_values[i]
##             
##             # Assign capacity (use mean capacity with some random variation)
##             seats_per_program[index] = np.random.normal(mean_capacity[i], mean_capacity[i] * 0.1)
##             seats_per_program[index] = max(10, seats_per_program[index])  # Ensure positive capacity
##             
##             index += 1
##     
##     # Sort all arrays based on y_grid
##     sort_indices = np.argsort(y_grid)
##     y_grid = y_grid[sort_indices]
##     mu_y = mu_y[sort_indices]
##     sigma_y = sigma_y[sort_indices]
##     seats_per_program = seats_per_program[sort_indices]
##     
##     # Fix sigma values of 0 to a small positive number to avoid division by zero
##     sigma_y[sigma_y == 0] = 0.01
##     
##     # Ensure capacities are integers
##     seats_per_program = np.round(seats_per_program).astype(int)
##     
##     return y_grid, mu_y, sigma_y, seats_per_program, N_y
## 
## # Generate program data from Excel info
## y_grid, mu_y, sigma_y, seats_per_program, N_y = create_data_from_excel()


## # Student grud NOTE: CURRENTLY SIMULATED
# mu = 0.5       # Mean
# sigma = 0.15   # Standard deviation
# a, b = (0 - mu) / sigma, (1 - mu) / sigma
# x_grid = truncnorm.rvs(a, b, loc=mu, scale=sigma, size=N_x)# Generate normally distributed values within [0, 1]
# x_grid = np.round(x_grid, 2)
# print("Sum:", np.mean(x_grid))
# print("Min:", np.min(x_grid))
# print("Max:", np.max(x_grid))

## NOW CODED
# Excel-Datei => Hardcoded; will not be uploaded.. If you need this; just ask me -- but don't wanna put it on my GH 
file_path = r'C:\Users\au738471\OneDrive - Aarhus universitet\Desktop\12_PhD_Courses\MicroMacroModels\RAW.xlsx'
df = pd.read_excel(file_path, sheet_name="STUDENTS", usecols=["End", "OBS", "RESCALED"])
x = df
print(x)

# VISUALIZE IT for the paper
upper_bounds = x["End"].values
lower_bounds = [0] + list(upper_bounds[:-1])
bin_centers = [(l + u) / 2 for l, u in zip(lower_bounds, upper_bounds)]

plt.figure(figsize=(10, 5))

# Plot RESCALED first (in red, behind)
plt.bar(bin_centers, x["RESCALED"], width=0.01, align='center',
        color='red', alpha=0.4, label="RESCALED (target n = 77300; actual n = 77296)")

# Then plot OBS on top
plt.bar(bin_centers, x["OBS"], width=0.01, align='center',
        edgecolor='black', alpha=0.7, label="OBS (n = 52563)")
plt.xlabel("Student Types Value  (x; bin center)")
plt.ylabel("Count")
plt.title("Student Type Distribution")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig('student_types.png')
plt.show()

# Create x_grid by drawing values from each bin
x_grid = []

for low, high, count in zip(lower_bounds, upper_bounds, x["RESCALED"]):
    n = int(round(count))  # Ensure integer number of draws
    if n > 0:
        draws = np.random.uniform(low, high, size=n)
        x_grid.extend(draws)

x_grid = np.array(x_grid)
N_x = len(x_grid)
print(N_x)










# Optional: check
print(f"x_grid contains {len(x_grid)} students -> if this is around 77300; it works")
print("Sample:", x_grid[:10])

# Print some information about the created data
print(f"Total programs: {N_y}")
print(f"Total students: {N_x}")
print(f"Total seats: {seats_per_program.sum()}")
print(f"Average seats per program: {seats_per_program.mean():.1f}")



###############################################################################
# HILFS FUNKTIONEN
###############################################################################


# present-value factors
pv_college = ((1 + r)**(-length) - (1 + r)**(-T)) / r
pv_cost    = (1 - (1 + r)**(-length))           / r
pv_work    = (1 - (1 + r)**(-T))                / r

# NPV functions
def f_npv(x, y):
    return beta * x * y * pv_college - gamma * pv_cost

def W0_npv(x):
    return 0.125 * alpha * x * pv_work

# compute full arrays:
#   f_mat: shape (N_x, N_y)
#   W0   : shape (N_x,)
f_mat = f_npv(x_grid[:, None], y_grid[None, :])
W0    = W0_npv(x_grid)

# quick sanity check
print("f_mat shape:", f_mat.shape)
print("W0    shape:", W0.shape)
print("example f( x_grid[0], y_grid[0] ) =", f_mat[0,0])
print("example W0( x_grid[0] )         =", W0[0])



### Check how it looks for all the groups
# Four selected ability types
x_types = [0.2, 0.4, 0.6, 0.8]

# Smooth program-quality grid
y_vals = np.linspace(0, 1, 200)

plt.figure(figsize=(10, 6))
for x_val in x_types:
    # college NPV curve
    plt.plot(y_vals, f_npv(x_val, y_vals), label=f"f(x={x_val:.1f})")
    # outside option NPV
    plt.hlines(W0_npv(x_val),
               xmin=y_vals.min(),
               xmax=y_vals.max(),
               linestyles='dashed',
               label=f"W0(x={x_val:.1f})")

plt.xlabel("Program Quality (y)")
plt.ylabel("Net Present Value")
plt.title("NPV of College Attendance vs. Work for Selected Ability Types")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig('npv_curves_by_ability.png')
plt.show()



###############################################################################
# Application Set
###############################################################################
# boolean matrix: True if student i applies to program j
application_matrix = (f_mat >= W0[:, None])

# (Optional) Summary counts
applications_per_student = application_matrix.sum(axis=1)   # how many programs each student applies to
applicants_per_program  = application_matrix.sum(axis=0)   # how many students apply to each program

# Quick sanity check
print("Shape of application matrix:", application_matrix.shape)
print("First 5 students apply to this many programs:", applications_per_student[:5])
print("First 5 programs receive this many applicants:", applicants_per_program[:5])




###############################################################################
# NC DETERMINATION & ADMISSION
###############################################################################

# initialize
prog_order       = np.argsort(y_grid)[::-1]               # program indices sorted by quality desc
admitted_matrix  = np.zeros_like(application_matrix, bool) # track admissions
available        = np.ones(N_x, dtype=bool)               # students still unadmitted
cutoffs          = np.full(N_y, np.nan)                   # worst admitted ability per program

for j in prog_order:
    # eligible applicants for program j
    apps = np.where(application_matrix[:, j] & available)[0]
    if apps.size == 0:
        cutoffs[j] = 0.0                                # no admits ⇒ cutoff = 0
        continue
    # random tie‐break: shuffle then stable sort by ability desc
    np.random.shuffle(apps)
    apps_sorted = apps[np.argsort(-x_grid[apps], kind='mergesort')]
    # admit up to capacity
    k = seats_per_program[j]
    admitted = apps_sorted[:k]
    admitted_matrix[admitted, j] = True
    # mark them unavailable for other programs
    available[admitted] = False
    # record cutoff as lowest ability admitted
    cutoffs[j] = x_grid[admitted].min()

# (Optional) inspect results
print("Cutoff abilities for first 5 programs:", np.round(cutoffs[:5], 3))
print("Total admitted students:", admitted_matrix.sum())

###############################################################################
# FIGURES
###############################################################################

#----------------------------------------------------------------------------- 
# Avg. Ability
#-----------------------------------------------------------------------------

# compute average and lowest ability of admitted students for each program
avg_admitted_ability    = np.zeros(N_y)
lowest_admitted_ability = np.zeros(N_y)

for j in range(N_y):
    admitted = np.where(admitted_matrix[:, j])[0]
    if admitted.size > 0:
        abilities = x_grid[admitted]
        avg_admitted_ability[j]    = abilities.mean()
        lowest_admitted_ability[j] = abilities.min()
    else:
        avg_admitted_ability[j]    = 0.0
        lowest_admitted_ability[j] = 0.0

# sort programs by quality for plotting
order         = np.argsort(y_grid)
y_sorted      = y_grid[order]
avg_sorted    = avg_admitted_ability[order]
lowest_sorted = lowest_admitted_ability[order]

# plot both series, with lowest in yellow
plt.figure(figsize=(5, 4))
plt.plot(y_sorted, avg_sorted,    marker='.', linestyle='none', label='Average Ability')

plt.xlabel("Program Quality (y)")
plt.ylabel("Student Ability")
plt.title("Average Ability of Admitted Students", fontsize=14)
plt.suptitle("Frictionless",  fontsize=10)
plt.grid(True)
plt.tight_layout()
plt.savefig('avg_lowest_student_by_program_quality.png')
plt.show()





#----------------------------------------------------------------------------- 
# Matching SET 
#-----------------------------------------------------------------------------

# refine application matrix: only keep applications if x ≥ NC(y)
application_matrix = application_matrix & (x_grid[:, None] >= cutoffs[None, :])

# compute min and max program quality among remaining applications for each student
min_program = np.full(N_x, np.nan)
max_program = np.full(N_x, np.nan)

for i in range(N_x):
    apps = np.where(application_matrix[i, :])[0]
    if apps.size > 0:
        qualities = y_grid[apps]
        min_program[i] = qualities.min()
        max_program[i] = qualities.max()
    else:
        min_program[i] = 0.0
        max_program[i] = 0.0

# sort students by ability for plotting
order            = np.argsort(x_grid)
x_sorted         = x_grid[order]
min_prog_sorted  = min_program[order]
max_prog_sorted  = max_program[order]


plt.figure(figsize=(5, 4))

# one call to vlines is much faster than looping
plt.vlines(
    x_sorted,          # x positions
    min_prog_sorted,   # bottom of each line
    max_prog_sorted,   # top of each line
    color='navy',
    linewidth=0.5
)
plt.xlabel("Student Ability (x)")
plt.ylabel("Programme Quality (y)")
plt.title("Application/Matching Set M(x,y)")
plt.xlim(0, 1)
plt.ylim(0, 1)
plt.grid(True, linestyle='--', alpha=0.5)
plt.tight_layout()
plt.savefig('matching_set_equilibrium.png')
plt.show()


def save_equilibrium_summary(
    filename='equilibrium_summary.txt'
):
    # compute key aggregates
    total_admitted   = admitted_matrix.sum()
    total_capacity   = seats_per_program.sum()
    attendance_rate  = total_admitted / N_x
    capacity_util    = total_admitted / total_capacity

    # build summary text
    summary = []
    summary.append(f"Version: {version} | Date: {date.today()}")
    summary.append("")
    summary.append("--- Equilibrium summary ---------------------------------------")
    summary.append(f"High School Graduates         : {N_x} graduates")
    summary.append(f"Total students admitted       : {total_admitted} students")
    summary.append(f"Total capacity                : {total_capacity} seats")
    summary.append(f"College attendance rate       : {attendance_rate:.3f}")
    summary.append(f"Capacity utilization          : {capacity_util:.3f}")
    summary.append("")
    summary.append("--- With parameters ------------------------------------------")
    summary.append(f"T     = {T_run}")
    summary.append(f"r     = {r_run}")
    summary.append(f"alpha = {alpha_run}")
    summary.append(f"beta  = {beta_run}")
    summary.append(f"gamma = {gamma_run}")
    summary.append(f"length= {length_run}")

    summary_text = "\n".join(summary)

    # print and save
    print(summary_text)
    with open(filename, 'w') as f:
        f.write(summary_text)

# call it
save_equilibrium_summary()

# %%

###############################################################################
# SU SWITCH
###############################################################################


# increase SU subsidy ⇒ gamma is more negative; here we double its magnitude
gamma_more = 2 * gamma

# define new NPV function under higher SU
def f_npv_more(x, y):
    return beta * x * y * pv_college - gamma_more * pv_cost

# recompute f_mat and application set (still require x ≥ cutoff)
f_mat_more            = f_npv_more(x_grid[:, None], y_grid[None, :])
application_more      = (f_mat_more >= W0[:, None]) & (x_grid[:, None] >= cutoffs[None, :])

# recompute, for each student, the min/max program quality they apply to
min_prog_more = np.full(N_x, 0.0)
max_prog_more = np.full(N_x, 0.0)
for i in range(N_x):
    apps = np.where(application_more[i, :])[0]
    if apps.size > 0:
        qs = y_grid[apps]
        min_prog_more[i] = qs.min()
        max_prog_more[i] = qs.max()

# sort these according to x_sorted (same order as baseline)
min_more_sorted = min_prog_more[order]
max_more_sorted = max_prog_more[order]

# overlay on the equilibrium matching‐set plot
plt.figure(figsize=(5, 4))
# baseline in navy

# higher‐SU in light blue
plt.vlines(x_sorted, min_more_sorted, max_more_sorted,
           color='lightblue', linewidth=0.5, label='2× SU')

plt.vlines(x_sorted, min_prog_sorted, max_prog_sorted,
           color='navy', linewidth=0.5, label='Baseline SU')

plt.xlabel("Student Ability (x)")
plt.ylabel("Programme Quality (y)")
plt.title("Application/Matching Set M(x,y); Higher SU")
plt.xlim(0, 1)
plt.ylim(0, 1)
plt.legend()
plt.grid(True, linestyle='--', alpha=0.5)
plt.tight_layout()
plt.savefig('matching_set_SU_comparison.png')
plt.show()







#----------------------------------------------------------------------------- 
# 3. Beta change
#-----------------------------------------------------------------------------

# re allocate as funct 
# NOTE: INclude it better in the code
def allocate_admissions(app_mat):
    admitted = np.zeros_like(app_mat, bool)
    available = np.ones(N_x, bool)
    cuts = np.zeros(N_y)
    for j in prog_order:
        apps = np.where(app_mat[:, j] & available)[0]
        if apps.size == 0:
            cuts[j] = 0.0
            continue
        np.random.shuffle(apps)
        sorted_apps = apps[np.argsort(-x_grid[apps], kind='mergesort')]
        admits = sorted_apps[:seats_per_program[j]]
        admitted[admits, j] = True
        available[admits] = False
        cuts[j] = x_grid[admits].min()
    return admitted, cuts



# 1) Build the beta=0.5 NPV
beta0 = 0.5
def f_npv_beta0(x, y):
    return beta0 * x * y * pv_college - gamma * pv_cost

# 2) New application matrix (no cutoff filter yet)
f_mat_beta0   = f_npv_beta0(x_grid[:, None], y_grid[None, :])
app_beta0_raw = (f_mat_beta0 >= W0[:, None])

# 3) Re‐allocate admissions under beta
admitted_beta0, cutoffs_beta0 = allocate_admissions(app_beta0_raw)

# 4) Filter by the new beta cutoffs and compute min/max program quality per student
app_beta0 = app_beta0_raw & (x_grid[:, None] >= cutoffs_beta0[None, :])
min_prog0 = np.zeros(N_x); max_prog0 = np.zeros(N_x)
for i in range(N_x):
    apps = np.where(app_beta0[i, :])[0]
    if apps.size:
        qs = y_grid[apps]
        min_prog0[i], max_prog0[i] = qs.min(), qs.max()

min0_sorted = min_prog0[order]
max0_sorted = max_prog0[order]

# 5) Plot baseline vs beta
plt.figure(figsize=(5, 4))

# baseline SU in navy
plt.vlines(x_sorted, min_prog_sorted, max_prog_sorted,
           color='navy', linewidth=0.5, label='Baseline Beta (1.2)')

plt.vlines(x_sorted, min0_sorted, max0_sorted,
           color='tomato', linewidth=0.5, label='Lower Beta (0.5)')

plt.xlabel("Student Ability (x)")
plt.ylabel("Programme Quality (y)")
plt.title("Application/Matching Set M(x,y); Lower Beta")
plt.xlim(0, 1); plt.ylim(0, 1)
plt.legend()
plt.grid(True, linestyle='--', alpha=0.5)
plt.tight_layout()
plt.savefig('matching_set_beta0.png')
plt.show()








########################################
# SCALE DOWN TO REDUCE COMPUTE
########################################

ten_sample = 1

# if ten_sample == 1:
#     # Subsample programs (every 10th program)
#     prog_idx = np.arange(N_y)[::10]
#     y_grid = y_grid[prog_idx]
#     seats_per_program = seats_per_program[prog_idx]
# 
#     # Update number of programs
#     N_y = len(y_grid)
#     print(f"Running on {N_y} programs (10% subsample)")
# 
#     # Optional: subset existing application_matrix if already defined
#     if 'application_matrix' in locals():
#         application_matrix = application_matrix[:, prog_idx]
#     if 'admitted_matrix' in locals():
#         admitted_matrix = admitted_matrix[:, prog_idx]
# 
#     # Display new capacities
# #     print(f"Total capacity after scaling: {seats_per_program.sum()}")
# 
# if ten_sample == 1:
#     # Compute min and max program quality among remaining applications for each student
#     min_program = np.full(N_x, np.nan)
#     max_program = np.full(N_x, np.nan)
#     for i in range(N_x):
#         apps = np.where(application_matrix[i, :])[0]
#         if apps.size > 0:
#             qualities = y_grid[apps]
#             min_program[i] = qualities.min()
#             max_program[i] = qualities.max()
#         else:
#             min_program[i] = 0.0
#             max_program[i] = 0.0
# 
#     # Sort students by ability for plotting
#     order = np.argsort(x_grid)
#     x_sorted = x_grid[order]
#     min_sorted = min_program[order]
#     max_sorted = max_program[order]
# 
#     # Plot matching set for subsample
#     plt.figure(figsize=(5, 4))
#     plt.vlines(
#         x_sorted,
#         min_sorted,
#         max_sorted,
#         color='navy',
#         linewidth=0.5
#     )
#     plt.xlabel("Student Ability (x)")
#     plt.ylabel("Programme Quality (y)")
#     plt.title("Equilibrium Matching Set for 10% Subsample")
#     plt.xlim(0, 1)
#     plt.ylim(0, 1)
#     plt.grid(True, linestyle='--', alpha=0.5)
#     plt.tight_layout()
#     plt.savefig('matching_set_subsample.png')
#     plt.show()
#------------------------------------------------------------------------------
# PART X: SCALE DOWN BOTH STUDENTS AND PROGRAMS BY 1/10 AND FULL RECOMPUTATION
#------------------------------------------------------------------------------
if ten_sample == 1:
    # 10% subsample of students
    sample_idx_x = np.arange(N_x)[::10]
    x_grid_sub   = x_grid[sample_idx_x]
    N_x_sub      = len(x_grid_sub)
    print(f"Running on {N_x_sub} students (10% subsample)")

    # 10% subsample of programs (every 10th)
    sample_idx_y = np.arange(N_y)[::10]
    y_grid_sub   = y_grid[sample_idx_y]
    seats_sub    = seats_per_program[sample_idx_y]
    N_y_sub      = len(y_grid_sub)
    print(f"Running on {N_y_sub} programs (10% subsample)")

    # Recompute NPV matrices for subsample
    f_mat_sub = f_npv(x_grid_sub[:, None], y_grid_sub[None, :])
    W0_sub    = W0_npv(x_grid_sub)

    # Initial application matrix for subsample
    application_sub = (f_mat_sub >= W0_sub[:, None])

    # Admission allocation on subsample
    prog_order_sub = np.argsort(y_grid_sub)[::-1]
    admitted_sub   = np.zeros_like(application_sub, bool)
    available_sub  = np.ones(N_x_sub, dtype=bool)
    cutoffs_sub    = np.full(N_y_sub, np.nan)

    for idx_j, j in enumerate(prog_order_sub):
        apps = np.where(application_sub[:, j] & available_sub)[0]
        if apps.size == 0:
            cutoffs_sub[j] = 0.0
            continue
        np.random.shuffle(apps)
        sorted_apps = apps[np.argsort(-x_grid_sub[apps], kind='mergesort')]
        k = seats_sub[idx_j]
        admits = sorted_apps[:k]
        admitted_sub[admits, j] = True
        available_sub[admits]   = False
        cutoffs_sub[j] = x_grid_sub[admits].min()

    # Matching set: recompute application set with cutoff filter
    application_final = (f_mat_sub >= W0_sub[:, None]) & (x_grid_sub[:, None] >= cutoffs_sub[None, :])

    # Compute matching set ranges
    min_prog = np.zeros(N_x_sub)
    max_prog = np.zeros(N_x_sub)
    for i in range(N_x_sub):
        apps = np.where(application_final[i, :])[0]
        if apps.size:
            qs = y_grid_sub[apps]
            min_prog[i] = qs.min()
            max_prog[i] = qs.max()
        else:
            min_prog[i] = 0.0
            max_prog[i] = 0.0

    # Sort for plotting
    order_x = np.argsort(x_grid_sub)
    x_sorted = x_grid_sub[order_x]
    min_sorted = min_prog[order_x]
    max_sorted = max_prog[order_x]

    # Equilibrium summary for subsample
    total_admitted_sub = admitted_sub.sum()
    total_capacity_sub = seats_sub.sum()
    attendance_rate_sub = total_admitted_sub / N_x_sub
    capacity_util_sub = total_admitted_sub / total_capacity_sub if total_capacity_sub>0 else np.nan

    print(f"Version: {version} | Date: {date.today()}")
    print("\n--- Equilibrium summary (10% subsample) ---------------------------------------")
    print(f"High School Graduates         : {N_x_sub} graduates")
    print(f"Total students admitted       : {total_admitted_sub} students")
    print(f"Total capacity                : {total_capacity_sub} seats")
    print(f"College attendance rate       : {attendance_rate_sub:.3f}")
    print(f"Capacity utilization          : {capacity_util_sub:.3f}")
    print("\n--- Scaled x10 -----------------------------------------------------------")
    print(f"High School Graduates         : {N_x_sub*10} graduates")
    print(f"Total students admitted       : {total_admitted_sub*10} students")
    print(f"Total capacity                : {total_capacity_sub*10} seats")
    print(f"College attendance rate       : {attendance_rate_sub:.3f}")
    print(f"Capacity utilization          : {capacity_util_sub:.3f}")

    # Plot matching set for subsample
    plt.figure(figsize=(5, 4))
    plt.vlines(x_sorted, min_sorted, max_sorted, linewidth=0.5)
    plt.xlabel("Student Ability (x)")
    plt.ylabel("Programme Quality (y)")
    plt.title("Equilibrium Matching Set for 10% Subsample (Recomputed)")
    plt.xlim(0, 1)
    plt.ylim(0, 1)
    plt.grid(True, linestyle='--', alpha=0.5)
    plt.tight_layout()
    plt.savefig('matching_set_subsample_recomputed.png')
    plt.show()





#------------------------------------------------------------------------------
#
#
# PART II 
# FRICTIONLESS
#
#
#------------------------------------------------------------------------------


###############################################################################
# HIst. Prob
###############################################################################

# This is currently drawn around the grid 
mu_y    = np.random.normal(loc=y_grid, scale=0.05)
sigma_y = np.full(N_y, 0.05)

# Just create mat with prob based on normal dist. -- When omega 1 this is the fix term
pi_hist = np.empty_like(f_mat)
for j in range(len(y_grid)):
    pi_hist[:, j] = norm.cdf((x_grid - mu_y[j]) / sigma_y[j])


###############################################################################
# Merit Congestion with Random Cutoff
###############################################################################

#-- THIS IS ITERATED ON !!

#### NOTE: THis was changed from the que lenght cutoff proability; 13.05.2025
#### NOTE: Que lenght cutoff lies in Model_Solver_1.4 offline in MMMOL Folder


def pi_cong_cutoff_with_ties(A):
    N_x, N_y = A.shape
    pi = np.zeros((N_x, N_y), float)
    cutoffs = np.zeros(N_y)
    # compute cutoffs c_j
    for j in range(N_y):
        apps = np.where(A[:, j])[0]
        s = seats_per_program[j]
        if len(apps) >= s:
            sorted_abils = np.sort(x_grid[apps])
            cutoffs[j] = sorted_abils[-s]
        else:
            cutoffs[j] = x_grid.min()
    # fill the matrix with the probabilites
    for j in range(N_y):
        c = cutoffs[j]
        apps = np.where(A[:, j])[0]
        at_cut = apps[x_grid[apps] == c]
        n_ties = len(at_cut)
        for i in range(N_x):
            xi = x_grid[i]
            if xi > c:
                pi[i, j] = 1.0
            elif xi == c and n_ties > 0:   # This could be done different, e.g. n over n_ties; i tried a little bit with it but the compute was crazily slow and didnt change smth 
                pi[i, j] = 1.0 / n_ties
            else:
                pi[i, j] = 0.0
    return pi

###############################################################################
# Costs
###############################################################################


# j starts at 1; can set this to k_base + k_j // for now kept that out
k_base = k_base_run
def k_app(rank):
    return k_base

###############################################################################
# BR
###############################################################################


# This is below run in the fix point algorithm
def best_response(pi_row, f_row):
    expected_surplus = pi_row * f_row                                           # Calculate benefits (ze s tilde)
    order = np.argsort(-expected_surplus)                                       # Sort descending (sorted list)
    keep = np.zeros_like(expected_surplus, bool)                                # Initialize applications
    cum_prod = 1.0                                                              # Initialize probability
    for rank, j in enumerate(order[:a_run], start=1):                           # Loop over all programs
        delta = cum_prod * expected_surplus[j] - k_app(rank)                    # calc MU
        if delta < 0:                                                           # Check worthwhile
            break                                                               # Stop applying
        keep[j] = True                                                          # Apply here
        cum_prod *= (1 - pi_row[j])                                             # Update probability
    return keep

###############################################################################
# Fixed Point Algo
###############################################################################

omega    = omega_run


# initial guess: frictionless (apply wherever f>=W0)
A = (f_mat >= W0[:, None])

for it in range(max_iter):
    pi_cong_mat = pi_cong_cutoff_with_ties(A)                                     # (N_x, N_y)
    pi_current = omega * pi_hist + (1 - omega) * pi_cong_mat                      # calc actual probability

    A_new = np.vstack([best_response(pi_current[i], f_mat[i])                     # Now set up new matrice for each student; like we had it in class
                       for i in range(len(x_grid))])

    diff = (A_new ^ A).mean()                                                     # Look at change
    print(f" Still Converging, Klappe die {it:2d} 'te | Diffffff: {diff:.5f}")    # some semantics
    if diff < tol:
        break
    A = A_new                                                                     # Update it here. NOTE: Forgot this in prev runs; led to weird never converging
else:
    print("Warning: max_iter reached without convergence.")

application_matrix = A
pi_final = pi_current

###############################################################################
# Seat allocation
###############################################################################


prog_order = np.argsort(y_grid)[::-1]                                           # highest program first
admitted = np.zeros_like(A, bool)                                               # admitted true false
available = np.ones(len(x_grid), bool)                                          # start with all available
cutoffs = np.zeros(len(y_grid))                                                 # beginning cutoffs are all zero

# Just assign them in a domination like assignment 
for j in prog_order:
    pool = np.where(application_matrix[:, j] & available)[0]
    if pool.size:
        np.random.shuffle(pool)
        ranked = pool[np.argsort(-x_grid[pool], kind='mergesort')]
        chosen = ranked[:seats_per_program[j]]
        admitted[chosen, j] = True
        available[chosen] = False
        cutoffs[j] = x_grid[chosen].min()

###############################################################################
# Sum
###############################################################################

def save_directed_search_summary(filename='directed_search_summary.txt'):
    # Compute aggregates
    total_students = len(x_grid)
    total_applications = application_matrix.sum()
    total_admitted = admitted.sum()
    total_capacity = seats_per_program.sum()
    attendance_rate = total_admitted / total_students
    applications_per_student = total_applications / total_students

    # Build summary text
    summary = []
    summary.append(f"Version: {version} | Date: {date.today()}")
    summary.append("")
    summary.append("--- Directed-search summary ---------------------------------------")
    summary.append(f"Graduates                      : {total_students:,}")
    summary.append(f"Applications submitted        : {total_applications:,}")
    summary.append(f"Applications per Graduate      : {applications_per_student:.2f}")
    summary.append(f"Admitted students             : {total_admitted:,}")
    summary.append(f"Total capacity                : {total_capacity:,}")
    summary.append(f"College attendance rate       : {attendance_rate:.3f}")
    summary.append("")
    summary.append("--- With parameters ----------------------------------------------")
    summary.append(f"T        = {T_run}")
    summary.append(f"r        = {r_run}")
    summary.append(f"alpha    = {alpha_run}")
    summary.append(f"beta     = {beta_run}")
    summary.append(f"gamma    = {gamma_run}")
    summary.append(f"length   = {length_run}")
    summary.append(f"omega    = {omega}")
    summary.append(f"k_base   = {k_base}")

    # Combine to text
    summary_text = "\n".join(summary)

    # Print and save
    print(summary_text)
    with open(filename, 'w') as f:
        f.write(summary_text)

# Call the function
save_directed_search_summary()

###############################################################################
# Figure 1 -- Set
###############################################################################

plt.figure(figsize=(8, 6))
title = "Application Set"

# Method 1: Scatter plot of all applications
application_indices = np.where(application_matrix)
plt.scatter(x_grid[application_indices[0]], y_grid[application_indices[1]], 
            alpha=0.1, s=5, color='blue', marker='.')
plt.xlabel("Student Ability (x)")
plt.ylabel("Program Quality (y)")
plt.title(title)
plt.xlim(0, 1)
plt.ylim(0, 1)
plt.grid(True, linestyle='--', alpha=0.5)
plt.tight_layout()
plt.savefig('Application_Set_DS.png')
plt.show()



###############################################################################
# Figure 2 -- Heatmap
###############################################################################


# This is basically the above in heated

plt.figure(figsize=(8, 6))
# Create a 2D histogram of applications
x_bins = 75
y_bins = 100
H, x_edges, y_edges = np.histogram2d(
    x_grid[application_indices[0]], 
    y_grid[application_indices[1]], 
    bins=[x_bins, y_bins],
    range=[[0, 1], [0, 1]]
)

# Plot the heatmap
plt.imshow(H.T, origin='lower', aspect='auto', 
           extent=[0, 1, 0, 1], 
           cmap='Blues')
plt.colorbar(label='Number of Applications')
plt.xlabel("Student Ability (x)")
plt.ylabel("Program Quality (y)")
plt.title(f"{title} -- Heatmap")
plt.grid(True, linestyle='--', alpha=0.3)
plt.tight_layout()
plt.savefig('Application_Set_HM_DS.png')
plt.show()


###############################################################################
# 9.  Figure 3 --Who was now admitted
###############################################################################

# Initialize arrays to store values
average_ability = []
highest_ability = []

# Loop over each program (i.e., each column in admitted matrix)
for j in range(admitted.shape[1]):
    admitted_students = admitted[:, j] == 1
    admitted_abilities = x_grid[admitted_students]
    
    if admitted_abilities.size > 0:
        avg = admitted_abilities.mean()
        high = admitted_abilities.max()
    else:
        avg = np.nan
        high = np.nan
    
    average_ability.append(avg)
    highest_ability.append(high)

average_ability = np.array(average_ability)
highest_ability = np.array(highest_ability)

# Sort by program quality (just for clean plotting)
sorted_idx = np.argsort(y_grid)
sorted_y = y_grid[sorted_idx]
sorted_avg = average_ability[sorted_idx]
sorted_high = highest_ability[sorted_idx]

plt.figure(figsize=(5, 4))
plt.scatter(sorted_y, sorted_avg, s=10, label='Average Ability', alpha=0.7)
plt.xlabel("Program Quality (y)")
plt.ylabel("Student Ability")
plt.title("Average Ability of Admitted Students", fontsize=14)
plt.suptitle("Frictions",  fontsize=10)
plt.grid(True)
plt.tight_layout()
plt.savefig('ADMISSION_DS.png')
plt.show()

###############################################################################
# Figure 3 --Who was now admitted
###############################################################################

#Based on Code on DST 
app_counts = np.array([1, 2, 3, 4, 5, 6, 7, 8])
student_numbers = np.array([67500, 40923, 26417, 16134, 9814, 6296, 3931, 2423])
total_students = student_numbers.sum()
proportions = student_numbers / total_students  # Convert to proportions

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
axes = axes.flatten()  # Flatten to easily access with single index

# P1
empirical_mean = np.average(app_counts, weights=student_numbers)
axes[0].bar(app_counts, proportions, color='purple', width=0.7, alpha=0.7, edgecolor='black')
axes[0].set_title(f"Empirical Distribution\nMean: {empirical_mean:.2f}", fontsize=12)
axes[0].set_xlabel("Applications per Student", fontsize=10)
axes[0].set_ylabel("Proportion", fontsize=10)
axes[0].set_xlim(0.5, 8.5)
axes[0].set_xticks(app_counts)
axes[0].grid(True, alpha=0.3, axis='y')

# P2
all_applications_per_student = application_matrix.sum(axis=1).astype(int)
all_mean = all_applications_per_student.mean()

# Count 
all_counts = np.zeros(9)  # Index 0 will be empty, indices 1-8 correspond to applications
unique_vals, counts = np.unique(all_applications_per_student, return_counts=True)
for val, count in zip(unique_vals, counts):
    if 1 <= val <= 8:  # Only include values in our range
        all_counts[val] = count
all_props = all_counts / all_counts.sum()  # Convert to proportions

axes[1].bar(range(1, 9), all_props[1:], color='blue', width=0.7, alpha=0.7, edgecolor='black')
axes[1].set_title(f"All Students\nMean: {all_mean:.2f}", fontsize=12)
axes[1].set_xlabel("Applications per Student", fontsize=10)
axes[1].set_ylabel("Proportion", fontsize=10)
axes[1].set_xlim(0.5, 8.5)
axes[1].set_xticks(app_counts)
axes[1].grid(True, alpha=0.3, axis='y')

# Plot 3 
low_x_mask = x_grid < 0.4
low_x_filtered_app_matrix = application_matrix[low_x_mask]
low_x_applications_per_student = low_x_filtered_app_matrix.sum(axis=1).astype(int)
low_x_mean = low_x_applications_per_student.mean()

# Count
low_x_counts = np.zeros(9)
unique_vals, counts = np.unique(low_x_applications_per_student, return_counts=True)
for val, count in zip(unique_vals, counts):
    if 1 <= val <= 8:
        low_x_counts[val] = count
low_x_props = low_x_counts / low_x_counts.sum()

axes[2].bar(range(1, 9), low_x_props[1:], color='green', width=0.7, alpha=0.7, edgecolor='black')
axes[2].set_title(f"Students (x < 0.4)\nMean: {low_x_mean:.2f}", fontsize=12)
axes[2].set_xlabel("Applications per Student", fontsize=10)
axes[2].set_ylabel("Proportion", fontsize=10)
axes[2].set_xlim(0.5, 8.5)
axes[2].set_xticks(app_counts)
axes[2].grid(True, alpha=0.3, axis='y')

# P4
high_x_mask = x_grid > 0.8
high_x_filtered_app_matrix = application_matrix[high_x_mask]
high_x_applications_per_student = high_x_filtered_app_matrix.sum(axis=1).astype(int)
high_x_mean = high_x_applications_per_student.mean()

# C
high_x_counts = np.zeros(9)
unique_vals, counts = np.unique(high_x_applications_per_student, return_counts=True)
for val, count in zip(unique_vals, counts):
    if 1 <= val <= 8:
        high_x_counts[val] = count
high_x_props = high_x_counts / high_x_counts.sum()

axes[3].bar(range(1, 9), high_x_props[1:], color='orange', width=0.7, alpha=0.7, edgecolor='black')
axes[3].set_title(f"Students (x > 0.8)\nMean: {high_x_mean:.2f}", fontsize=12)
axes[3].set_xlabel("Applications per Student", fontsize=10)
axes[3].set_ylabel("Proportion", fontsize=10)
axes[3].set_xlim(0.5, 8.5)
axes[3].set_xticks(app_counts)
axes[3].grid(True, alpha=0.3, axis='y')

max_prop = max([
    proportions.max(),
    all_props[1:].max(),
    low_x_props[1:].max(),
    high_x_props[1:].max()
])
for ax in axes:
    ax.set_ylim(0, max_prop * 1.1)  # Add 10% padding
fig.suptitle("Applications per Student", fontsize=16, y=0.98)
plt.tight_layout()
plt.subplots_adjust(top=0.92)
plt.savefig('APPL_NRS_DS.png')
plt.show()
