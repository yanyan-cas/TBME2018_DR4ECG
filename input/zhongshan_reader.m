function [ M , frequency] = zhongshan_reader( filename )
%read the ECG data.
%filename
%M--samples
PATH = '/Users/Yanyan/Documents/MATLAB/ECG_DATASET/ECG_sun/';
filename = char(filename);
ECGFILE= strcat(filename,'.ECG');   
infPath = fullfile(PATH, ECGFILE);
ecg_file =fopen(infPath, 'r');
frequency = fread(ecg_file, 1, 'int16');
offset = 128;
fseek(ecg_file, offset, -1);
M = fread(ecg_file, inf, 'int32')';  
fclose(ecg_file);
end

