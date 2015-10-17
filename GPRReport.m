%#####################################################%
%Copyright Sivarat Malapet 2015. All rights reserved%
%#####################################################%
%Read Input from file
finput = input('Input Data File:','s'); %ex. d:\t1.txt
fdatastr = fopen(finput,'r');
datastr = fscanf(fdatastr,'%s');
fclose(fdatastr);
datastr = strsplit(datastr,':');
datastr1 = strsplit(char(datastr(1)),',');
datastr2 = strsplit(char(datastr(2)),',');
datastr3 = strsplit(char(datastr(3)),',');
datastr4 = strsplit(char(datastr(4)),',');
datastr5 = strsplit(char(datastr(5)),',');
datastr6 = strsplit(char(datastr(6)),',');
datastr7 = strsplit(char(datastr(7)),',');
datasum  = strsplit(char(datastr(8)),',');

subplot(7,1,1);plot(datastr1);
ylabel('Buffer 1');

subplot(7,1,2);plot(datastr2);
ylabel('Buffer 2');

subplot(7,1,3);plot(datastr3);
ylabel('Buffer 3');

subplot(7,1,4);plot(datastr4);
ylabel('Buffer 4');

subplot(7,1,5);plot(datastr5);
ylabel('Buffer 5');

subplot(7,1,6);plot(datastr6);
ylabel('Moving Avg');

subplot(7,1,7);plot(datastr7);
label = strcat('Data Different Summary: ',datasum);
xlabel(label);
ylabel('Current Frame');

fprintf('%s%s\n','Data Sum:',datasum);
