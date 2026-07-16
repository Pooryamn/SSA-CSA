function Weight_map = weight_map_init(bound_dict)
% WEIGHT_MAP_INIT Create an initial weight map for weighted sampling.
%
% This function initializes the weight map used by weighted population
% initialization methods. Each valid parameter value is assigned the same
% initial weight, resulting in a uniform probability distribution across
% the search space.
%
% Inputs:
%   bound_dict
%       Dictionary (containers.Map) containing parameter definitions.
%       Each key is a parameter name and each value is a vector:
%
%           [min_value, max_value, step_size]
%
% Outputs:
%   Weight_map
%       Cell array containing the weight vector for each parameter.
%
%       Each weight vector has the same length as the corresponding
%       parameter value pool and is initialized with ones.
%
% Method:
%   1. Generate all valid values for each parameter using the specified
%      minimum value, maximum value, and step size.
%   2. Create a weight vector of equal weights for all values.
%   3. Store the weight vectors in a cell array.
%
% Notes:
%   - All parameter values start with equal probability.
%   - The weight map can later be updated using
%     WEIGHT_MAP_UPDATE to emphasize promising regions of the
%     search space.
%   - This function provides the initial state for adaptive
%     weighted-sampling strategies.
%
% Example:
%   Weight_map = weight_map_init(Bound_dict);
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Read parameter definitions

    param_values = values(bound_dict);

    %% Initialize weight map

    Weight_map = cell(size(param_values,1), 1);

    K = 1;
    for i = 1:size(param_values,1)

        min_val = param_values{i,1}(1);
        max_val = param_values{i,1}(2);
        step    = param_values{i,1}(3);

        % Generate all valid values for this parameter
        available_values = min_val:step:max_val;

        % Assign equal initial weights
        Weight_map{K} = ones(1, length(available_values));

        K = K + 1;
    end

end