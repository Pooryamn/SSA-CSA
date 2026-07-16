function [population] = LHS_init(population_size, bound_dict)
% LHS_INIT Create an initial population using Latin Hypercube Sampling (LHS).
%
% This function generates a population of candidate solutions using the
% Latin Hypercube Sampling method. LHS provides a more uniform coverage
% of the search space than purely random sampling by ensuring that samples
% are distributed across the entire range of each parameter.
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
%   population = LHS_init(100, bounds);
%
% Coded by::
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Read and validate input data
    param_names = keys(bound_dict);
    param_values = values(bound_dict);

    check_inputs(param_names, param_values);

    %% Extract minimum and maximum values for each parameter
    % These values are used to scale the LHS samples
    % to the actual parameter ranges.
    paramPool = cell(size(param_values,1), 1);

    K = 1;
    for i = 1:size(param_values,1)

        min_val(K) = param_values{i,1}(1);
        max_val(K) = param_values{i,1}(2);

        K = K + 1;
    end

    %% Generate Latin Hypercube samples
    d = size(param_values,1);
    population = zeros(population_size, d);

    for j = 1:d

        % Divide the normalized range [0,1]
        % into equal intervals.
        edges = linspace(0,1,population_size+1);

        % Generate one random sample inside
        % each interval.
        u = rand(1,population_size);
        pts = edges(1:population_size) + u .* diff(edges);

        % Randomly shuffle samples to avoid
        % correlations between parameters.
        pts = pts(randperm(population_size));

        % Scale samples from [0,1] to the
        % parameter's actual range.
        population(:,j) = ...
            min_val(j) + pts' * (max_val(j) - min_val(j));
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