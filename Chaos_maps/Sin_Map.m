function C_map = Sin_Map(Num)
% SIN_MAP Generate a chaotic sequence using the Sine map.
%
% This function generates a sequence of chaotic values in the range
% [0, 1] using the Sine map. Chaotic sequences are commonly used in
% optimization algorithms to improve population diversity and explore
% the search space more effectively.
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
%   The Sine map is defined as:
%
%       x(n+1) = sin(pi * x(n))
%
%   where:
%       x(1) = 0.7
%
% Example:
%   C_map = Sin_Map(100);
%
% Coded by::
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Initialize map

    % Initial value (seed)
    x(1) = 0.7;

    %% Generate chaotic sequence
    for i = 2:Num

        x(i) = sin(pi * x(i-1));

    end

    %% Return generated sequence
    C_map = x;
end