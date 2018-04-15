%For NSR dataset, normal beats most

folder = '/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET/MITBIH_NSR/';
target_folder = '/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET/MITTBIH_NSR_MAT';
% scan all the .dat file
path = strcat(folder,'*.dat');
files = dir(path);
len = length(files);
%  Datafiles = cell(len,1);
data = [];
frequency = 128; % sampling frequency
for i = 1 : len
    % str = regexp(files(1).name,'.','split');
    [PATHSTR,NAME,EXT] = fileparts(files(i).name);
    fprintf('Parse the file: %s ... \n', NAME);
    marfile = strcat(NAME,'.mat');
    marfile = fullfile(target_folder,marfile);
     % Datafiles{i} = NAME;
     [M,TIME,~, ~]= rawReaderMITBIH_NSR( NAME );  % read the '212' format data
    ATRTIME = AATRTIME(1);
    ANNOT = [0];
    save(marfile,'M','ANNOT','ATRTIME');    
end