%Translate the origenal MIT data to corresponding mar file
%each file has four variances
%M--samples
%TIME--samples occur time
%ANNOT--annotation
%ATRTIME--corresponding annotation time
%This file transfer the hea dat file into a .mat file

dataset = {'100';'101';'102';'103';'104';'105';'106';'107';'108';'109';'111';'112';'113';'114';'115';...
    '116';'117';'118';'119';'121';'122';'123';'124';'200';'201';'202';'203';'205';'207';'208';'209';...
    '210';'212';'213';'214';'215';'217';'219';'220';'221';'222';'223';'228';'230';'231';'232';'233';'234'};
%%-------------------------------------------------------------------------
%save file in this folder
folder = '../MITBIH_Arrhythmia_MAT';
for i = 1 : size(dataset,1)
    filename = dataset{i};
    marfile = strcat(filename,'.mat');
    marfile = fullfile(folder,marfile);
    [M,TIME,ANNOT,ATRTIME] = rawReaderMITBIH_Arrhythmia(filename);  % read the '212' format data
    save(marfile,'M','TIME','ANNOT','ATRTIME');    
end