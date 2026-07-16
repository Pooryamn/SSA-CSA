function indexes = find_pareto_set(data)
% FIND_PARETO_SET Identify Pareto-optimal solutions from a set of
% multi-objective results.
%
% This function extracts the Pareto set from a collection of candidate
% solutions. A solution is considered Pareto-optimal if no other solution
% performs better in all objectives simultaneously.
%
% The function assumes that all objectives are maximization objectives.
%
% Inputs:
%   data
%       Matrix of size:
%
%           N × M
%
%       where:
%
%           Columns 1:(M-1) contain objective values.
%           Column M contains the corresponding solution index.
%
% Outputs:
%   indexes
%       Row vector containing the indexes of all Pareto-optimal
%       individuals.
%
% Method:
%   A solution A is said to dominate solution B if:
%
%       1. A is at least as good as B in every objective.
%       2. A is strictly better than B in at least one objective.
%
% Any solution that is dominated by another solution is removed from
% the Pareto set.
%
% Example:
%   data = [
%       0.80  0.90  1;
%       0.85  0.85  2;
%       0.70  0.95  3
%   ];
%
%   indexes = find_pareto_set(data);
%
% Notes:
%   - All objectives are assumed to be maximized.
%   - The function returns only the indexes of Pareto-optimal solutions.
%   - The returned solutions form the first Pareto front.
%   - Commonly used in multi-objective optimization algorithms for
%     selecting elite individuals.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Extract objective values

    [N, M] = size(data);

    objectives = data(:,1:M-1);

    %% Assume all solutions are Pareto-optimal initially

    isPareto = true(N,1);

    %% Check dominance relationships

    for i = 1:N

        for j = 1:N

            % Solution j dominates solution i if:
            %   - it is at least as good in all objectives
            %   - and strictly better in at least one objective
            if all(objectives(j,:) >= objectives(i,:)) && ...
               any(objectives(j,:) > objectives(i,:))

                isPareto(i) = false;
                break;

            end

        end

    end

    %% Return Pareto-optimal solution indexes

    indexes = data(isPareto,end)';

end