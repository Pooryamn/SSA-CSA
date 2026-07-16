function [population] = CLHS_init(population_size, bound_dict, map)
% CLHS_INIT Create an initial population using Chaotic Latin Hypercube Sampling.
%
% This function generates a population of candidate solutions using the
% Latin Hypercube Sampling (LHS) method enhanced with a chaotic map.
% Instead of using a random permutation, the sample arrangement is guided
% by chaotic sequences, which can improve the diversity and distribution
% of the initial population.
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
%       Name of the chaotic map used to generate the permutation.
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
%   population = CLHS_init(100, bounds, "Tent");
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
    % The chaotic sequence is used to create a deterministic
    % permutation for the LHS samples.

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

    %% Convert chaotic sequence to sampling indices
    % Reshape the sequence so that each column corresponds
    % to one optimization parameter.
    C_map = reshape(C_map, population_size, size(param_values,1));

    Chaotic_indexes = ceil(C_map * population_size);

    %% Extract parameter ranges
    min_val = zeros(1,size(param_values,1));
    max_val = zeros(1,size(param_values,1));

    K = 1;
    for i = 1:size(param_values,1)

        min_val(K) = param_values{i,1}(1);
        max_val(K) = param_values{i,1}(2);

        K = K + 1;
    end

    %% Generate Chaotic Latin Hypercube population
    population = zeros(population_size, size(param_values,1));

    for j = 1:size(param_values,1)

        % Divide the normalized range [0,1]
        % into equal intervals.
        edges = linspace(0,1,population_size+1);

        % Generate one random sample inside
        % each interval.
        u = rand(1,population_size);
        pts = edges(1:population_size) + u .* diff(edges);

        % Rearrange samples using chaotic indices
        % instead of a random permutation.
        pts = pts(Chaotic_indexes(:,j));

        % Scale samples from [0,1] to the
        % actual parameter range.
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