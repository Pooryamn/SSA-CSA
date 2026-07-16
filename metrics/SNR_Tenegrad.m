function score = SNR_Tenegrad(img, Alpha, Beta, Tenegrad_method)
% SNR_TENEGRAD Calculate a combined image-quality score using
% Signal-to-Noise Ratio (SNR) and Tenengrad sharpness.
%
% This function combines two image-quality measures:
%
%   1. Signal-to-Noise Ratio (SNR)
%      Evaluates image noise level.
%
%   2. Tenengrad
%      Evaluates image sharpness based on gradient strength.
%
% The final score is computed as a weighted sum of the inverse SNR
% and inverse Tenengrad values. Lower scores indicate better image
% quality because higher SNR and higher sharpness reduce the fitness
% value.
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
%       Weight assigned to the Tenengrad term.
%       Default value: 1.0
%
%   Tenegrad_method (optional)
%       Calculation method passed to the Tenengrad function.
%
%       Examples:
%           "avg"
%           "sum"
%
%       Default value: "sum"
%
% Outputs:
%   score
%       Combined image-quality score.
%       Lower values indicate better image quality.
%
% Formula:
%
%       score = Alpha / SNR + Beta / Tenengrad
%
% Example:
%   score = SNR_Tenegrad(img);
%
%   score = SNR_Tenegrad(img, 0.7, 0.3, "avg");
%
% Notes:
%   Increasing Alpha gives more importance to noise reduction.
%
%   Increasing Beta gives more importance to image sharpness.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Set default parameters

    if nargin < 2

        Alpha = 1.0;
        Beta = 1.0;
        Tenegrad_method = 'sum';

    elseif nargin < 3

        Beta = 1.0;
        Tenegrad_method = 'sum';

    elseif nargin < 4

        Tenegrad_method = 'sum';

    end

    %% Calculate image-quality metrics

    % Signal-to-noise ratio
    SNR_score = SNR(img);

    % Image sharpness
    Tenengrad_score = Tenengrad(img, Tenegrad_method);

    %% Calculate combined objective value
    % Lower values correspond to better image quality.
    score = (Alpha * (1 / SNR_score)) + ...
            (Beta  * (1 / Tenengrad_score));

end