%#####################################################%
%Copy rights Sivarat Malapet 2015. All rights reserved%
%#####################################################%
%Read Input of Frame1 and Frame2 from file
%Ex. d:\t1.txt, d:\t2.txt, d:\t9.txt
frame1 = input('Input Buffer Frame1:','s'); %ex. d:\t1.txt
frame2 = input('Input Buffer Frame2:','s'); %ex. d:\t2.txt
frame3 = input('Input Buffer Frame3:','s'); %ex. d:\t3.txt
frame4 = input('Input Buffer Frame4:','s'); %ex. d:\t4.txt
frame5 = input('Input Buffer Frame5:','s'); %ex. d:\t5.txt
frame6 = input('Input for Auto Calibrate:','s'); %ex. d:\t7.txt
frame7 = input('Input As Current Frame:','s'); %ex. d:\t9.txt
fid1 = fopen(frame1,'r');%Moving Avg Frame 1
fid2 = fopen(frame2,'r');%Moving Avg Frame 2
fid3 = fopen(frame3,'r');%Moving Avg Frame 3
fid4 = fopen(frame4,'r');%Moving Avg Frame 4
fid5 = fopen(frame5,'r');%Moving Avg Frame 5
fid6 = fopen(frame6,'r');%For Auto Calibrate
fid7 = fopen(frame7,'r');%As Current Frame (Test Frame)
arrayb1 = fscanf(fid1,'%e%e%e%e%e%e%e%e%e',[9,inf]);
arrayb2 = fscanf(fid2,'%e%e%e%e%e%e%e%e%e',[9,inf]);
arrayb3 = fscanf(fid3,'%e%e%e%e%e%e%e%e%e',[9,inf]);
arrayb4 = fscanf(fid4,'%e%e%e%e%e%e%e%e%e',[9,inf]);
arrayb5 = fscanf(fid5,'%e%e%e%e%e%e%e%e%e',[9,inf]);
arra4adjust = fscanf(fid6,'%e%e%e%e%e%e%e%e%e',[9,inf]);
array2 = fscanf(fid7,'%e%e%e%e%e%e%e%e%e',[9,inf]);%As Current Frame (Test Frame)
fclose(fid1);
fclose(fid2);
fclose(fid3);
fclose(fid4);
fclose(fid5);
fclose(fid6);
fclose(fid7);

%Initial Parameters
temparray1 = 0;%show only
temparray2 = 0;%show only
movingarr = 0;%moving avg with weight
tempSum = 0;%show only
tempS = 0;%show only
C = -3;
Q = 100; %txtMParam in C# code
S = 1; %k in C# code (Represent Different Threshold in Each Point of 2 Frame)
diff_sampling_val = 0;
sum = 0;
isdetected = false;

%===========================Start Moving Avg with Weight===================%
for i=1:800
   movingarr(i) = (0.5*arrayb1([3],i))+(0.25*arrayb2([3],i))+(0.125*arrayb3([3],i))+(0.0625*arrayb4([3],i))+(0.0625*arrayb5([3],i)); 
   arrayb5([3],i) = arrayb4([3],i);
   arrayb4([3],i) = arrayb3([3],i);   
   arrayb3([3],i) = arrayb2([3],i);   
   arrayb2([3],i) = arrayb1([3],i);   
   arrayb1([3],i) = array2([3],i);   
end
%==========================================================================%

%===========================Start Auto Calibrate===========================%
for k=1:10000
    if(S <= k)%Start Auto Calibrate Loop
        diff_sampling_val = 0;
        %(1) Scan 800 points and filter only negative value AND more than clipping
        %value
        for i=1:800
            if( (movingarr(i) >= 0 || movingarr(i) < C) || (arra4adjust([3],i) >= 0 || arra4adjust([3],i) < C) )
                temparray1(i) = 0;
                temparray2(i) = 0;
                diff_sampling_val(i) = 0;
            else
                temparray1(i) = movingarr(i);
                temparray2(i) = arra4adjust([3],i);
                diff_sampling_val(i) = abs( abs(movingarr(i)) - abs(arra4adjust([3],i)) ) / abs(arra4adjust([3],i));
            end
            
            diff_sampling_val(i) = diff_sampling_val(i)*1000;
            if(diff_sampling_val(i)>=k)
                diff_sampling_val(i) = 1;
            else
                diff_sampling_val(i) = 0;
            end    
            %fprintf('%e\n',diff_sampling_val(i));
        end %End Scan 800 Points For Each Loop
        
        %(2)
        sum = 0;

        for j=1:800
            if(diff_sampling_val(j)==1)
                sum = sum+1;
            end 
        end    
        
        tempSum(k) = sum;
        tempS(k) = k;
        
        if(sum>=Q) %Q = txtMParam in C# code
            isdetected = true;
        else
            isdetected = false;
        end

        if(isdetected)
            fprintf('%s %e %s %e %s %e\n','Calibrated.. SumM=',sum,' And S=',k,'Loop k=',k);
        else
            S = k;
            fprintf('%s %e %s %e %s %e\n','Calibrated Completed.. SumM=',sum,' And S=',S,'Loop k=',k);
            break;
        end
        
    end    
end %End Auto Calibrate Loop    

%===========================Run Working Mode===========================%
r_sum = 0;
r_diff = 0;
temparray1 = 0;
temparray2 = 0;

%(1)
for i=1:800
    %array2 as test frame (normally hole graph ex. d:\t9.txt)        
    %movingarr as Moving Avg Result Frame
    if( (movingarr(i) >= 0 || movingarr(i) < C) || (array2([3],i) >= 0 || array2([3],i) < C) )
        temparray1(i) = 0;
        temparray2(i) = 0;
        r_diff(i) = 0;
    else
        temparray1(i) = movingarr(i);
        temparray2(i) = array2([3],i);
        r_diff(i) = abs( abs(movingarr(i)) - abs(array2([3],i)) ) / abs(array2([3],i));
    end

    r_diff(i) = r_diff(i)*1000;
    if(r_diff(i)>=k)
        r_diff(i) = 1;
    else
        r_diff(i) = 0;
    end    
    
end    

%(2)
sum = 0;

for j=1:800
    if(r_diff(j)==1)
        sum = sum+1;
    end 
end

%(3)Make Dicision
if(sum>=Q) %Q = txtMParam in C# code
    fprintf('%s %s %e %s %e\n','*****Hole Detected!*****',' sum=',sum,' Q=',Q);
else
	fprintf('%s %s %e %s %e\n','Normal Ground..',' sum=',sum,' Q=',Q);
end


%=====================================================================%

%Show Raw Data Of Moving Avg with Weight
subplot(4,2,1);plot(movingarr);
xlabel('Time(ns)');
ylabel('Voltage(v)');
title('Moving Avg with Weight Waveform as Reference');

%Show Raw Data For Test As Test Frame
subplot(4,2,2);plot(array2([1],:),array2([3],:));
title('GPR Waveform for Test Frame');

%Show Filtered Data of Moving Avg Data
subplot(4,2,3);plot(temparray1);
title('Filtered Moving Avg');

%Show Filtered Data of Test Frame
subplot(4,2,4);plot(temparray2);
title('Filtered Test Frame');

%Show Diff Array (Working Mode)
subplot(4,2,5);plot(r_diff);
title('rdiff in Working Mode');

%Show tempSum in Autcalibrate Mode
subplot(4,2,6);plot(tempSum);
title('Graph of Sum in Autcalibrate Mode');

%Show tempS in Autocalibrate Mode
subplot(4,2,7);plot(tempS);
title('Graph of Developed S in Autocalibrate Mode');

%Show r_diff
%plot(r_diff);
%title('r_diff');
