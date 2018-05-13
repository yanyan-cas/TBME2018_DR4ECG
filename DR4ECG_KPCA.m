 function DR4ECG_KPCA
    load DATAUSING/PCAexpData.mat;
     varargin = 'gauss';
%     para1 = 1;
%     para2 = 2;
    no_dims = 14;
    [mappedX, mapping] = kernel_pca(trainExp, no_dims);
    
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
    
    
    % Compute and center kernel matrix
    K = gram(mapping.X, testExp, mapping.kernel, mapping.param1, mapping.param2);
    J = repmat(mapping.column_sums', [1 size(K, 2)]);
    K = K - repmat(sum(K, 1), [size(K, 1) 1]) - J + repmat(mapping.total_sum, [size(K, 1) size(K, 2)]);

    % Compute transformed points
    t_point = mapping.invsqrtL * mapping.V' * K;
    testFeatures = t_point';            
    testLabel = testLabelExp;
    
    [pred] = softmaxPredict(softmaxModel, testFeatures);
    acc = mean(testLabel(:) == pred(:));
    fprintf('Test Accuracy: %0.3f%%\n', acc * 100);   
    
    save('KPCA/KPCAexpResults.mat','testLabel','pred');
   % save('DATAUSING/KPCAexpData.mat', 'trainExp','testExp','trainLabelExp','testLabelExp');
    save('KPCA/KPCAparameters.mat','mappedX', 'mapping','varargin','testFeatures','trainFeatures');
    
    Y = tsne(testExp);
    figure; gscatter(Y(:,1), Y(:,2),testLabel);
    
    
    Y1 = tsne(testFeatures);
    figure; gscatter(Y1(:,1), Y1(:,2),testLabel);
    
                        