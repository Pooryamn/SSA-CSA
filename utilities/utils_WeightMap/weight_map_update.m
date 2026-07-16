function weight_map = weight_map_update(weight_map, bound_dict, ...
                                        individuals, Update_rate)
% WEIGHT_MAP_UPDATE Update parameter sampling weights based on
% high-performing individuals.
%
% This function increases the sampling weights around parameter values
% found in selected individuals. The updated weights can then be used by
% weighted initialization methods to focus the search on promising regions
% of the parameter space.
%
% Inputs:
%   weight_map
%       Cell array containing the current weights for each parameter.
%
%   bound_dict
%       Dictionary (containers.Map) containing parameter definitions.
%       Each key is a parameter name and each value is a vector:
%
%           [min_value, max_value, step_size]
%
%   individuals
%       Matrix containing selected individuals.
%
%       Size:
%           number_of_individuals × number_of_parameters
%
%       Each row represents a candidate solution whose parameter values
%       will influence the weight update.
%
%   Update_rate
%       Amount added to the weights of parameter values located near the
%       selected individuals.
%
% Outputs:
%   weight_map
%       Updated weight map.
%
% Method:
%   1. Generate the value pool for each parameter.
%   2. For every parameter value in the selected individuals,
%      define a neighborhood around that value.
%   3. Identify parameter values located within the neighborhood.
%   4. Increase their weights by the specified update rate.
%
% Notes:
%   - The neighborhood range is defined as ±10% of the selected value.
%   - Regions containing good solutions gradually receive larger weights.
%   - This mechanism encourages future populations to sample more often
%     from promising areas of the search space.
%
% Example:
%   weight_map = weight_map_update( ...
%                   weight_map, ...
%                   Bound_dict, ...
%                   elite_individuals, ...
%                   0.1);
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Generate parameter value pools

    param_values = values(bound_dict);

    paramPool = cell(size(param_values,1), 1);

    K = 1;
    for i = 1:size(param_values,1)

        min_val = param_values{i,1}(1);
        max_val = param_values{i,1}(2);
        step    = param_values{i,1}(3);

        % Generate all valid values for this parameter
        available_values = min_val:step:max_val;

        paramPool{K} = available_values;
        K = K + 1;
    end

    %% Update weights using selected individuals

    for i = 1:size(individuals,1)

        for j = 1:size(individuals,2)

            value = individuals(i,j);

            % Define a local neighborhood around the value
            lower_range = value - (0.1 * value);
            upper_range = value + (0.1 * value);

            % Find parameter values inside the neighborhood
            highlighted_indexes = find( ...
                paramPool{j} >= lower_range & ...
                paramPool{j} <= upper_range);

            % Increase the corresponding weights
            weight_map{j}(highlighted_indexes) = ...
                weight_map{j}(highlighted_indexes) + Update_rate;

        end

    end

end