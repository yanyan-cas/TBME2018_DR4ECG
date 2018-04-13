function readDatasets [datasetName, samples]
    % datasets = {'MITBIH_AF','MITBIH_Arrhythmia', 'MITBIH_LT', 'MITBIH_NSR', 'LTAF', 'PICTArrhythmia'};
    % This is the file for dealing with the PhysioNet Data samples
    % Base on the work from Xin-Bing Qin
    
    FLAG = 1; %Check if the files are transfered from the orignial files into .mat
    
    dataSet = datasetName;
    if FLAG == 0
        switch dataSet   
            case 'MITBIH_AF'        
                dataReadMITBIH_AtrialFibrilation;
            case 'MITBIH_Arrhythmia'
                dataReadMITBIH_Arrhythmia;
            case 'MITBIH_LT'
                dataReadMITBIH_LongTerm;
            case  'MITBIH_NSR'
                dataReadMITBIH_NSR;
            case 'LT_AF'
                dataReadLongTerm_AF;
            case 'PICTArrhythmia'
                dataReadPICTArrhythmia;
            otherwise
                disp(e);
                warning('Nothing input ...');
                pause
        end
    end
    
    


end