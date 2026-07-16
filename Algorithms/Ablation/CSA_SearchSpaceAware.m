function [solution, score] = CSA_SearchSpaceAware( ...
                                projections, geo, angles, ...
                                Max_iter, AP, fl, Bound_dict, ...
                                population, metric, ...
                                Recon_algorithm, varargin)
% CSA_SEARCHSPACEAWARE Search-Space-Aware Crow Search Algorithm.
%
% This algorithm extends the standard Crow Search Algorithm (CSA) by
% introducing an adaptive search-space learning mechanism. A weight map is
% continuously updated according to the best solutions found so far and is
% then used to guide global exploration toward promising regions of the
% parameter space.
%
% Compared to the standard CSA:
%   - Local search is unchanged and follows memory positions.
%   - Global search uses weighted sampling instead of purely random
%     initialization.
%   - The search space becomes increasingly focused around good solutions.
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
%       Controls the probability of performing global exploration.
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
%       Reconstruction algorithm to be optimized.
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
%   2. Store each crow's best known position.
%   3. Build an adaptive weight map of the search space.
%   4. At each iteration:
%         - Local search follows memory positions.
%         - Global search uses weighted sampling.
%         - The weight map is updated using memory positions.
%   5. Return the best solution found.
%
% Notes:
%   - Lower fitness values indicate better solutions.
%   - Weighted exploration increases the probability of sampling
%     promising parameter values.
%   - The update rate gradually increases throughout optimization,
%     strengthening the influence of successful regions.
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

    %% Search-space learning parameters

    % Initial weight update amount
    Update_rate = 1;

    % Gradual increase in update strength
    Update_rate_inc = 1.1;

    %% Evaluate initial population

    for i = 1:N

        fprintf("iteration 0\n");

        fprintf(".:: crow #%g ", i);
        fprintf("%7.4f / ", xn(i,:));
        fprintf("\n");

        [ft(1,i), objectives(i,:)] = ...
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

    %% Initialize search-space model

    weight_map = weight_map_init(Bound_dict);

    %% Main optimization loop

    for t = 1:Max_iter

        %% Random selection of leaders

        num = ceil(N * rand(1,N));

        %% Generate new candidate positions

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

            % Global search
            else

                % Weighted exploration guided by
                % the learned search-space model
                xnew(i,:) = ...
                    weighted_init( ...
                        1, ...
                        Bound_dict, ...
                        weight_map);

            end

        end

        %% Update search-space model

        xn = xnew;

        % Update weight map using all memory positions.
        weight_map = ...
            weight_map_update( ...
                weight_map, ...
                Bound_dict, ...
                mem, ...
                Update_rate);

        % Increase update strength gradually
        Update_rate = Update_rate * Update_rate_inc;

        %% Evaluate generated solutions

        for i = 1:N

            fprintf("iteration %g\n", t);

            fprintf(".:: crow #%g ", i);
            fprintf("%7.4f / ", xn(i,:));
            fprintf("\n");

            [ft(1,i), objectives(i,:)] = ...
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

        %% Store best fitness

        ffit(t) = min(fit_mem);

        score(1,t) = ffit(t);

    end

    %% Extract global best solution

    ngbest = find(fit_mem == min(fit_mem));

    g_best = mem(ngbest(1),:);

    solution = g_best;

end