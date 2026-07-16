function score = Laplacian_Variance(img, Sigma, Alpha)
% LAPLACIAN_VARIANCE Calculate image sharpness using Laplacian variance.
%
% This function measures image sharpness by applying a local Laplacian
% filter and computing the variance of the filtered image. Images with
% stronger edges and finer details generally produce larger variance
% values and therefore higher sharpness scores.
%
% Inputs:
%   img
%       Input image or image stack.
%
%   Sigma (optional)
%       Edge amplitude parameter used by the local Laplacian filter.
%
%       Default value:
%           0.7
%
%   Alpha (optional)
%       Detail enhancement parameter used by the local Laplacian filter.
%
%       Default value:
%           0.3
%
% Outputs:
%   score
%       Average Laplacian variance score.
%
%       Higher values indicate sharper images with more high-frequency
%       content and stronger edge information.
%
% Method:
%   1. Apply a local Laplacian filter to each image slice.
%   2. Compute the variance of the filtered image.
%   3. Repeat for all slices.
%   4. Return the average variance across all slices.
%
% Example:
%   score = Laplacian_Variance(img);
%
%   score = Laplacian_Variance(img, 0.7, 0.3);
%
% Notes:
%   - This metric is commonly used as a focus and sharpness measure.
%   - Higher scores generally indicate better edge preservation.
%   - The metric does not explicitly measure image noise and is often
%     combined with noise-related metrics such as SNR.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Set default filter parameters

    if nargin < 2

        Sigma = 0.7;
        Alpha = 0.3;

    elseif nargin < 3

        Alpha = 0.3;

    end

    %% Calculate variance for each image slice
    for i = 1:size(img,3)
        % Apply local Laplacian filter
        L = locallapfilt(img(:,:,i), Sigma, Alpha);

        % Measure variance of filtered image
        var_L(i) = var(L(:));
    end

    %% Average variance across all slices

    score = mean(var_L(:));

end

