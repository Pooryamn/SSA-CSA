function score = Tenengrad(img, method, Threshold)
% TENENGRAD Calculate image sharpness using the Tenengrad focus measure.
%
% This function evaluates image sharpness based on gradient magnitude
% obtained from Sobel operators. Images with stronger edges and higher
% local intensity changes produce larger Tenengrad values and are
% considered sharper.
%
% Inputs:
%   img
%       Input image or image stack.
%
%   method (optional)
%       Method used to calculate the final score.
%
%       "avg"  - Mean gradient magnitude above the threshold (default)
%       Other  - Logarithm of the sum of gradient magnitudes
%
%   Threshold (optional)
%       Threshold applied to remove weak gradients when using
%       the "avg" method. Default value is 0.
%
% Outputs:
%   score
%       Sharpness score of the image.
%       Higher values indicate sharper images.
%
% Method:
%   1. Compute horizontal and vertical gradients using Sobel filters.
%   2. Calculate the gradient magnitude.
%   3. Apply thresholding if required.
%   4. Compute a sharpness score for each image slice.
%   5. Return the average score across all slices.
%
% Example:
%   score = Tenengrad(img);
%
%   score = Tenengrad(img, "avg", 10);
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Set default parameters

    if nargin < 2

        method = "avg";
        Threshold = 0;

    elseif nargin < 3

        Threshold = 0;

    end

    %% Convert image to double precision
    img = double(img);

    %% Calculate Tenengrad score for each slice
    for i = 1:size(img,3)

        % Horizontal Sobel gradient
        Gx = imfilter(img(:,:,i), fspecial('sobel')');

        % Vertical Sobel gradient
        Gy = imfilter(img(:,:,i), fspecial('sobel'));

        % Gradient magnitude squared
        gradMagSq = Gx.^2 + Gy.^2;

        % Gradient magnitude
        gradMag = sqrt(gradMagSq);

        if strcmp(method,"avg")

            % Ignore weak gradients below the threshold
            gradMag(gradMag < Threshold^2) = 0;

            % Mean edge strength
            T(i) = mean(gradMag(:));

        else

            % Logarithmic edge-energy measure
            T(i) = log(sum(gradMag(:)));

        end

    end

    %% Average score across all slices
    score = mean(T(:));

end