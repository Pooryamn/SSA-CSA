function C_map = Chebyshev_Map(Num)
% CHEBYSHEV_MAP Generate a chaotic sequence using the Chebyshev map.
%
% This function generates a sequence of chaotic values using the
% Chebyshev map. The generated sequence lies within the range [-1, 1]
% and can be used in optimization algorithms for population
% initialization, randomization, and search-space exploration.
%
% Inputs:
%   Num
%       Number of chaotic values to generate.
%
% Outputs:
%   C_map
%       Row vector containing the generated chaotic sequence.
%
% Method:
%   The Chebyshev map is defined as:
%
%       x(n+1) = cos(K * acos(x(n)))
%
%   where:
%       K = 3
%       x(1) = 0.7
%
% Example:
%   C_map = Chebyshev_Map(100);
%
% Notes:
%   The generated values are in the range [-1, 1]. If values in the
%   range [0, 1] are required, they can be transformed using:
%
%       C_map = (C_map + 1) / 2;
%
% Coded by::
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Initialize map parameters

    % Chebyshev polynomial degree
    K = 3;

    % Initial value (seed)
    x(1) = 0.7;

    %% Generate chaotic sequence
    for i = 2:Num

        x(i) = cos(K * acos(x(i-1)));

    end

    %% Return generated sequence
    C_map = x;

end