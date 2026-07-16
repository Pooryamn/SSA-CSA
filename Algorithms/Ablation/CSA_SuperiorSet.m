function [solution, score] = CSA_SuperiorSet( ...
                            projections, geo, angles, ...
                            Max_iter, AP, fl, Bound_dict, ...
                            population, metric, ...
                            Recon_algorithm, varargin)
% CSA_SUPERIORSET Crow Search Algorithm with Superior-Set guidance.
%
% This algorithm extends the standard Crow Search Algorithm (CSA) by
% replacing random leader selection with guidance from a superior set of
% individuals. The superior set is generated using Pareto-front analysis,
% allowing individuals to follow high-quality and diverse solutions during
% the search process.
%
% Compared to the standard CSA:
%   - Local search is guided by selected superior individuals.
%   - Superior solutions are chosen using multi-objective information.
%   - Selection pressure gradually increases throughout optimization.
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
%       Controls the balance between:
%           - Local exploitation
%           - Global exploration
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
%       Best fitness value achieved at each iteration.
%
% Method:
%   1. Evaluate the initial population.
%   2. Store the best position of each individual.
%   3. Select a superior set using Pareto-front analysis.
%   4. During local search, individuals follow members of the
%      superior set instead of randomly chosen crows.
%   5. Gradually reduce the superior-set size to increase
%      exploitation over time.
%   6. Return the best solution found.
%
% Notes:
%   - Lower fitness values indicate better solutions.
%   - Pareto-based selection improves diversity among leaders.
%   - The superior set becomes more selective as optimization
%     progresses.
%   - Global exploration is still performed through random
%     population initialization.
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

    % Initial percentage of individuals used as leaders
    pioneers_selection_rate = 0.5;

    % Gradually reduce superior-set size
    selection_rate_red = 1 - (1 / Max_iter);

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

    % Best position found by each individual
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

        % Reduce superior-set size gradually
        pioneers_selection_rate = ...
            pioneers_selection_rate * selection_rate_red;

        %% Assign a superior leader to each individual

        num = randi(numel(pioneers_indexes), 1, N);

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
                    correct_individual(xnew(i,:), Bound_dict);

            % Global exploration
            else

                xnew(i,:) = init(1, Bound_dict);

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

        %% Update positions and memories

        for i = 1:N

            if Validate_individual(xnew(i,:), Bound_dict)

                % Update current position
                x(i,:) = xnew(i,:);

                % Update memory if an improved solution is found
                if ft(i) < fit_mem(i)

                    mem(i,:) = xnew(i,:);

                    fit_mem(i) = ft(i);

                end

            end

        end

        %% Store best fitness value

        ffit(t) = min(fit_mem);

        score(1,t) = ffit(t);

    end

    %% Extract global best solution

    ngbest = find(fit_mem == min(fit_mem));

    g_best = mem(ngbest(1),:);

    solution = g_best;

end
