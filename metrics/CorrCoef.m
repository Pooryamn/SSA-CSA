function score = CorrCoef(image, reference)
% CORRCOEF Compute the Pearson correlation coefficient between two images.
%
% This function measures the strength of the linear relationship between
% two images using the Pearson correlation coefficient. The resulting
% value indicates how similar the intensity patterns of the two images are.
%
% Inputs:
%   image
%       Input image to be evaluated.
%
%   reference
%       Reference image used for comparison.
%
% Outputs:
%   score
%       Pearson correlation coefficient.
%
%       Range:
%           -1 <= score <= 1
%
%       Interpretation:
%           score = 1   : Perfect positive correlation
%           score = 0   : No linear relationship
%           score = -1  : Perfect negative correlation
%
% Method:
%   1. Verify that both images have identical dimensions.
%   2. Convert images into vectors.
%   3. Subtract the mean intensity from each image.
%   4. Compute the Pearson correlation coefficient:
%
%          score =
%              Σ[(I - mean(I)) .* (R - mean(R))]
%              ----------------------------------
%              sqrt(Σ(I - mean(I))² Σ(R - mean(R))²)
%
%      where:
%          I = input image
%          R = reference image
%
% Example:
%   score = CorrCoef(reconstruction, reference);
%
% Notes:
%   - Higher values indicate greater similarity to the reference image.
%   - A value close to 1 indicates that both images have very similar
%     intensity distributions and structures.
%   - This metric is commonly used for image quality assessment when a
%     ground-truth or reference image is available.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Verify image dimensions

    if ~isequal(size(image), size(reference))
        error('Input arrays must have the same size');
    end

    %% Convert images into vectors

    image = image(:);
    reference = reference(:);

    %% Remove mean intensity

    image_mean = mean(image);
    reference_mean = mean(reference);

    image_centered = image - image_mean;
    reference_centered = reference - reference_mean;

    %% Calculate Pearson correlation coefficient

    numerator = sum(image_centered .* reference_centered);

    denominator = sqrt( ...
        sum(image_centered.^2) * ...
        sum(reference_centered.^2));

    %% Avoid division by zero

    if denominator == 0

        score = NaN;

    else

        score = numerator / denominator;

    end

end