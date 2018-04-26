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
    % Intrinsic dimensionality estimation
    
     [mappedX, mapping] = pca(sampleSet(1:100, :), 100);
     
     
     
      t_point = bsxfun(@minus, point, mapping.mean) * mapping.M;
     
     
    
    
    
   
    
    
    
%% ?. Softmax Classifier
    
    %Use softmaxTrain.m to train a multi-class classifier. 
    softmaxInput = mappedX;
    
saeSoftmaxTheta = 0.005 * randn(hiddenSizeL2 * numClasses, 1);
addpath minFunc/
options.Method = 'lbfgs'; 
options.maxIter = 200;	
options.display = 'on';
softmaxModel = softmaxTrain(hiddenSizeL2, numClasses, lambda, ...
                            train2Features, trainlabels, options);
                        
                        
                        
                        
                        
                        
                        