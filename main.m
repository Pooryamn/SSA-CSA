%% MAIN SCRIPT
% Automatic parameter optimization for CT/CBCT reconstruction algorithms
% using bio-inspired metaheuristic optimization methods.
%
% This script:
%   1. Loads the projection and geometry data.
%   2. Defines optimization settings.
%   3. Creates an initial population.
%   4. Runs the selected optimization algorithm.
%   5. Returns the best parameter set and fitness score.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
%% Load dataset
% To reduce execution time, data is loaded only if it is not already
% available in the workspace.
if ~exist('projections','var') || ~exist('angles','var') || ~exist('geo','var')

    load('Dataset/SophiaBeads/SophiaBeads64/projection.mat');
    load("Dataset/SophiaBeads/SophiaBeads64/angles.mat");
    load("Dataset/SophiaBeads/SophiaBeads64/geo.mat");
    load("Dataset/SophiaBeads/reference/reference.mat");

    %% Use only a portion of the data (optional)
    % N controls the amount of projection data used.
    %
    % N = 1:
    %   Use all projections.
    %   Higher reconstruction quality but longer runtime.
    %
    % N > 1:
    %   Use every N-th projection.
    %   Faster execution but potentially lower quality.
    N = 1;

    if N ~= 1
        projections = projections(:,:,1:N:end);
        angles = angles(1:N:end);
        geo.DSD = geo.DSD(1:N:end);
        geo.DSO = geo.DSO(1:N:end);
        geo.offDetector = geo.offDetector(:,1:N:end);
    end
end

%% Optimization settings

% Number of candidate solutions in the population
flock_size = 25;

% Maximum number of optimization iterations
Max_iter = 30;

% Flight length parameter
fl = 2;

% Awareness probability
% Used by CSA-based methods but not required for SSA-CSA.
AP = 0.1;

% Chaotic map used by chaos-based initialization methods.
% Available options:
%   "Sine"
%   "Chebyshev"
%   "Tent"
ChaosMap = "Sine";

%% Fitness evaluation settings

% Objective metric used to evaluate reconstruction quality.
% Weight settings can be modified directly inside Objective.m.
metric = "SNR_HFER";

%% Reconstruction algorithm

Recon_algorithm = "ASD_POCS";

%% ASD-POCS parameter search space

% Parameters to optimize
Parameter_names = {
    "iterations", ...
    "TViter", ...
    "maxL2err", ...
    "alpha", ...
    "lambda", ...
    "lambda_red", ...
    "alpha_red", ...
    "Ratio"
    };

% Search bounds defined as:
% [minimum_value maximum_value step_size]
parameter_bounds = {
    [5 50 1], ...
    [5 50 1], ...
    [50 1500 10], ...
    [0.0001 0.1 0.0001], ...
    [0.9 0.99 0.01], ...
    [0.9 0.99 0.01], ...
    [0.9 0.99 0.01], ...
    [0.9 0.99 0.01]
    };

%% Alternative parameter sets

% AwPCSD parameters
% Parameter_names = {"iterations","TViter","maxL2err", ...
%                    "lambda","lambda_red","delta"};
%
% parameter_bounds = {[5 50 1], ...
%                     [5 50 1], ...
%                     [50 1500 10], ...
%                     [0.9 0.99 0.01], ...
%                     [0.9 0.99 0.01], ...
%                     [0.005 2 0.005]};

% PICCS parameters
% Parameter_names = {"iterations","TViter","maxL2err", ...
%                    "alpha","lambda","lambda_red", ...
%                    "alpha_red","Ratio"};
%
% parameter_bounds = {[5 50 1], ...
%                     [5 50 1], ...
%                     [50 1500 10], ...
%                     [0.0001 0.1 0.0001], ...
%                     [0.9 0.99 0.01], ...
%                     [0.9 0.99 0.01], ...
%                     [0.9 0.99 0.01], ...
%                     [0.9 0.99 0.01]};

%% Create parameter dictionary
Bound_dict = dictionary(Parameter_names, parameter_bounds);

%% Population initialization

% Available initialization methods:
% RND_init      : Random initialization
% LHS_init      : Latin Hypercube Sampling
% DLU_init      : Distributed Linear Uniform initialization
% CLHS_init     : Chaotic Latin Hypercube Sampling
% Chaotic_init  : Chaotic sampling
% CDLU_init     : Chaotic Distributed Linear Uniform initialization

% crows = RND_init(flock_size, Bound_dict);
% crows = LHS_init(flock_size, Bound_dict);
% crows = DLU_init(flock_size, Bound_dict);
% crows = CLHS_init(flock_size, Bound_dict, ChaosMap);
% crows = Chaotic_init(flock_size, Bound_dict, ChaosMap);
crows = CDLU_init(flock_size, Bound_dict, ChaosMap);

%% Prior image (optional)

% Assign a prior/reference volume if available.
% For PICCS reconstruction, a prior image is required.
Ref_Prior = '';

%% Run optimization algorithm

% Available optimization methods:
% CSA
% CSA_Balance
% CSA_SuperiorSet
% CSA_SearchSpaceAware
% CSA_SearchSpaceAware_SuperiorSet
% SSACSA

% [solution,score] = CSA(...);
% [solution,score] = CSA_Balance(...);
% [solution,score] = CSA_SuperiorSet(...);
% [solution,score] = CSA_SearchSpaceAware(...);
% [solution,score] = CSA_SearchSpaceAware_SuperiorSet(...);

[solution,score] = SSACSA( ...
    projections, ...
    geo, ...
    angles, ...
    Max_iter, ...
    fl, ...
    Bound_dict, ...
    crows, ...
    metric, ...
    Recon_algorithm, ...
    Ref_Prior);

%% Results
% solution : Best parameter set found by the optimizer.
% score    : Best fitness value achieved.