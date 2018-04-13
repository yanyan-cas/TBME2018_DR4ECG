%Translate the origenal MIT data to corresponding mat file
%each file has four variances
%M--samples
%TIME--samples occur time
%ANNOT--annotation
%ATRTIME--corresponding annotation time
%This file transfer the hea dat file into a .mat file

dataset = {'15814'; '14046';'14134';'14149';'14157';'14172';'14184'};
%%-------------------------------------------------------------------------
%save file in this folder
folder = '/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET/MITBIH_LongTerm_MAT';
for i = 1 : size(dataset,1)
    filename = dataset{i};
    marfile = strcat(filename,'.mat');
    marfile = fullfile(folder,marfile);
    [M,TIME,ANNOT,ATRTIME] = rawReaderMITBIH_LongTerm(filename);  % read the '212' format data
    save(marfile,'M','TIME','ANNOT','ATRTIME');    
end