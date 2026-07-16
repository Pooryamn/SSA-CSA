function [score, SNR_score, Freq_score] = SNR_FREQ(img, Alpha, Beta, Cutoff_ratio)
% SNR_FREQ Calculate a combined image-quality score using
% Signal-to-Noise Ratio (SNR) and frequency-domain information.
%
% This function combines a noise metric and a frequency-content metric
% into a single objective value. The frequency-energy term measures the
% amount of high-frequency information in the image, which is often
% related to edge preservation and image detail.
%
% Inputs:
%   img
%       Input image or image stack.
%
%   Alpha (optional)
%       Weight assigned to the SNR term.
%       Default value: 7.0
%
%   Beta (optional)
%       Weight assigned to the frequency-energy term.
%       Default value: 4.5
%
%   Cutoff_ratio (optional)
%       Cutoff frequency ratio used by the Frequency_energy
%       function to separate frequency components.
%       Default value: 0.01
%
% Outputs:
%   score
%       Combined image-quality score.
%
%   SNR_score
%       Signal-to-Noise Ratio value.
%
%   Freq_score
%       Frequency-energy score.
%
% Formula:
%
%       score = Alpha / SNR + Beta * (1 - FrequencyEnergy)
%
% where:
%
%   - Higher SNR values indicate lower image noise.
%   - Higher frequency-energy values indicate better preservation
%     of image details and edges.
%
% Lower scores correspond to better image quality.
%
% Example:
%   score = SNR_FREQ(img);
%
%   [score,snr,freq] = SNR_FREQ(img, 7.0, 4.5, 0.01);
%
% Notes:
%   Increasing Alpha places more importance on noise reduction.
%
%   Increasing Beta places more importance on preserving
%   image details and high-frequency information.
%
%   This metric is useful for reconstruction and optimization
%   tasks where both noise suppression and detail preservation
%   are desired.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Set default parameters

    if nargin < 2

        Alpha = 7.0;
        Beta = 4.5;
        Cutoff_ratio = 0.01;

    elseif nargin < 3

        Beta = 4.5;
        Cutoff_ratio = 0.01;

    elseif nargin < 4

        Cutoff_ratio = 0.01;

    end

    %% Calculate image-quality metrics

    % Signal-to-noise ratio
    SNR_score = SNR(img);

    % Frequency-domain energy measure
    Freq_score = Frequency_energy(img, Cutoff_ratio);

    %% Calculate combined objective value
    % Lower values correspond to better image quality.
    score = (Alpha * (1 / SNR_score)) + ...
            (Beta * (1 - Freq_score));

end