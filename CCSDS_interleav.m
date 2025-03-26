clc;clear all;
K=8920;
k1=8;
k2=223*5;
s=(1:1:K);
p=[31,37,43,47,53,59,61,67];
m=mod(s-1,2);
ii=floor((s-1)./(2*k2));
jj=floor((s-1)./2)-ii*k2;
t=mod((19*ii+1),4);
q=mod(t,8)+1;
c=mod((p(q).*jj+21.*m),k2);
data_2_index=2*(t+c*4+1)-m;
AA=[1 0 1 1 1 0 1 1 1 1 0 0 1 1 0 1 1 1 0 1];
BB = randi([0 1], 1, 8880);
CC=[AA,BB,AA];
CC=CC';
fid = fopen('index_hex.mem', 'wt');
% data_2_index_binary=zeros(8920,16);
 data_2_index_binary=dec2hex(data_2_index(1:8920),4);
% fprintf(fid,"memory_initialization_radix = 2; \n");
% fprintf(fid,"memory_initialization_vector = \n");
for i = 1:length(data_2_index)
       if (i==length(data_2_index))
           fprintf(fid,"%s\n",data_2_index_binary(i,:)); 
       else
           fprintf(fid,"%s\n",data_2_index_binary(i,:)); 
       end
end
fclose(fid);