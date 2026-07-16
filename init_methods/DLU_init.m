function [population] = DLU_init(population_size, bound_dict)
% DLU_INIT Create an initial population using the DLU method.
%
% This function generates an initial population based on the Distributed
% Linear Uniform (DLU) initialization strategy proposed in:
%
%   https://doi.org/10.1109/ACCESS.2021.3073480
%
% Instead of randomly sampling parameter values, the method distributes
% individuals uniformly across the search space. For each parameter,
% values are evenly spaced between the minimum and maximum bounds.
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
%   population = DLU_init(100, bounds);
%
% Reference:
%   Li, Qian et al.,
%   "Improved Initialization Method for Metaheuristic Algorithms: A Novel Search Space View"
%   IEEE Access, 2021.
%
% Coded by::
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Read and validate input data
    param_names = keys(bound_dict);
    param_values = values(bound_dict);

    check_inputs(param_names, param_values);

    %% Generate uniformly distributed population
    % For each parameter, create evenly spaced values
    % between the minimum and maximum bounds.
    % The spacing is determined by the population size.

    K = 1;
    for i = 1:size(param_values,1)

        min_val = param_values{i,1}(1);
        max_val = param_values{i,1}(2);

        % Calculate the interval between adjacent samples
        step = (max_val - min_val) / (population_size - 1);

        % Create evenly distributed values across the range
        population(:,K) = min_val:step:max_val;

        K = K + 1;
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