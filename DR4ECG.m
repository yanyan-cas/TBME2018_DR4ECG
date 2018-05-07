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
    
  %  no_dims = intrinsic_dim(trainExp, 'CorrDim'); %check the intrinsic_dim
    
%% 4. Try PCA first
    
    % For no_dims (2nd parameter of pca), you can also specify a number between 0 and 1, determining 
    % the amount of variance you want to retain in the PCA step.
    [mappedX, mapping] = pca(trainExp, no_dims);
   
    % Once get the feature/representation matrix, train the Softmax
    % classifier in the last section
    trainFeatures = mappedX;
    trainLabel = trainLabelExp;    
    
    numClasses = 5;
    addpath minFunc/
    options.Method = 'lbfgs'; 
    options.maxIter = 200;	
    options.display = 'on';    
    lambda = 1e-4;        % weight decay parameter      
    softmaxTheta = 0.005 * randn(size(trainFeatures, 2) * numClasses, 1);
    softmaxModel = softmaxTrain(size(trainFeatures, 2), numClasses, lambda, trainFeatures', trainLabel, softmaxTheta, options);
     
    % Using the same mapping as the 
    testFeatures = bsxfun(@minus, testExp, mapping.mean) * mapping.M;
    testLabel = testLabelExp;
    
    [pred] = softmaxPredict(softmaxModel, testFeatures);
    acc = mean(testLabel(:) == pred(:));
    fprintf('Test Accuracy: %0.3f%%\n', acc * 100);
% %================================================================

%% 5. Isomap

%      [mappedX, mapping] =  isomap(trainExp, no_dims, 12);
%      
%     
% 
% 
%         
%  % Precomputations for speed
%             if strcmp(mapping.name, 'Isomap')
%                 invVal = inv(diag(mapping.val));
%                 [val, index] = sort(mapping.val, 'descend');
%                 mapping.landmarks = 1:size(mapping.X, 1);
%             else
%                 val = mapping.beta .^ (1 / 2);
%                 [val, index] = sort(real(diag(val)), 'descend');
%             end
% 
%             val = val(1:mapping.no_dims);
%             meanD1 = mean(mapping.DD .^ 2, 1);
%             meanD2 = mean(mean(mapping.DD .^ 2));
%             
%             % Process all points (notice that in this implementation 
%             % out-of-sample points are not used as landmark points)
%             point = testExp;
%             t_point = repmat(0, [size(point, 1) mapping.no_dims]);
%             for i=1:size(point, 1)
%                 
%                 % Compute distance of new sample to training points
%                 point = points(i,:);
%                 tD = L2_distance(point', mapping.X');
%                 [tmp, ind] = sort(tD); 
%                 tD(ind(mapping.k + 2:end)) = 0;
%                 tD = sparse(tD);
%                 tD = dijkstra([0 tD; tD' mapping.D], 1);
%                 tD = tD(mapping.landmarks + 1) .^ 2;
% 
%                 % Compute point embedding
%                 subB = -.5 * (bsxfun(@minus, tD, mean(tD, 2)) - meanD1 - meanD2);
%                 if strcmp(mapping.name, 'LandmarkIsomap')
%                     vec = subB * mapping.alpha * mapping.invVal;
%                     vec = vec(:,index(1:mapping.no_dims));
%                 else
%                     vec = subB * mapping.vec * mapping.val;
%                     vec = vec(:,index(1:mapping.no_dims));
%                 end
%                 t_point(i,:) = real(vec .* sqrt(val)');
%             end
% 
%             trainFeatures = mappedX;
%             trainLabel = trainLabelExp;    
% 
%             numClasses = 5;
%             addpath minFunc/
%             options.Method = 'lbfgs'; 
%             options.maxIter = 200;	
%             options.display = 'on';    
%             lambda = 1e-4;        % weight decay parameter      
%             softmaxTheta = 0.005 * randn(size(trainFeatures, 2) * numClasses, 1);
%             softmaxModel = softmaxTrain(size(trainFeatures, 2), numClasses, lambda, trainFeatures', trainLabel, softmaxTheta, options);


%% 6. Kernel PCA
     [mappedX, mapping] = kernelPCA(X, no_dims, varargin);
    
    
    
%% 8. MVU
    

    

%% 9. Diffusion Map
    
    
    
%% 10. 


%% 10. 
    
%% Classifier Training and Test
    numClasses = 5;
    addpath minFunc/
    options.Method = 'lbfgs'; 
    options.maxIter = 200;	
    options.display = 'on';    
    lambda = 1e-4;        % weight decay parameter      
    softmaxTheta = 0.005 * randn(hiddenSizeL3 * numClasses, 1);
    softmaxModel = softmaxTrain(size(trainFeatures, 2), numClasses, lambda, trainFeatures, trainLabel, softmaxTheta, options);
    
    [pred] = softmaxPredict(softmaxModel, testFeatures);
    
    acc = mean(testLabel(:) == pred(:));
    fprintf('Test Accuracy: %0.3f%%\n', acc * 100);
    
    
    
                        
                        
                        
                        
                        
                        
