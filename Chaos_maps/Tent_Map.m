function C_map = Tent_Map(Num)
% TENT_MAP Generate a chaotic sequence using the Tent map.
%
% This function generates a sequence of chaotic values in the range
% [0, 1] using the Tent map. Chaotic sequences are commonly used in
% optimization algorithms to improve population diversity and exploration
% of the search space.
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
%   The Tent map is defined as:
%
%       x(n+1) = mu * x(n)           , if x(n) < 0.5
%       x(n+1) = mu * (1 - x(n))    , otherwise
%
%   where:
%       mu = 1.5
%
% Example:
%   C_map = Tent_Map(100);
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Initialize map parameters

    % Initial value (seed)
    x(1) = 0.7;

    % Control parameter
    mu = 1.5;

    %% Generate chaotic sequence
    for i = 2:Num

        if x(i-1) < 0.5

            x(i) = mu * x(i-1);

        else

            x(i) = mu * (1 - x(i-1));

        end
    end

    %% Return generated sequence
    C_map = x;
end