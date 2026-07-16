function [solution, score] = CSA_Balance(projections, geo, angles, ...
                                        Max_iter, AP, fl, Bound_dict, ...
                                        population, metric, ...
                                        Recon_algorithm, varargin)
% CSA_BALANCE Balanced Crow Search Algorithm for parameter optimization.
%
% This algorithm is a modified version of the standard Crow Search
% Algorithm (CSA). Instead of using a random awareness mechanism,
% individuals are divided into local-search and global-search groups based
% on their fitness values.
%
% Better-performing individuals focus on exploitation by following the
% memory positions of other crows, while weaker individuals perform
% exploration through random population initialization. This strategy
% provides a dynamic balance between exploration and exploitation during
% the optimization process.
%
% Inputs:
%   projections
%       Projection data used for image reconstruction.
%
%   geo
%       Geometry structure describing the acquisition system.
%
%   angles
%       Projection acquisition angles.
%
%   Max_iter
%       Maximum number of optimization iterations.
%
%   AP
%       Awareness probability parameter.
%
%       Note:
%       This parameter is retained for compatibility with the standard
%       CSA interface but is not used directly in this implementation.
%
%   fl
%       Flight length parameter controlling movement size.
%
%   Bound_dict
%       Dictionary containing parameter search bounds.
%
%       Format:
%           parameter -> [min max step]
%
%   population
%       Initial population.
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
%       Best fitness value obtained at each iteration.
%
% Method:
%   1. Evaluate the initial population.
%   2. Store the best known position of each individual.
%   3. At each iteration:
%         - Rank individuals based on fitness.
%         - Good solutions perform local search.
%         - Weak solutions perform global exploration.
%   4. Gradually increase the percentage of individuals assigned to
%      local search.
%   5. Update memory whenever an improved solution is found.
%   6. Return the global best solution.
%
% Notes:
%   - Lower fitness values indicate better solutions.
%   - The local-search population grows over time.
%   - The algorithm naturally shifts from exploration to exploitation
%     as optimization progresses.
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

    %% Exploration-exploitation control

    % Initial fraction of individuals assigned to local search
    AP_Percent = 0.6;

    % Gradual increase in local search participation
    AP_Percent_inc = 1.01;

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

    % Best solution found by each individual
    mem = x;

    % Fitness of memory positions
    fit_mem = ft;

    %% Main optimization loop

    for t = 1:Max_iter

        %% Generate random leaders

        num = ceil(N * rand(1, N));

        %% Determine local-search threshold

        % Individuals better than this threshold
        % perform local exploitation.
        ft_threshold = quantile(fit_mem, AP_Percent);

        % Gradually increase exploitation pressure
        AP_Percent = AP_Percent * AP_Percent_inc;

        %% Generate new candidate solutions

        for i = 1:N

            % Local search for better solutions
            if fit_mem(i) < ft_threshold

                xnew(i,:) = ...
                    x(i,:) + ...
                    fl * rand * ...
                    (mem(num(i),:) - x(i,:));

                % Repair infeasible values
                xnew(i,:) = ...
                    correct_individual(xnew(i,:), Bound_dict);

            % Global search for weaker solutions
            else

                xnew(i,:) = init(1, Bound_dict);

            end

        end

        %% Evaluate new population

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

        %% Update positions and memory

        for i = 1:N

            if Validate_individual(xnew(i,:), Bound_dict)

                % Update current position
                x(i,:) = xnew(i,:);

                % Update memory if the new solution is better
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