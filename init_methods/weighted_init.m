function [population] = weighted_init(population_size, bound_dict, weight_map)
% WEIGHTED_INIT Create an initial population using weighted sampling.
%
% This function generates a population of candidate solutions by sampling
% parameter values according to user-defined probability weights.
% Unlike uniform random initialization, values with higher weights have a
% greater chance of being selected.
%
% Inputs:
%   population_size
%       Number of individuals (solutions) to create.
%
%   bound_dict
%       Dictionary (containers.Map) containing parameter definitions.
%       Each key is a parameter name and each value is a vector:
%
%           [min_value, max_value, step_size]
%
%   weight_map
%       Cell array containing sampling weights for each parameter.
%       Each weight vector must correspond to the parameter values
%       generated from its range definition.
%
% Outputs:
%   population
%       Matrix of size:
%
%           population_size × number_of_parameters
%
%       Each row represents one candidate solution and each column
%       represents a parameter.
%
% Method:
%   1. Generate all valid values for each parameter using the specified
%      minimum value, maximum value, and step size.
%   2. Use weighted sampling to select parameter values.
%   3. Repeat the process until the desired population size is reached.
%
% Example:
%   population = weighted_init(50, Bound_dict, weight_map);
%
% Notes:
%   Parameters with larger weights are sampled more frequently.
%
%   This initialization method can incorporate prior knowledge about
%   promising regions of the search space.
%
% Coded by::
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Read parameter definitions
    param_values = values(bound_dict);

    %% Create parameter value pools
    % Generate all valid values for each parameter.
    paramPool = cell(size(param_values,1), 1);

    K = 1;
    for i = 1:size(param_values,1)

        min_val = param_values{i,1}(1);
        max_val = param_values{i,1}(2);
        step    = param_values{i,1}(3);

        % Generate allowable parameter values
        available_values = min_val:step:max_val;

        paramPool{K} = available_values;
        K = K + 1;
    end

    %% Generate weighted population
    % Select values according to their assigned probabilities.
    for i = 1:population_size

        for j = 1:size(param_values,1)

            selected_value = ...
                weighted_Sampling(paramPool{j}, weight_map{j}, 1);

            population(i,j) = selected_value;

        end
    end

end