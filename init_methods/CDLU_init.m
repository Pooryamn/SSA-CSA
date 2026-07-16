function [population] = CDLU_init(population_size, bound_dict, map)
% CDLU_INIT Create an initial population using Chaotic Distributed
% Linear Uniform (CDLU) initialization.
%
% This function generates a population using a chaotic version of the
% Distributed Linear Uniform (DLU) initialization method proposed in:
%
%   https://doi.org/10.1109/ACCESS.2021.3073480
%
% The method first creates uniformly distributed values across the range
% of each parameter. A chaotic map is then used to shuffle these values,
% increasing population diversity while preserving the uniform coverage
% of the search space.
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
%   map
%       Name of the chaotic map used for shuffling.
%
%       Supported options:
%           "Tent"
%           "Sine"
%           "Chebyshev"
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
%   population = CDLU_init(100, bounds, "Tent");
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

    %% Generate chaotic sequence
    % The chaotic sequence is used to create
    % parameter-specific shuffle indices.

    if (strcmp(map,"Tent") == 1)

        C_map = Tent_Map(population_size * size(param_values,1));

    elseif (strcmp(map,"Sine") == 1)

        C_map = Sin_Map(population_size * size(param_values,1));

    elseif (strcmp(map,"Chebyshev") == 1)

        C_map = Chebyshev_Map(population_size * size(param_values,1));

        % Shift values from [-1,1] to [0,1]
        C_map = (C_map + 1) / 2;

    else

        error("Chaos map was not identified. Available options: 'Tent', 'Sine', 'Chebyshev'");
    end

    %% Convert chaotic sequence to shuffle indices
    C_map = reshape(C_map, population_size, size(param_values,1));

    Chaotic_indexes = ceil(C_map * population_size);

    %% Generate uniformly distributed population
    % Create evenly spaced values between the minimum
    % and maximum bounds for each parameter.
    K = 1;

    for i = 1:size(param_values,1)

        min_val = param_values{i,1}(1);
        max_val = param_values{i,1}(2);

        % Calculate spacing between adjacent values
        step = (max_val - min_val) / (population_size - 1);

        % Generate uniformly distributed values
        population(:,K) = min_val:step:max_val;

        K = K + 1;
    end

    %% Shuffle each parameter using chaotic indices
    % This step improves population diversity while
    % keeping the uniform distribution of values.
    for i = 1:size(param_values,1)

        population(:,i) = population(Chaotic_indexes(:,i), i);

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