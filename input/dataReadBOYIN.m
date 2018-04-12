function [M, ATRTIME] = boyin_reader(filename)
%read the data and RR of ECG data.
%filename
%M--samples
%ATRTIME--
PATH = '/Users/Yanyan/Documents/MATLAB/DATASET/ECG_DATASET/ECG_boyin/';
filename = char(filename);
INFFILE= strcat(lower(filename),'.inf');      % .inf
RRFILE= strcat(lower(filename),'.rr');        % .rr
DATAFILE=strcat(filename,'.pd');       % .dat
%% deal with .inf file
infPath = fullfile(PATH, INFFILE);
inf_file =fopen(infPath,'r');
A = textscan(inf_file,'%*s %d',1,'HeaderLines',8);
frequency = A{1};
fgetl(inf_file);
line = fgetl(inf_file);
channel = sscanf(line, '%*s %d',[1]);
line = fgetl(inf_file);
HitBytes = sscanf(line, '%*s %d',[1]);
line = fgetl(inf_file);
ADC  = sscanf(line, '%*s %d',[1]);
line = fgetl(inf_file);
ADCZero  = sscanf(line, '%*s %d',[1]);
fclose(inf_file);
if channel ~= 3
    error('binary formats are different.');
end

%% deal with .dat file
dataPath = fullfile(PATH, DATAFILE);
data_file = fopen(dataPath,'r');
offset = 95;
sp = fseek(data_file,offset,0);
if sp == 0
    M3 = fread(data_file, inf, 'uint8');
    M = M3(3:3:end);
    index = find(M(1:200,1) == 0);
    M(index) = ADCZero;
    M = (M - ADCZero) / ADC;
else
    M = [];
end
fclose(data_file);

%% deal with .RR file
RRPath = fullfile(PATH, RRFILE);      % attribute file with annotation data
rr_file = fopen(RRPath, 'r');
A = textscan(rr_file, '%*s %*s %d');
ATRTIME = double(A{1}) / 1000;       % s
fclose(rr_file);
end