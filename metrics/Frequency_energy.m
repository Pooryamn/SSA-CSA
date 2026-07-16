function Score = Frequency_energy(img, cutoff_ratio)
% FREQUENCY_ENERGY Measure the amount of high-frequency information
% in an image using Fourier-domain energy.
%
% This function computes the ratio of high-frequency energy to total
% spectral energy based on the image Fourier transform. Higher values
% indicate a larger amount of high-frequency content, which is often
% associated with sharper edges, finer details, and better texture
% preservation.
%
% Inputs:
%   img
%       Input image or image stack.
%
%   cutoff_ratio (optional)
%       Normalized cutoff frequency used to separate low-frequency and
%       high-frequency components.
%
%       Range:
%           0 < cutoff_ratio < 1
%
%       Default value:
%           0.5
%
% Outputs:
%   Score
%       Average high-frequency energy ratio.
%
%       Range:
%           0 ≤ Score ≤ 1
%
%       Interpretation:
%           Higher values indicate more high-frequency content.
%           Lower values indicate smoother images with less detail.
%
% Method:
%   1. Compute the 2D Fourier transform of each image slice.
%   2. Calculate the power spectrum.
%   3. Define a radial frequency cutoff.
%   4. Measure the energy above the cutoff frequency.
%   5. Compute:
%
%          High-Frequency Energy Ratio =
%               High-Frequency Energy / Total Energy
%
%   6. Average the ratio across all slices.
%
% Example:
%   score = Frequency_energy(img);
%
%   score = Frequency_energy(img, 0.1);
%
% Notes:
%   - This metric does not directly measure image quality.
%   - Very high values may indicate strong detail preservation, but can
%     also result from noise.
%   - For reconstruction optimization, this metric is often combined with
%     noise-related measures such as SNR.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Set default cutoff frequency ratio
    if nargin < 2

        cutoff_ratio = 0.01;

    end

    %% Convert image to double precision
    img = double(img);

    %% Calculate frequency-energy ratio for each slice

    for i = 1:size(img,3)

        % Compute 2D Fourier transform
        F = fft2(img(:,:,i));

        % Move zero frequency component to the center
        Fshift = fftshift(F);

        % Compute power spectrum
        P = abs(Fshift).^2;

        %% Create frequency grid

        [rows, cols] = size(img(:,:,i));

        [u, v] = meshgrid( ...
            (-floor(cols/2)):(ceil(cols/2)-1), ...
            (-floor(rows/2)):(ceil(rows/2)-1));

        % Radial frequency distance
        D = sqrt(u.^2 + v.^2);

        % Maximum frequency radius
        Dmax = max(D(:));

        %% Define cutoff frequency
        fc = cutoff_ratio * Dmax;

        %% Compute energy values
        total_energy = sum(P(:));
        high_energy = sum(P(D > fc));

        %% High-frequency energy ratio
        ratio(i) = high_energy / total_energy;

    end

    %% Average score across all slices

    Score = mean(ratio(:));

end