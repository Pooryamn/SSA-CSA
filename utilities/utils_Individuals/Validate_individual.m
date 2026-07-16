function flag = Validate_individual(individial, Bound_dict)
% VALIDATE_INDIVIDUAL Check whether an individual satisfies all
% parameter bounds.
%
% This function verifies that every parameter value in an individual
% lies within its corresponding search range. It is commonly used during
% optimization to ensure that candidate solutions remain inside the
% defined search space.
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
% Outputs:
%   flag
%       Logical value indicating whether the individual is valid.
%
%       true  : All parameter values are within their bounds.
%       false : At least one parameter violates its bounds.
%
% Method:
%   For each parameter:
%
%       min_value <= parameter_value <= max_value
%
%   If any parameter falls outside its allowed range, the function
%   immediately returns false.
%
% Example:
%   if Validate_individual(solution, Bound_dict)
%       disp("Valid solution");
%   end
%
% Notes:
%   - Only the lower and upper bounds are checked.
%   - Step-size constraints are not validated.
%   - Useful after position updates, mutation, or local search
%     operations in optimization algorithms.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Assume the individual is valid

    flag = true;

    %% Get parameter bounds

    Bounding_values = values(Bound_dict);

    %% Check each parameter

    for i = 1:size(individial,2)

        if individial(i) > Bounding_values{i}(2) || ...
           individial(i) < Bounding_values{i}(1)

            flag = false;
            break;

        end

    end

end
