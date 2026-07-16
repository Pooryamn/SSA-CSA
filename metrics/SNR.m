function score = SNR(img, dim)
% SNR Calculate the Signal-to-Noise Ratio (SNR) of an image.
%
% This function estimates the Signal-to-Noise Ratio (SNR) by computing
% the ratio of the mean intensity to the standard deviation of the
% intensity values. The calculation can be performed along a specified
% dimension and is averaged over all resulting elements.
%
% Inputs:
%   img
%       Input image or image stack.
%
%   dim (optional)
%       Dimension along which the SNR is calculated.
%
%       Default:
%           dim = 3
%
%       For 2D images, the function automatically uses:
%           dim = 1
%
% Outputs:
%   score
%       Estimated Signal-to-Noise Ratio.
%
%       Higher values indicate lower noise levels and better image quality.
%
% Method:
%   The SNR is calculated as:
%
%       SNR = mean(img) / std(img)
%
%   where:
%
%       mean(img) = average signal intensity
%       std(img)  = signal variation (noise estimate)
%
% The final score is the average SNR across all computed elements.
%
% Example:
%   score = SNR(img);
%
%   score = SNR(img, 3);
%
% Notes:
%   - The input image is converted to double precision before computation.
%   - Zero standard deviations are ignored to avoid division-by-zero.
%   - If the computed SNR is zero or negative, a small positive value
%     (1e-2) is returned to maintain numerical stability in optimization
%     algorithms.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Set default dimension

    if nargin < 2

        dim = 3;

    end

    %% Handle 2D images

    if ndims(img) < 3

        dim = 1;

    end

    %% Convert image to double precision
    img = double(img);

    %% Compute mean intensity
    m = mean(img, dim);

    %% Compute standard deviation
    sd = std(img, 0, dim);

    %% Calculate SNR values
    snr_arr = zeros(size(sd));
    snr_arr(sd ~= 0) = m(sd ~= 0) ./ sd(sd ~= 0);

    %% Average SNR across all elements
    score = mean(snr_arr(:));

    %% Ensure positive output value
    % This avoids numerical issues in objective functions
    % that use the inverse of the SNR score.
    if score <= 0.0
        score = 1e-2;
    end

end

