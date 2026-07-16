function Corrected_individual = correct_individual(individial, Bound_dict, varargin)
% CORRECT_INDIVIDUAL Repair an individual that violates parameter bounds.
%
% This function checks whether the parameter values of an individual lie
% within the allowed search ranges. Any parameter that falls outside its
% valid bounds is replaced with a randomly selected valid value.
%
% Optionally, weighted sampling can be used so that replacement values are
% drawn according to a predefined probability distribution.
%
% Inputs:
%   individial
%       Row vector representing a candidate solution.
%
%       Size:
%           1 × number_of_parameters
%
%   Bound_dict
%       Dictionary (containers.Map) containing parameter definitions.
%       Each key is a parameter name and each value is a vector:
%
%           [min_value, max_value, step_size]
%
%   varargin (optional)
%       weight_map
%
%       Cell array containing sampling weights for each parameter.
%       If provided, invalid values are repaired using weighted sampling
%       instead of uniform random sampling.
%
% Outputs:
%   Corrected_individual
%       Corrected version of the input individual.
%
% Method:
%   For each parameter:
%
%       1. Check whether the value is within its bounds.
%       2. If valid, keep the original value.
%       3. If invalid:
%            - Generate all allowable parameter values.
%            - Select a replacement value.
%            - Use weighted sampling if a weight map is provided.
%            - Otherwise use uniform random sampling.
%
% Notes:
%   - Only out-of-bound parameters are modified.
%   - Valid parameters remain unchanged.
%   - This function helps maintain feasible solutions during optimization.
%   - Weighted correction can guide repaired solutions toward promising
%     regions of the search space.
%
% Example:
%   repaired = correct_individual(solution, Bound_dict);
%
%   repaired = correct_individual( ...
%                   solution, ...
%                   Bound_dict, ...
%                   weight_map);
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Check whether weighted sampling is enabled

    weighted_sampling = false;

    if ~isempty(varargin)

        weight_map = varargin{1};
        weighted_sampling = true;

    end

    %% Get parameter bounds

    Bounding_values = values(Bound_dict);

    %% Initialize corrected individual

    Corrected_individual = individial;

    %% Check all parameter values

    for i = 1:size(individial,2)

        % Check if parameter value violates its bounds
        if individial(i) > Bounding_values{i}(2) || ...
           individial(i) < Bounding_values{i}(1)

            % Generate all valid parameter values
            available_values = ...
                Bounding_values{i}(1): ...
                Bounding_values{i}(3): ...
                Bounding_values{i}(2);

            % Replace invalid value
            if weighted_sampling

                Corrected_individual(i) = ...
                    weighted_Sampling( ...
                        available_values, ...
                        weight_map{i}, ...
                        1);

            else

                Corrected_individual(i) = ...
                    available_values(randi(length(available_values)));

            end

        end

    end

end
