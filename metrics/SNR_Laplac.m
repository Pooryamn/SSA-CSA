function [score, SNR_score, lapace_score] = SNR_Laplac(img, Alpha, Beta)
% SNR_LAPLAC Calculate a combined image-quality score using
% Signal-to-Noise Ratio (SNR) and Laplacian variance.
%
% This function combines two image-quality metrics:
%
%   1. Signal-to-Noise Ratio (SNR)
%      Measures the noise level of the image.
%
%   2. Laplacian Variance
%      Measures image sharpness based on the amount of high-frequency
%      image content. Higher values generally indicate sharper images.
%
% The final score is calculated as a weighted sum of the inverse SNR and
% inverse Laplacian variance values. Lower scores correspond to better
% image quality because higher SNR and higher sharpness reduce the
% objective value.
%
% Inputs:
%   img
%       Input image or image stack.
%
%   Alpha (optional)
%       Weight assigned to the SNR term.
%       Default value: 1.0
%
%   Beta (optional)
%       Weight assigned to the Laplacian variance term.
%       Default value: 1.0
%
% Outputs:
%   score
%       Combined image-quality score.
%
%   SNR_score
%       Signal-to-Noise Ratio value.
%
%   lapace_score
%       Laplacian variance value.
%
% Formula:
%
%       score = Alpha / SNR + Beta / LaplacianVariance
%
% Example:
%   score = SNR_Laplac(img);
%
%   [score,snr,lap] = SNR_Laplac(img, 0.8, 0.2);
%
% Notes:
%   Increasing Alpha places more emphasis on noise reduction.
%
%   Increasing Beta places more emphasis on image sharpness.
%
%   Lower scores indicate better overall image quality.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Set default weights

    if nargin < 2

        Alpha = 1.0;
        Beta = 1.0;

    elseif nargin < 3

        Beta = 1.0;

    end

    %% Calculate image-quality metrics

    % Signal-to-noise ratio
    SNR_score = SNR(img);

    % Image sharpness based on Laplacian variance
    lapace_score = Laplacian_Variance(img, 0.7, 0.1);

    %% Calculate combined objective value
    % Lower values correspond to better image quality.
    score = (Alpha * (1 / SNR_score)) + ...
            (Beta  * (1 / lapace_score));

end
