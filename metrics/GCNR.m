function score = GCNR(Region, BackGround, numBins)
% GCNR Calculate the Generalized Contrast-to-Noise Ratio (GCNR).
%
% GCNR measures the separability between two intensity distributions,
% typically representing a foreground region and a background region.
% Unlike traditional contrast metrics, GCNR is based on the histogram
% overlap between the two regions and produces values in the range [0, 1].
%
% Inputs:
%   Region
%       Foreground region of interest (ROI).
%       Can be a 2D image, 3D volume, or pixel array.
%
%   BackGround
%       Background region used for comparison.
%       Can be a 2D image, 3D volume, or pixel array.
%
%   numBins (optional)
%       Number of histogram bins used to estimate the intensity
%       distributions.
%
%       Default value:
%           256
%
% Outputs:
%   score
%       Generalized Contrast-to-Noise Ratio (GCNR).
%
%       Range:
%           0 ≤ score ≤ 1
%
%       Interpretation:
%           score ≈ 0  : Complete overlap between distributions
%                         (poor contrast)
%
%           score ≈ 1  : No overlap between distributions
%                         (excellent contrast)
%
% Method:
%   1. Convert both regions into vectors.
%   2. Compute normalized histograms using a common set of bins.
%   3. Calculate the overlap between the two distributions.
%   4. Compute GCNR as:
%
%          GCNR = 1 - Overlap
%
%      where:
%
%          Overlap = Σ min(pRegion, pBackGround)
%
% Example:
%   score = GCNR(ROI, Background);
%
%   score = GCNR(ROI, Background, 128);
%
% Notes:
%   - GCNR is independent of intensity scaling and is often preferred
%     over conventional CNR metrics when comparing reconstructed images.
%   - Higher GCNR values indicate better separation between foreground
%     and background regions.
%   - GCNR is widely used in medical imaging and image reconstruction
%     quality assessment.
%
% Reference:
%   Rodriguez-Molares et al.,
%   "The Generalized Contrast-to-Noise Ratio: A Formal Definition
%   for Lesion Detectability," IEEE Transactions on Ultrasonics,
%   Ferroelectrics, and Frequency Control, 2020.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Set default number of histogram bins

    if nargin < 3

        numBins = 256;

    end

    %% Convert inputs to vectors

    Region = double(Region(:));
    BackGround = double(BackGround(:));

    %% Determine common histogram range

    allPixels = [Region; BackGround];

    minVal = min(allPixels);
    maxVal = max(allPixels);

    %% Compute normalized histograms

    edges = linspace(minVal, maxVal, numBins + 1);

    pRegion = histcounts(Region, edges, ...
        'Normalization', 'probability');

    pBackGround = histcounts(BackGround, edges, ...
        'Normalization', 'probability');

    %% Calculate histogram overlap

    overlap = sum(min(pRegion, pBackGround));

    %% Compute GCNR score

    score = 1 - overlap;

end
