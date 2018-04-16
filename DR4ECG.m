function DR4ECG
% DR4ECG Tests all functionalities of the dimension reduction
% and all open source ecg signal dataset
%
%   DR4ECG
%
% Tests all functionalities of the dimension reduction and 
% experiments on different datasets.
%
%

% This file is part of the Matlab Toolbox for Dimensionality Reduction.
% The toolbox can be obtained from http://homepage.tudelft.nl/19j49
% You are free to use, change, or redistribute this code in any way you
% want for non-commercial purposes. However, it is appreciated if you 
% maintain the name of the original author.
%
% (C) Yan Yan, Shenzhen Institutes of Advance Technology, Chinese Academy
% of Sciences.

%   MITBIH_AF:   The MIT-BIH Atrial Fibrillation Database
%   MITBIH_Arrhythmia: MIT-BIH Arrhythmia Database  **
%   MITBIH_LT: The MIT-BIH Long Term Database             **
%   MITBIH_NSR: The MIT-BIH Normal Sinus Rhythm Database     ***
%   LTAF: The Long-Term AF Database
%   PICTArrhythmia: St. Petersburg Institute of Cardiological Technics 12-lead Arrhythmia Database.
%   EUSTT: European ST-T Database.
%   LTST:  Long-Term ST Database
%   

    addpath('/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET');
    
    % Collect ecg data
    disp('Reading data files');
    %datasets = {'MITBIH_AtrialFibrilation','MITBIH_Arrhythmia', 'MITBIH_LT', 'MITBIH_NSR', 'LTAF', 'PICTArrhythmia'};
    datasets = {'MITBIH_Arrhythmia'}; %, 'MITBIH_LT', 'PICTArrhythmia'
    dataFlag.MITARRHY = 1;
    dataFlag.MITLT = 1;
    dataFlag.MITPICT = 1;
    disp('Testing data generation functions...');

    %% 1. Raw Data input
    %
    X = readDatasets(datasets{1}, dataFlag);
    
    %% 2. Data Sample Extraction MITBIHArrhythmia Database finished.
    data = preprocessing(datasets{1}, X);
    clear X
    len = length(data);
    %tmp = zeros(len, 1);
    sampleNum = 0;
    for i = 1 : len
        data(i).Count = length(data(i).LABEL);
        sampleNum = sampleNum + data(i).Count;
    end
    sampleSet = zeros(sampleNum, 340);
    label = zeros(sampleNum, 1);
    tmp = 1;  
    
    for i = 1 : len
        for j = 1 :  data(i).Count   
           sampleSet(j + tmp-1, :) = data(i).DATA(j, :);     
           label(j + tmp-1) = data(i).LABEL(j);
        end      
         tmp = tmp + data(i).Count;
    end
    
%% 3. Try PCA first
    intrinsic_dim(sampleSet, 'MLE');
     % Test all intrinsic dimensionality estimators
    disp('Testing intrinsic dimensionality estimators...');
    techniques = {'CorrDim', 'NearNbDim', 'GMST', 'PackingNumbers', 'EigValue', 'MLE'};
    for i=1:length(techniques)
        try
            intrinsic_dim(X, techniques{i});
        catch e
            disp(e);
            warning(['Intrinsic dimensionality estimation using ' techniques{i} ' failed! Press any key to continue tests...']);
            pause
        end
    end
    
     % Test all unsupervised dimension reduction techniques
     disp('Testing dimensionality reduction techniques...');
     techniques = {'PCA', 'MDS', 'ProbPCA', 'FactorAnalysis', 'GPLVM', 'Sammon', 'Isomap', ...
         'LandmarkIsomap', 'LLE', 'Laplacian', 'HessianLLE', 'LTSA', 'MVU', 'CCA', 'LandmarkMVU', ...
         'FastMVU', 'DiffusionMaps', 'KernelPCA', 'GDA', 'SNE', 'SymSNE', 'tSNE', 'LPP', 'NPE', ...
         'LLTSA', 'SPE', 'Autoencoder', 'LLC', 'ManifoldChart', 'CFA'};
     for i=1:length(techniques)
         
         % Test the dimension reduction technique
         try
             if any(strcmpi(techniques{i}, {'GPLVM', 'CFA'}))
                [mappedX, mapping] = compute_mapping(unscaled_X, techniques{i}, 2);
             else
                [mappedX, mapping] = compute_mapping(X, techniques{i}, 2);
             end
             if any(strcmpi(techniques{i}, {'Isomap', 'LandmarkIsomap', 'LLE', 'Laplacian', 'MVU', 'CCA', 'FastMVU', 'LPP', 'NPE', 'LLTSA'}))
                 [mappedX, mapping] = compute_mapping(X, techniques{i}, 2, 'adaptive');
             end
         catch e
             disp(e);
             warning(['Technique ' techniques{i} ' failed! Press any key to continue tests...']);
             pause
         end
      
        % Test the out-of-sample extension code
         if any(strcmpi(techniques{i}, {'PCA', 'LPP', 'NPE', 'LLTSA', 'SPCA', 'PPCA', 'FA'}))
             try
                 out_of_sample(X, mapping);
             catch e
                 disp(e);
                 warning(['Out-of-sample extension for technique ' techniques{i} ' failed! Press any key to continue tests...']);
                 pause                
             end
        end
         
         % Test reconstruction code
         if any(strcmpi(techniques{i}, {'PCA', 'LPP', 'NPE', 'LLTSA', 'SPCA', 'PPCA', 'FA', 'Autoencoder'}))
             try
                 reconstruct_data(mappedX, mapping);
             catch e
                 disp(e);
                 warning(['Reconstruction for technique ' techniques{i} ' failed! Press any key to continue tests...']);
                 pause
           end
       end
    end
   
     % Test approximate out-of-sample function
     try
         out_of_sample_est(X, X, mappedX);
     catch e
         disp(e);
         warning(['Approximate out-of-sample extension failed! Press any key to continue tests...']);
         pause                
     end
     
     % Test all supervised dimension reduction techniques
     labels = double(X(:,1) > .5) + 1;
     X = [labels X];
     techniques = {'LDA', 'NCA', 'MCML', 'LMNN'};
     for i=1:length(techniques)
         
         % Test the actual technique
         try
             [mappedX, mapping] = compute_mapping(X, techniques{i}, 2);
        catch e
            disp(e);
            warning(['Technique ' techniques{i} ' failed! Press any key to continue tests...']);
            pause
        end
        
        % Test out-of-sample extension
        try
            out_of_sample(X(:,2:end), mapping);
        catch e
            disp(e);
            warning(['Out-of-sample extension for technique ' techniques{i} ' failed! Press any key to continue tests...']);
            pause
        end
        
        % Test reconstruction code
        try
            reconstruct_data(mappedX, mapping);
        catch e
            disp(e);
            warning(['Reconstruction for technique ' techniques{i} ' failed! Press any key to continue tests...']);
            pause
        end
        
    end
    disp('All tests completed!');    
    