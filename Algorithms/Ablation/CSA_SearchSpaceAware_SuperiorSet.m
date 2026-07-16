function [solution, score] = CSA_SearchSpaceAware_SuperiorSet( ...
                                projections, geo, angles, ...
                                Max_iter, AP, fl, Bound_dict, ...
                                population, metric, ...
                                Recon_algorithm, varargin)
% CSA_SEARCHSPACEAWARE_SUPERIORSET Search-Space-Aware CSA with
% Superior-Set guidance.
%
% This algorithm extends the standard Crow Search Algorithm (CSA) by
% combining two improvements:
%
%   1. Superior-set selection using Pareto-front analysis.
%   2. Search-space learning using an adaptive weight map.
%
% The superior set contains promising individuals selected from the
% population based on both fitness and objective diversity. Information
% from these individuals is used to update the search-space model, which
% guides future global exploration toward more promising parameter regions.
%
% Inputs:
%   projections
%       Projection data used for reconstruction.
%
%   geo
%       Geometry structure of the imaging system.
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
%       Controls the balance between local exploitation and
%       global exploration.
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
%   metric
%       Objective metric used for evaluation.
%
%   Recon_algorithm
%       Reconstruction algorithm being optimized.
%
%   varargin
%       Optional inputs.
%
%       Reference
%           Prior/reference image used during evaluation.
%
% Outputs:
%   solution
%       Best parameter set found during optimization.
%
%   score
%       Best fitness value obtained at each iteration.
%
% Method:
%   1. Evaluate the initial population.
%   2. Store the best position of each individual.
%   3. Select a superior set using Pareto-front analysis.
%   4. Update an adaptive search-space weight map using the superior set.
%   5. At each iteration:
%         - Local search follows memory positions.
%         - Global search uses weighted sampling guided by the weight map.
%   6. Return the best solution found.
%
% Notes:
%   - Lower fitness values indicate better solutions.
%   - The superior-set size decreases gradually during optimization,
%     increasing selection pressure.
%   - Only superior individuals influence the search-space model.
%   - This variant combines objective diversity preservation with
%     search-space learning.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
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

    %% Superior-set settings

    % Initial fraction of population considered superior
    pioneers_selection_rate = 0.5;

    % Gradually reduce superior-set size
    selection_rate_red = 1 - (1 / Max_iter);

    %% Search-space learning settings

    % Weight update magnitude
    Update_rate = 1;

    % Gradual increase in update strength
    Update_rate_inc = 1.1;

    %% Initialize search-space model

    weight_map = weight_map_init(Bound_dict);

    %% Evaluate initial population

    for i = 1:N

        fprintf("iteration 0\n");

        fprintf(".:: crow #%g ", i);
        fprintf("%7.4f / ", xn(i,:));
        fprintf("\n");

        [ft(1,i), obj_arr(i,:)] = ...
            objective( ...
                projections, ...
                geo, ...
                angles, ...
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

        %% Select superior individuals

        pioneers_indexes = ...
            find_frontiers( ...
                fit_mem', ...
                obj_arr, ...
                N, ...
                pioneers_selection_rate);

        % Increase selection pressure over time
        pioneers_selection_rate = ...
            pioneers_selection_rate * selection_rate_red;

        %% Generate random leaders for chasing

        num = ceil(N * rand(1,N));

        %% Update search-space model

        % Learn promising parameter regions using
        % the superior individuals only.
        weight_map = ...
            weight_map_update( ...
                weight_map, ...
                Bound_dict, ...
                mem(pioneers_indexes,:), ...
                Update_rate);

        % Gradually strengthen the influence of the model
        Update_rate = Update_rate * Update_rate_inc;

        %% Generate candidate solutions

        for i = 1:N

            % Local search
            if rand > AP

                xnew(i,:) = ...
                    x(i,:) + ...
                    fl * rand * ...
                    (mem(num(i),:) - x(i,:));

                % Repair infeasible solutions
                xnew(i,:) = ...
                    correct_individual( ...
                        xnew(i,:), ...
                        Bound_dict);

            % Global search guided by weight map
            else

                xnew(i,:) = ...
                    weighted_init( ...
                        1, ...
                        Bound_dict, ...
                        weight_map);

            end

        end

        %% Evaluate generated solutions

        xn = xnew;

        for i = 1:N

            fprintf("iteration %g\n", t);

            fprintf(".:: crow #%g ", i);
            fprintf("%7.4f / ", xn(i,:));
            fprintf("\n");

            [ft(1,i), obj_arr(i,:)] = ...
                objective( ...
                    projections, ...
                    geo, ...
                    angles, ...
                    xn(i,:), ...
                    keys(Bound_dict)', ...
                    metric, ...
                    Recon_algorithm, ...
                    Reference);

            fprintf("\nFitness: %7.4f", ft(1,i));
            fprintf("\n________________________________________________\n");

        end

        %% Update positions and memory

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