function readDatasets [datasetName, samples]
    % datasets = {'MITBIH_AF','MITBIH_Arrhythmia', 'MITBIH_LT', 'MITBIH_NSR', 'LTAF', 'PICTArrhythmia'};
    % This is the file for dealing with the PhysioNet Data samples
    % Base on the work from Xin-Bing Qin
    
    FLAG = 1; %Check if the files are transfered from the orignial files into .mat
    
    dataSet = datasetName;
    if FLAG == 0
        switch dataSet   
            case 'MITBIH_AF'        
                transferMITBIH_AF;
            case 'MITBIH_Arrhythmia'
                transferMITBIH_Arrhythmia;
            case 'MITBIH_LT'
                transferMITBIH_LongTerm;
            case  'MITBIH_NSR'
                transferMITBIH_NSR;
            case 'LT_AF'
                transferLongTerm_AF;
            case 'PICTArrhythmia'
                transferPICTArrhythmia;
            otherwise
                disp(e);
                warning('Nothing input ...');
                pause
        end

    end




end