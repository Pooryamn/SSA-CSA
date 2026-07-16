function [population] = RND_init(population_size, bound_dict)
% RND_INIT Create a random initial population.
%
% This function generates a population of candidate solutions for an
% optimization algorithm. Each parameter value is randomly selected from
% its allowed range based on the specified minimum value, maximum value,
% and step size.
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
% Outputs:
%   population
%       Matrix of size:
%
%           population_size × number_of_parameters
%
%       Each row represents one candidate solution and each column
%       represents a parameter.
%
% Example:
%   bounds = containers.Map;
%   bounds("param1") = [0 10 1];
%   bounds("param2") = [5 15 2];
%
%   population = RND_init(100, bounds);
%
% Coded by::
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Read and validate input data
    param_names = keys(bound_dict);
    param_values = values(bound_dict);

    check_inputs(param_names, param_values);

    %% Create a pool of valid values for each parameter
    % Each pool contains all values between min and max
    % using the specified step size.
    paramPool = cell(size(param_values,1), 1);

    K = 1;
    for i = 1:size(param_values,1)

        min  = param_values{i,1}(1);
        max  = param_values{i,1}(2);
        step = param_values{i,1}(3);

        % Generate all allowed values for this parameter
        available_values = min:step:max;

        paramPool{K} = available_values;
        K = K + 1;
    end

    %% Generate random population
    % For each individual, randomly select one value from
    % each parameter pool.
    for i = 1:population_size
        for j = 1:size(param_values,1)

            selected_value = ...
                paramPool{j}(randi(length(paramPool{j})));

            population(i, j) = selected_value;
        end
    end
end


%% CHECK_INPUTS FUNCTION
function check_inputs(param_names, param_values)
% CHECK_INPUTS Validate parameter names and parameter bounds.
%
% This function checks that:
%   1. Parameter names are strings.
%   2. Parameter definitions are numeric vectors.
%   3. Each definition contains exactly three elements:
%          [min, max, step]
%   4. Minimum value is smaller than maximum value.
%   5. Step size fits within the defined range.

    %% Check parameter names
    for i = 1:length(param_names)

        if ~isstring(param_names{i})
            error("Parameter names must be strings.");
        end
    end

    %% Check parameter bounds
    for i = 1:length(param_values)

        % Bounds must be numeric
        if ~isnumeric(param_values{i})
            error("Parameter bounds must be a numeric vector: [min max step].");
        end

        % Bounds must contain exactly three elements
        if numel(param_values{i}) ~= 3
            error("Parameter bounds must be a numeric vector: [min max step].");
        end

        % Minimum must be smaller than maximum
        if param_values{i}(1) > param_values{i}(2)
            error("Minimum value must be smaller than maximum value.");
        end

        % Range must be large enough for the step size
        if (param_values{i}(2) - param_values{i}(1)) < param_values{i}(3)
            error("The range (max - min) must be greater than or equal to the step size.");
        end
    end
end
