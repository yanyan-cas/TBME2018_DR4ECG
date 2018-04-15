function  output = readDatasets (datasetName, dataFlag)
    % datasets = {'MITBIH_Arrhythmia', 'MITBIH_LT',  'PICTArrhythmia'};
    % This is the file for dealing with the PhysioNet Data samples

    %Check if the files are transfered from the orignial files into .mat
    
    switch datasetName
        case 'MITBIH_Arrhythmia'
            if dataFlag.MITARRHY == 1
                disp('loading dataset MITBIH_Arrhythmia, please wait ...');
                folder = '/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET/MITBIH_Arrhythmia_MAT/';
            else
                disp('generate MAT file first, use the fucntions in the input folder');
            end     
   %%================== 
        case  'MITBIH_LT'   
            if dataFlag.MITLT == 1
                disp('loading dataset MITBIH_LongTerm, please wait ...');
                folder = '/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET/MITBIH_LongTerm_MAT/';
            else
                 disp('generate MAT file first, use the fucntions in the input folder for MITBIH_LT');
            end
    %%==================
        case 'PICTArrhythmia'
             if dataFlag.PICT == 1
                disp('loading dataset PICT12LEAD_Arrhythmia_MAT, please wait ...');
                folder = '/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET/PICT12LEAD_Arrhythmia_MAT/';
            else
                 disp('generate MAT file first, use the fucntions in the input folder for PICT');
             end
          %%==================  
        otherwise
            disp('dataset name error, no dataset name detected...');
    end
    
    %%==============
    matfiles = strcat(folder,'*.mat');
    files = dir(matfiles);
    len = length(files);
    sample = struct('M', {},'TIME', {},'ATRTIME', {}, 'ANNOT', {});
    X = repmat(sample, len, 1);     
    sampleX = {'M', 'TIME', 'ATRTIME', 'ANNOT'};
        for i = 1 : len
         %    X(i).M = load(files(i).name, 'M'); 
            name = fullfile(folder, files(i).name);
            X(i) = load(name, sampleX{:});
        end    
    output = X;
end