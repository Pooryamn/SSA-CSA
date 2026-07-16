function [solution, score] = SSACSA(projections, geo, angles, ...
                                   Max_iter, fl, Bound_dict, ...
                                   population, metric, ...
                                   Recon_algorithm, varargin)
% SSACSA Search-Space-Aware Crow Search Algorithm (SSA-CSA).
%
% This function performs automatic parameter optimization using a modified
% Crow Search Algorithm (CSA). The proposed method combines:
%
%   - Pareto-based pioneer selection
%   - Search-space-aware weighted sampling
%   - Adaptive local/global search switching
%   - Chaotic guidance using a Sine map
%
% The algorithm is designed to efficiently explore and exploit the
% parameter search space while improving convergence toward high-quality
% solutions.
%
% Inputs:
%   projections
%       Measured projection data.
%
%   geo
%       Scanner geometry structure.
%
%   angles
%       Projection acquisition angles.
%
%   Max_iter
%       Maximum number of optimization iterations.
%
%   fl
%       Flight length parameter controlling movement size.
%
%   Bound_dict
%       Dictionary containing parameter bounds.
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
%       Best parameter set found by the optimizer.
%
%   score
%       Best fitness value achieved at each iteration.
%
% Method:
%   The algorithm operates in four main stages:
%
%   1. Fitness Evaluation
%      Evaluate all individuals and initialize memory.
%
%   2. Pioneer Selection
%      Select promising individuals using Pareto-front analysis.
%
%   3. Search-Space Learning
%      Update a weight map to guide sampling toward promising
%      parameter regions.
%
%   4. Position Update
%      - Good individuals perform local search around pioneers.
%      - Weak individuals perform global exploration through
%        weighted sampling.
%
% Notes:
%   - Lower fitness values are assumed to be better.
%   - Weighted sampling gradually focuses the search on promising
%     regions.
%   - Pioneer selection becomes more selective as the optimization
%     progresses.
%   - The local/global search balance changes adaptively during
%     optimization.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Optional inputs

    Reference = varargin{1,1};

    %% Problem settings

    % Number of optimization variables
    pd = size(keys(Bound_dict),1);

    % Population size
    N = size(population,1);

    %% Population initialization

    x = population;

    % Current population
    xn = x;

    %% Pioneer selection parameters

    pioneers_selection_rate = 0.5;

    % Gradually reduce pioneer set size
    selection_rate_red = 1 - (1 / Max_iter);

    %% Chaotic guidance

    Chaos_map = Sin_Map(Max_iter * N);

    Chaos_map = reshape(Chaos_map, Max_iter, N);

    %% Local/global search control

    % Percentage of individuals performing local search
    AP_Percent = 0.6;

    % Gradual increase in local exploitation
    AP_Percent_inc = 1.01;

    %% Weight map update settings

    Update_rate = 1;

    Update_rate_inc = 1.1;

    %% Evaluate initial population

    for i = 1:N

        fprintf("iteration 0\n");

        fprintf(".:: crow #%g ", i);
        fprintf("%7.4f / ", xn(i,:));
        fprintf("\n");

        [ft(1,i), obj_arr(i,:)] = ...
            objective( ...
                projections, geo, angles, ...
                xn(i,:), keys(Bound_dict)', ...
                metric, Recon_algorithm, ...
                Reference);

        fprintf("\nFitness: %7.4f", ft(1,i));
        fprintf("\n________________________________________________\n");

    end

    %% Initialize memory

    % Best known position of each crow
    mem = x;

    % Fitness of memory positions
    fit_mem = ft;

    %% Initialize search-space model

    weight_map = weight_map_init(Bound_dict);

    %% Main optimization loop

    for t = 1:Max_iter

        %% Select pioneer individuals

        pioneers_indexes = ...
            find_frontiers( ...
                fit_mem', ...
                obj_arr, ...
                N, ...
                pioneers_selection_rate);

        % Decrease pioneer selection rate over time
        pioneers_selection_rate = ...
            pioneers_selection_rate * selection_rate_red;

        % Random pioneer assignment
        num = randi(numel(pioneers_indexes), 1, N);

        %% Define local/global search threshold

        % Better individuals perform local search
        ft_threshold = quantile(fit_mem, AP_Percent);

        % Increase local exploitation over time
        AP_Percent = AP_Percent * AP_Percent_inc;

        %% Update search-space weight map

        weight_map = ...
            weight_map_update( ...
                weight_map, ...
                Bound_dict, ...
                mem(pioneers_indexes,:), ...
                Update_rate);

        Update_rate = Update_rate * Update_rate_inc;

        %% Generate new population

        for i = 1:N

            % Local search
            if fit_mem(i) < ft_threshold

                xnew(i,:) = ...
                    x(i,:) + ...
                    fl * Chaos_map(t,i) * ...
                    (mem(num(i),:) - x(i,:));

                xnew(i,:) = ...
                    correct_individual( ...
                        xnew(i,:), ...
                        Bound_dict, ...
                        weight_map);

            % Global search
            else

                xnew(i,:) = ...
                    weighted_init( ...
                        1, ...
                        Bound_dict, ...
                        weight_map);

            end

        end

        %% Evaluate newly generated solutions

        xn = xnew;

        for i = 1:N

            fprintf("iteration %g\n", t);

            fprintf(".:: crow #%g ", i);
            fprintf("%7.4f / ", xn(i,:));
            fprintf("\n");

            [ft(1,i), obj_arr(i,:)] = ...
                objective( ...
                    projections, geo, angles, ...
                    xn(i,:), keys(Bound_dict)', ...
                    metric, Recon_algorithm, ...
                    Reference);

            fprintf("\nFitness: %7.4f", ft(1,i));
            fprintf("\n________________________________________________\n");

        end

        %% Update population memory

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

    %% Save learned search-space model

    save("Weight_map.mat", "weight_map", "-v7.3");

end