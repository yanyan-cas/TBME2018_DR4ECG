 function DR4ECG_MVU
load DATAUSING/PCAexpData.mat;

    no_dims = 14;
    k= 12;
    [mappedA, mapping] = lle(trainExp, no_dims,k);
    
    

        disp('Running Maximum Variance Unfolding...');
        opts.method = 'MVU';
 
    disp('CSDP OUTPUT =============================================================================');


    mappedA = cca(trainExp(mapping.conn_comp,:)', mappedA', mapping.nbhd(mapping.conn_comp, mapping.conn_comp)', opts);
    disp('=========================================================================================');
    mappedA = mappedA(1:no_dims,:)';

    
    
    trainFeatures = mappedA;
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
    
    save('KPCA/KPCAexpResults.mat','testLabel','pred');
    save('DATAUSING/KPCAexpData.mat', 'trainExp','testExp','trainLabelExp','testLabelExp');
    save('KPCA/KPCAparameters.mat','mappedX', 'mapping','varargin');
                        