function [solution, score] = CSA(projections, geo, angles, ...
                                Max_iter, AP, fl, Bound_dict, ...
                                population, metric, ...
                                Recon_algorithm, varargin)
% CSA Crow Search Algorithm (CSA) for parameter optimization.
%
% This function implements the standard Crow Search Algorithm (CSA)
% proposed by Askarzadeh for solving optimization problems. In this
% framework, each crow represents a candidate parameter set, while the
% memory of each crow stores the best solution found so far.
%
% During the search process:
%   - A crow may follow another crow toward its memorized position
%     (local exploitation).
%   - A crow may become aware of being followed, forcing the follower
%     to move to a random position (global exploration).
%
% The objective is to find the parameter set that minimizes the selected
% reconstruction quality metric.
%
% Inputs:
%   projections
%       Projection data used for image reconstruction.
%
%   geo
%       Geometry structure describing the imaging system.
%
%   angles
%       Projection acquisition angles.
%
%   Max_iter
%       Maximum number of optimization iterations.
%
%   AP
%       Awareness Probability.
%
%       Controls the balance between exploration and exploitation.
%
%       Large AP:
%           More exploration.
%
%       Small AP:
%           More exploitation.
%
%   fl
%       Flight length parameter controlling movement size.
%
%   Bound_dict
%       Dictionary containing the parameter search ranges.
%
%       Format:
%           parameter -> [min max step]
%
%   population
%       Initial population.
%
%       Size:
%           population_size × number_of_parameters
%
%   metric
%       Objective metric used to evaluate reconstruction quality.
%
%   Recon_algorithm
%       Reconstruction algorithm to optimize.
%
%   varargin
%       Optional inputs.
%
%       Reference
%           Prior/reference image used by the objective function.
%
% Outputs:
%   solution
%       Best parameter set found during optimization.
%
%   score
%       Best fitness value obtained at each iteration.
%
% Method:
%   1. Initialize population and memory.
%   2. Evaluate all candidate solutions.
%   3. For each iteration:
%        - Select a random crow to follow.
%        - Move toward its memory position.
%        - With probability AP, perform random exploration.
%   4. Update memories when better solutions are found.
%   5. Return the global best solution.
%
% Reference:
%   A. Askarzadeh,
%   "A Novel Metaheuristic Method for Solving Constrained
%   Engineering Optimization Problems: Crow Search Algorithm",
%   Computers & Structures, Vol. 169, pp. 1-12, 2016.
%
% Notes:
%   - This implementation solves a minimization problem.
%   - Lower fitness values correspond to better solutions.
%   - Due to the stochastic nature of CSA, different runs may
%     produce slightly different results.
%
% Author:
%   Original CSA:
%       Alireza Askarzadeh
%       Kerman Graduate University of Advanced Technology (KGUT)
%
%   Adapted for automatic reconstruction parameter optimization by:
%       <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Optional inputs

    Reference = varargin{1,1};

    %% Problem settings

    % Number of decision variables
    pd = size(keys(Bound_dict),1);

    % Population size
    N = size(population,1);

    %% Initialize population

    x = population;

    % Current population
    xn = x;

    %% Evaluate initial population

    for i = 1:N

        fprintf("iteration 0\n");

        fprintf(".:: crow #%g ", i);
        fprintf("%7.4f / ", xn(i,:));
        fprintf("\n");

        [ft(1,i), objectives(i,:)] = ...
            objective( ...
                projections, geo, angles, ...
                xn(i,:), ...
                keys(Bound_dict)', ...
                metric, ...
                Recon_algorithm, ...
                Reference);

        fprintf("\nFitness: %7.4f", ft(1,i));
        fprintf("\n________________________________________________\n");

    end

    %% Initialize memory

    % Best position found by each crow
    mem = x;

    % Fitness of memory positions
    fit_mem = ft;

    %% Main optimization loop

    for t = 1:Max_iter

        % Randomly select crows to follow
        num = ceil(N * rand(1, N));

        %% Generate new candidate positions

        for i = 1:N

            % Unaware crow: move toward memorized position
            if rand > AP

                xnew(i,:) = ...
                    x(i,:) + ...
                    fl * rand * ...
                    (mem(num(i),:) - x(i,:));

                % Repair infeasible solutions
                xnew(i,:) = ...
                    correct_individual(xnew(i,:), Bound_dict);

            % Aware crow: perform random exploration
            else

                xnew(i,:) = init(1, Bound_dict);

            end

        end

        %% Evaluate new positions

        xn = xnew;

        for i = 1:N

            fprintf("iteration %g\n", t);

            fprintf(".:: crow #%g ", i);
            fprintf("%7.4f / ", xn(i,:));
            fprintf("\n");

            [ft(1,i), objectives(i,:)] = ...
                objective( ...
                    projections, geo, angles, ...
                    xn(i,:), ...
                    keys(Bound_dict)', ...
                    metric, ...
                    Recon_algorithm, ...
                    Reference);

            fprintf("\nFitness: %7.4f", ft(1,i));
            fprintf("\n________________________________________________\n");

        end

        %% Update positions and memories

        for i = 1:N

            if Validate_individual(xnew(i,:), Bound_dict)

                % Update current position
                x(i,:) = xnew(i,:);

                % Update memory if improvement is found
                if ft(i) < fit_mem(i)

                    mem(i,:) = xnew(i,:);

                    fit_mem(i) = ft(i);

                end

            end

        end

        %% Record best fitness

        ffit(t) = min(fit_mem);

        score(1,t) = ffit(t);

    end

    %% Extract global best solution

    ngbest = find(fit_mem == min(fit_mem));

    g_best = mem(ngbest(1),:);

    solution = g_best;

end