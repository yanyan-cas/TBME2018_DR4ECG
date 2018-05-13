function DR4ECG_PCA
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

    addpath('C:\Users\HP\Desktop\TBME2018_DR4ECG');
    
    % Collect ecg data
    disp('Reading data files');
    %datasets = {'MITBIH_AtrialFibrilation','MITBIH_Arrhythmia', 'MITBIH_LT', 'MITBIH_NSR', 'LTAF', 'PICTArrhythmia'};
    datasets = {'MITBIH_Arrhythmia'}; %, 'MITBIH_LT', 'PICTArrhythmia'
    dataFlag.MITARRHY = 1;
    dataFlag.MITLT = 0;
    dataFlag.MITPICT = 0;
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
    
    label = remapLabels(label);
    
%% 3. Prepare for the Training and Testing samples ( Consider the label distribution)
    x1 = sampleSet(label==1, 1:340);
    x2 = sampleSet(label==2, 1:340);
    x3 = sampleSet(label==3, 1:340);
    x4 = sampleSet(label==4, 1:340);
    x5 = sampleSet(label==5, 1:340);
    
    m = randperm(size(x1, 1), round(size(x1, 1) * 0.8));
    trainX1 = x1(m, 1: 340);
    trainLabelX1 = ones(size(trainX1, 1),1);
    x1(m, :) = [];
    testX1 = x1;
    testLabelX1 = ones(size(testX1, 1),1);
    
    m = randperm(size(x2, 1), round(size(x2, 1) * 0.8));
    trainX2 = x2(m, 1: 340);
    trainLabelX2 = 2 * ones(size(trainX2, 1),1);
    x2(m, :) = [];
    testX2 = x2;
    testLabelX2 = 2 * ones(size(testX2, 1),1);
    
    m = randperm(size(x3, 1), round(size(x3, 1) * 0.8));
    trainX3 = x3(m, 1: 340);
    trainLabelX3 = 3 * ones(size(trainX3, 1),1);
    x3(m, :) = [];
    testX3 = x3;
    testLabelX3 = 3 * ones(size(testX3, 1),1);
        
    m = randperm(size(x4, 1), round(size(x4, 1) * 0.8));
    trainX4 = x4(m, 1: 340);
    trainLabelX4 = 4 * ones(size(trainX4, 1),1);
    x4(m, :) = [];
    testX4 = x4;
    testLabelX4 = 4 * ones(size(testX4, 1),1);
    
    m = randperm(size(x5, 1), round(size(x5, 1) * 0.8));
    trainX5 = x5(m, 1: 340);
    trainLabelX5 = 5 * ones(size(trainX5, 1),1);
    x5(m, :) = [];
    testX5 = x5;
    testLabelX5 = 5 * ones(size(testX5, 1),1);
    
    trainExp = [trainX1' trainX2' trainX3' trainX4' trainX5']';
    trainLabelExp = [trainLabelX1' trainLabelX2' trainLabelX3' trainLabelX4' trainLabelX5']';
    
    testExp = [testX1' testX2' testX3' testX4' testX5']';
    testLabelExp = [testLabelX1' testLabelX2' testLabelX3' testLabelX4' testLabelX5']';
    
    clear x1 x2 x3 x4 x5 x6
    clear trainX1 trainX2 trainX3 trainX4 trainX5
    clear testX1 testX2 testX3 testX4 testX5
    clear sampleSet
    clear data label testLabelX1 testLabelX2 testLabelX3 testLabelX4 testLabelX5
    clear trainLabelX1 trainLabelX2 trainLabelX3 trainLabelX4 trainLabelX5
    
%     dimesion = intrinsicDim(trainExp, 'MLE');
%     save dimesion
%     
    
%% 4. Try PCA first
    [mappedX, mapping] = pca(trainExp, 0.99);
    trainFeatures = mappedX;
    trainLabel = trainLabelExp;    

    % Classifier Training and Test
    numClasses = 5;
    addpath minFunc/
    options.Method = 'lbfgs'; 
    options.maxIter = 400;	
    options.display = 'on';    
    lambda = 1e-4;        % weight decay parameter      
    softmaxTheta = 0.005 * randn(size(trainFeatures, 2) * numClasses, 1);
    softmaxModel = softmaxTrain(size(trainFeatures, 2), numClasses, lambda, trainFeatures', trainLabel, softmaxTheta, options);

    testFeatures = bsxfun(@minus, testExp, mapping.mean) * mapping.M;
    testLabel = testLabelExp;
    [pred] = softmaxPredict(softmaxModel, testFeatures);
    acc = mean(testLabel(:) == pred(:));
    fprintf('Test Accuracy: %0.3f%%\n', acc * 100);      
    save('PCA/PCAexpResults.mat','testLabel','pred');
    save('DATAUSING/PCAexpData.mat', 'trainExp','testExp','trainLabelExp','testLabelExp');
    save('PCA/PCAparameters.mat','mappedX', 'mapping');
    
    

                        
