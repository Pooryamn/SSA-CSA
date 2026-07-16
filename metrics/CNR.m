function score = CNR(Region, BackGround)
% CNR Calculate the Contrast-to-Noise Ratio (CNR).
%
% This function measures the contrast between a foreground region and a
% background region while taking image noise into account. Higher CNR
% values indicate that the object is more distinguishable from the
% background.
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
% Outputs:
%   score
%       Contrast-to-Noise Ratio (CNR).
%
%       Higher values indicate better contrast and object visibility.
%
% Method:
%   The CNR is calculated as:
%
%                     |μRegion - μBackground|
%       CNR = ----------------------------------------
%              sqrt(σ²Region + σ²Background)
%
%   where:
%
%       μRegion      = mean intensity of the foreground region
%       μBackground  = mean intensity of the background region
%       σ²Region     = variance of the foreground region
%       σ²Background = variance of the background region
%
% Example:
%   score = CNR(ROI, Background);
%
% Notes:
%   - Higher CNR values indicate improved object detectability.
%   - A CNR value close to zero suggests poor contrast between the
%     foreground and background regions.
%   - This metric is commonly used in medical imaging, image
%     reconstruction, and image quality assessment.
%   - The function supports both 2D and 3D image data.
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Calculate region statistics

    [var_obj, mu_obj] = var(Region(:));

    [var_BG, mu_BG] = var(BackGround(:));

    %% Calculate Contrast-to-Noise Ratio

    score = abs(mu_obj - mu_BG) / ...
            sqrt(var_obj + var_BG);

end