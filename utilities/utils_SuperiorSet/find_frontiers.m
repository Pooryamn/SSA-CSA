function indexes = find_frontiers(fitness_arr, objective_array, ...
                                  population_size, selection_rate)
% FIND_FRONTIERS Select a set of promising individuals for local search.
%
% This function identifies a subset of high-quality individuals that can
% be used as leaders or reference solutions during the optimization
% process. The selection combines:
%
%   1. Pareto-optimal solutions (multi-objective quality)
%   2. Best fitness solutions (single-objective quality)
%
% The resulting set represents a balance between overall fitness and
% objective diversity.
%
% Inputs:
%   fitness_arr
%       Column vector containing fitness values for all individuals.
%
%   objective_array
%       Matrix containing objective values for each individual.
%
%       Size:
%           population_size × number_of_objectives
%
%   population_size
%       Total number of individuals in the population.
%
%   selection_rate
%       Fraction of the population to be selected as frontier
%       individuals.
%
%       Example:
%           selection_rate = 0.2
%
%       selects approximately 20% of the population.
%
% Outputs:
%   indexes
%       Row vector containing the indexes of the selected frontier
%       individuals.
%
% Method:
%   1. Determine the desired frontier set size.
%   2. Identify Pareto-optimal individuals.
%   3. If the Pareto set is larger than the target size:
%         - Randomly select individuals from the Pareto front.
%   4. If the Pareto set is smaller than the target size:
%         - Keep all Pareto individuals.
%         - Fill the remaining positions using the best fitness values.
%
% Notes:
%   - Pareto-optimal individuals help preserve solution diversity.
%   - Fitness-based selection ensures that high-quality solutions are
%     retained.
%   - The selected frontier can be used as a guiding set for local search
%     or exploitation phases of an optimization algorithm.
%
% Example:
%   indexes = find_frontiers( ...
%                 fitness_arr, ...
%                 objective_array, ...
%                 50, ...
%                 0.2);
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Determine frontier size

    Size_of_set = ceil(population_size * selection_rate);

    %% Create individual indexes

    % Used to map selected solutions back to the population.
    ordered_idx = 1:population_size;

    %% Find Pareto-optimal individuals

    pareto_front_indexes = ...
        find_pareto_set([objective_array ordered_idx']);

    %% Build frontier set

    if size(pareto_front_indexes,2) > Size_of_set

        % Too many Pareto solutions:
        % randomly select the required number.
        indexes = pareto_front_indexes( ...
            randperm(numel(pareto_front_indexes), Size_of_set));

    else

        % Sort individuals according to fitness
        Sorted_fitness = ...
            sortrows([fitness_arr ordered_idx'], 1);

        Sorted_fitness_indexes = Sorted_fitness(:,end)';

        % Remove Pareto solutions to avoid duplicates
        Sorted_fitness_indexes = ...
            setdiff(Sorted_fitness_indexes, pareto_front_indexes);

        % Keep all Pareto solutions and complete the set
        % using the best fitness individuals.
        indexes = [ ...
            pareto_front_indexes ...
            Sorted_fitness_indexes( ...
                1:Size_of_set-size(pareto_front_indexes,2)) ...
        ];

    end

end

