function selected = weighted_Sampling(A, W, k)
% WEIGHTED_SAMPLING Draw random samples using weighted probabilities.
%
% This function randomly selects values from an input array according to
% user-defined weights. Values with larger weights have a higher chance
% of being selected.
%
% This function is a lightweight implementation of MATLAB's
% "randsample" function and does not require the Statistics and Machine
% Learning Toolbox.
%
% Inputs:
%   A
%       Array of candidate values.
%
%   W
%       Weight vector associated with the values in A.
%
%       Requirements:
%           - Same length as A
%           - Non-negative values
%           - Larger weights correspond to higher selection probability
%
%   k
%       Number of samples to draw.
%
% Outputs:
%   selected
%       Row vector containing the selected samples.
%
% Method:
%   1. Normalize the weights to create a probability distribution.
%   2. Compute the cumulative distribution function (CDF).
%   3. Generate a random number in the range [0,1].
%   4. Select the first value whose cumulative probability exceeds the
%      random number.
%   5. Repeat until k samples are generated.
%
% Example:
%   A = [10 20 30 40];
%   W = [0.1 0.2 0.5 0.2];
%
%   sample = weighted_Sampling(A, W, 1);
%
%   samples = weighted_Sampling(A, W, 100);
%
% Notes:
%   - Sampling is performed with replacement.
%   - A value may be selected multiple times.
%   - The probability of selecting a value is proportional to its weight.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Normalize weights into probabilities
    W = W / sum(W);

    %% Preallocate output array
    selected = zeros(1, k);

    %% Compute cumulative probability distribution
    edges = [0 cumsum(W)];

    %% Draw samples

    for i = 1:k

        % Generate random number in [0,1]
        r = rand;

        % Find corresponding probability interval
        idx = find(r <= edges(2:end), 1);

        % Select value
        selected(i) = A(idx);

    end

end