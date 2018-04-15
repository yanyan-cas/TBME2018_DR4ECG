folder = '/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET/PICT12LEAD_Arrhythmia/';
target_folder = '/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET/PICT12LEAD_Arrhythmia_MAT';

% This database consists of 75 annotated recordings extracted from 32 Holter records.
% Each record is 30 minutes long and contains 12 standard leads, each sampled at 257 Hz,
% with gains varying from 250 to 1100 analog-to-digital converter units per millivolt. 
% Gains for each record are specified in its .hea file. The reference annotation files 
% contain over 175,000 beat annotations in all. The original records were collected from 
% patients undergoing tests for coronary artery disease (17 men and 15 women, aged 18-80; 
% mean age: 58). None of the patients had pacemakers; most had ventricular ectopic beats. 
% In selecting records to be included in the database, preference was given to subjects with
% ECGs consistent with ischemia, coronary artery disease, conduction
% abnormalities, and arrhythmias.
% 


% scan all the .dat file
path = strcat(folder,'*.dat');
files = dir(path);
len = length(files);
%  Datafiles = cell(len,1);
data = [];
frequency = 257; % sampling frequency is 257Hz for PICT database.
for i = 1 : len
    % str = regexp(files(1).name,'.','split');
    [PATHSTR,NAME,EXT] = fileparts(files(i).name);
    fprintf('Parse the file: %s ... \n', NAME);
    marfile = strcat(NAME,'.mat');
    marfile = fullfile(target_folder,marfile);
     % Datafiles{i} = NAME;
    [M,TIME,ANNOT,ATRTIME]  = rawReaderPICTArrhythmia( NAME );  % read the data
    %ATRTIME = AATRTIME(1);
  %  ANNOT = [0];
    save(marfile,'M','TIME', 'ANNOT','ATRTIME');    
end