function [score, objectives] = objective( ...
                    projections, geo, angles, ...
                    individual, header, type, ...
                    Recon_algorithm, varargin)
% OBJECTIVE Evaluate the fitness of a candidate solution.
%
% This function reconstructs an image using the selected reconstruction
% algorithm and evaluates its quality using the specified metric. The
% resulting fitness score is used by the optimization algorithm to guide
% the search toward better parameter combinations.
%
% Inputs:
%   projections
%       Projection data of the scanned object.
%
%   geo
%       Geometry structure compatible with TIGRE reconstruction methods.
%
%   angles
%       Projection acquisition angles.
%
%   individual
%       Candidate solution containing the reconstruction parameters.
%
%   header
%       String array containing the names of the optimized parameters.
%
%   type
%       Image-quality metric used as the objective function.
%
%       Reference-based metrics:
%           "RMSE"
%           "CC"
%           "SSIM"
%           "PSNR"
%
%       Region-based metrics:
%           "CNR"
%           "GCNR"
%
%       No-reference metrics:
%           "SNR"
%           "SNR_HFER"
%           "SNR_Tenegrad"
%           "SNR_Laplac"
%           "HFER"
%           "Laplac"
%
%   Recon_algorithm
%       Reconstruction algorithm to evaluate.
%
%       Supported options:
%           "ASD_POCS"
%           "OS_ASD_POCS"
%           "PICCS"
%           "PCSD"
%           "AwPCSD"
%
%   varargin
%       Optional inputs.
%
%       Reference image:
%           Required for reference-based metrics and PICCS.
%
%       Slice number:
%           Required for CNR and GCNR calculations.
%
% Outputs:
%   score
%       Fitness value used by the optimizer.
%
%       Lower values correspond to better solutions.
%
%   objectives
%       Raw metric values used to compute the score.
%
%       For multi-objective metrics, multiple values may be returned.
%
% Method:
%   1. Validate the selected metric.
%   2. Execute the selected reconstruction algorithm using the
%      candidate parameters.
%   3. Compute the requested image-quality metric.
%   4. Convert the metric into a minimization fitness score.
%
% Notes:
%   - All fitness values are formulated as minimization objectives.
%   - Some metrics are internally inverted to ensure that lower scores
%     indicate better reconstruction quality.
%   - Regions for CNR and GCNR can be selected interactively and are
%     automatically saved for future evaluations.
%
% Example:
%   [score, objectives] = objective( ...
%       projections, geo, angles, ...
%       individual, header, ...
%       "RMSE", "ASD_POCS", reference);
%
% Coded by:
%   <Poorya MohammadiNasab (https://github.com/Pooryamn)>
%
% ---------------------------------------------------------------------

    %% Validate and prepare metric inputs

    if strcmp(type,"RMSE") || ...
       strcmp(type,"CC") || ...
       strcmp(type,"SSIM") || ...
       strcmp(type,"PSNR")

        % Reference image required
        if size(varargin,2) == 0

            error("For reference-based metrics, a reference image must be provided.");

        end

        Reference = varargin{1,1};

    elseif strcmp(type,"CNR") || strcmp(type,"GCNR")

        slice_num = varargin{1,1};

        %% Load or define ROI regions

        if exist("Regions.mat",'file') == 2

            load("Regions.mat");

            ForeGround = Regions(1,:);
            BackGround = Regions(2,:);

        else

            % Create an FDK reconstruction for ROI selection
            disp('Reconstructing using FDK...');

            imgFDK = FDK(projections, geo, angles);

            fig = figure();
            imshow(imgFDK(:,:,slice_num), []);
            ForeGround = getrect(fig);
            close all;

            fig = figure();
            imshow(imgFDK(:,:,slice_num), []);
            BackGround = getrect(fig);
            close all;

            Regions = [ForeGround; BackGround];

            save("Regions.mat","Regions");

        end

    elseif strcmp(type,"SNR") || ...
           strcmp(type,"SNR_HFER") || ...
           strcmp(type,"SNR_Tenegrad") || ...
           strcmp(type,"SNR_Laplac") || ...
           strcmp(type,"HFER") || ...
           strcmp(type,"Laplac")

        % No additional setup required

    else

        error("Metric passed as 'type' was not recognized.");

    end

    %% Execute reconstruction algorithm

    iterations = int16(individual(1,1));

    switch Recon_algorithm

        case "ASD_POCS"

            reconstruction_res = ASD_POCS( ...
                    projections, geo, angles, iterations, ...
                    string(header(2)), int16(individual(1,2)), ...
                    string(header(3)), int16(individual(1,3)), ...
                    string(header(4)), individual(1,4), ...
                    string(header(5)), individual(1,5), ...
                    string(header(6)), individual(1,6), ...
                    string(header(7)), individual(1,7), ...
                    string(header(8)), individual(1,8));

        case "OS_ASD_POCS"

            reconstruction_res = OS_ASD_POCS( ...
                    projections, geo, angles, iterations, ...
                    string(header(2)), int16(individual(1,2)), ...
                    string(header(3)), int16(individual(1,3)), ...
                    string(header(4)), individual(1,4), ...
                    string(header(5)), individual(1,5), ...
                    string(header(6)), individual(1,6), ...
                    string(header(7)), individual(1,7), ...
                    string(header(8)), individual(1,8));

        case "PICCS"

            reconstruction_res = PICCS( ...
                    projections, geo, angles, ...
                    iterations, Reference, ...
                    string(header(2)), int16(individual(1,2)), ...
                    string(header(3)), int16(individual(1,3)), ...
                    string(header(4)), individual(1,4), ...
                    string(header(5)), individual(1,5), ...
                    string(header(6)), individual(1,6), ...
                    string(header(7)), individual(1,7), ...
                    string(header(8)), individual(1,8));

        case "PCSD"

            reconstruction_res = PCSD( ...
                    projections, geo, angles, iterations, ...
                    string(header(2)), int16(individual(1,2)), ...
                    string(header(3)), int16(individual(1,3)), ...
                    string(header(4)), individual(1,4), ...
                    string(header(5)), individual(1,5));

        case "AwPCSD"

            reconstruction_res = AwPCSD( ...
                    projections, geo, angles, iterations, ...
                    string(header(2)), int16(individual(1,2)), ...
                    string(header(3)), int16(individual(1,3)), ...
                    string(header(4)), individual(1,4), ...
                    string(header(5)), individual(1,5), ...
                    string(header(6)), individual(1,6));

    end

    %% Evaluate reconstruction quality

    switch type

        %% Reference-based metrics

        case "RMSE"

            objectives = RMSE(reconstruction_res, Reference);
            score = objectives;

        case "CC"

            objectives = CorrCoef(reconstruction_res, Reference);
            score = 1 - objectives;

        case "SSIM"

            objectives = ssim(reconstruction_res, Reference);
            score = 1 - objectives;

        case "PSNR"

            objectives = psnr(reconstruction_res, Reference);
            score = 1 / objectives;

        %% Region-based metrics

        case "CNR"

            object = reconstruction_res( ...
                ForeGround(2):ForeGround(2)+ForeGround(4), ...
                ForeGround(1):ForeGround(1)+ForeGround(3), ...
                slice_num);

            BG = reconstruction_res( ...
                BackGround(2):BackGround(2)+BackGround(4), ...
                BackGround(1):BackGround(1)+BackGround(3), ...
                slice_num);

            objectives = CNR(object, BG);
            score = 1 / objectives;

        case "GCNR"

            object = reconstruction_res( ...
                ForeGround(2):ForeGround(2)+ForeGround(4), ...
                ForeGround(1):ForeGround(1)+ForeGround(3), ...
                slice_num);

            BG = reconstruction_res( ...
                BackGround(2):BackGround(2)+BackGround(4), ...
                BackGround(1):BackGround(1)+BackGround(3), ...
                slice_num);

            objectives = GCNR(object, BG, 128);
            score = 1 / objectives;

        %% No-reference metrics

        case "SNR"

            objectives = SNR(reconstruction_res);
            score = 1 / objectives;

        case "SNR_HFER"

            [score, SNR_score, Frequency_score] = ...
                SNR_FREQ(reconstruction_res, 7, 4.5, 0.01);

            objectives = [SNR_score, Frequency_score];

        case "SNR_Tenegrad"

            score = SNR_Tenegrad( ...
                reconstruction_res, 1, 3, 'sum');

            objectives = score;

        case "SNR_Laplac"

            [score, SNR_score, lapace_score] = ...
                SNR_Laplac(reconstruction_res, 2, 1);

            objectives = [SNR_score, lapace_score];

        case "HFER"

            objectives = Frequency_energy( ...
                reconstruction_res, 0.01);

            score = 1 - objectives;

        case "Laplac"

            objectives = Laplacian_Variance( ...
                reconstruction_res, 0.7, 0.1);

            score = 1 / objectives;

    end

end