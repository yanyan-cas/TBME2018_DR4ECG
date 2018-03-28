function [M,ANNOT,ATRTIME] = MIT_AF_reader( filename )
%read the data and RR of ECG data.
%filename
%M--samples
%TIME--samples occur time
%ANNOT--annotation
%ATRTIME--

PATH = '../MIT-BIH_AF';
filename = char(filename);
HEADERFILE= strcat(filename,'.hea');    % .hea
ATRFILE= strcat(filename,'.atr');       % .atr
DATAFILE=strcat(filename,'.dat');       % .dat
% section_time = 1800;
% start_time  = (n -1) * section_time;
%% deal with .hea file
heaPath = fullfile(PATH, HEADERFILE);
hea_file =fopen(heaPath,'r');
line = fgetl(hea_file);
A = sscanf(line, '%*s %d %d %d',[1,3]);
channel = A(1);
frequency = A(2);
SAMPLENUM = A(3);          %2*SAMPLENUM
for k = 1 : channel           
    line = fgetl(hea_file);
    A = sscanf(line, '%*s %d %d %d %d %d',[1,5]);
    code_format(k) = A(1);          
    gain(k) = A(2);            
    valid_bit(k) = A(3);          
    zero_line(k) = A(4);      
    firstvalue(k) = A(5);
end;
fclose(hea_file);
if code_format ~= [212,212]
    error('binary formats different to 212.');
end

%% deal with .dat file -- each 30 mins
dataPath = fullfile(PATH, DATAFILE);             % '212'
data_file = fopen(dataPath,'r');
% offset = 3 * start_time * frequency;
% size = 3 * section_time * frequency;
% sp = fseek(data_file,offset,0);
A = fread(data_file, [3, SAMPLENUM], 'uint8')';  % matrix with 3 rows, each 8 bits long, = 2*12bit
fclose(data_file);
Ml2H = bitshift(A(:,2), -4);        
Ml1H = bitand(A(:,2), 15);          
PRL = bitshift(bitand(A(:,2),8),9);              % sign-bit
PRR = bitshift(bitand(A(:,2),128),5);            % sign-bit
M( : , 1) = bitshift(Ml1H,8)+ A(:,1)-PRL;
M( : , 2) = bitshift(Ml2H,8)+ A(:,3)-PRR;
M( : , 1) = (M( : , 1)) / 200;
M( : , 2) = (M( : , 2)) / 200;

% M( : , 1) = (M( : , 1) - zero_line(1)) / gain(1);
% M( : , 2) = (M( : , 2) - zero_line(2)) / gain(2);
% TIME = (0:(SAMPLENUM-1)) / frequency;
% TIME = TIME';

%% deal with .atr file
atrPath = fullfile(PATH, ATRFILE);  % attribute file with annotation data
atr_file = fopen(atrPath,'r');
B = fread(atr_file, [2, inf], 'uint8')';
fclose(atr_file);
ATRTIME = [];
ANNOT = [];
saa = numel(B) / 2;
i = 1;
while i < saa
    annoth = bitshift(B(i,2),-2);
    if annoth == 59
        ATRTIME=[ATRTIME;B(i+2,1)+bitshift(B(i+2,2),8)+...
                bitshift(B(i+1,1),16)+bitshift(B(i+1,2),24)];
        if B(i+5,2)==65 && B(i+6,2)==73
            ANNOT=[ANNOT;1];
        else
            ANNOT=[ANNOT;0];
        end
        i=i+3;
    elseif annoth==60
        % nothing to do
    elseif annoth==61
        % nothing to do
    elseif annoth==62
        % nothing to do
    elseif annoth==63
        hilfe=bitshift(bitand(B(i,2),3),8)+B(i,1);
        hilfe=hilfe+mod(hilfe,2);
        i=i+hilfe/2;
    else
        ATRTIME=[ATRTIME;bitshift(bitand(B(i,2),3),8)+B(i,1)];
        if B(i+2,2)==65 && B(i+3,2)==73
            ANNOT=[ANNOT;1];
        else
            ANNOT=[ANNOT;0];
        end
   end;
   i=i+1;
end;
% ANNOT(length(ANNOT)) = [];       % last line = EOF (=0)
% ATRTIME(length(ATRTIME)) = [];   % last line = EOF
ATRTIME= (cumsum(ATRTIME)) ;

end

