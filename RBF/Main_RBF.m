
% ����ʱ�����е� rbf Ԥ��(һ��Ԥ��) -- ������
% ʹ��ƽ̨ - Matlab7.1
% ���ߣ�½�񲨣��������̴�ѧ
% ��ӭͬ�����Ž���������������������������������ҵĸ�����ҳ
% �����ʼ���luzhenbo@yahoo.com.cn
% ������ҳ��http://blog.sina.com.cn/luzhenbo2

clc
clear all
close all
%--------------------------------------------------------------------------
% % X = csvread('../../data/logisFH.csv'); %t=7,d=4
% % X = csvread('../../data/ChebyshevFH.csv'); %t=d=4
% X = csvread('../../data/TentFH.csv'); %t=9,d=4
data=xlsread('FH_128_4095estim.csv');
len=length(data); %4095
numTimeStepsTrain =len-200; %4095-200=3895
data_train=data(1:numTimeStepsTrain);%data(1:3895) 3895*1
data_test=data(1+numTimeStepsTrain:end); %data(3896:4095)  200*1
%--------------------------------------------------------------------------
% ��ز���

t =1;                  % ʱ�� ԭֵ��1
d = 15;                  % Ƕ��ά�� ԭֵ��3
% n_tr = length(data_train);            % ѵ��������
% n_te = legdata_test;            % ����������

%--------------------------------------------------------------------------
% ��ռ��ع�

X_TR = data_train;
% min_X_TR = min(X_TR);
% max_X_TR = max(X_TR);
% [X_TR_scaled,Xp]= mapminmax(X_TR',0,1);
% min_X_TRscaled=min(X_TR_scaled)
% max_X_TRscaled=max(X_TR_scaled);

X_TE = [data_train(end-d+1:end);data_test];
% X_TE_scaled= mapminmax('apply',X_TE',Xp);
% X_TR=X_TR_scaled';
% X_TE=X_TE_scaled';

[XN_TR,DN_TR] = PhaSpaRecon(X_TR,t,d);
[XN_TE,DN_TE] = PhaSpaRecon(X_TE,t,d);

%--------------------------------------------------------------------------
% ѵ�������

P = XN_TR;
T = DN_TR;
spread =7;       % ��ֵԽ��,���ǵĺ���ֵ�ʹ�(Ĭ��Ϊ1)
net = newrbe(P,T,spread);

ERR1 = sim(net,XN_TR)-DN_TR;
err_mse1 = mean(ERR1.^2);
perr1 = err_mse1/var(data)

predict_y_scaled = sim(net,XN_TE);
ERR2 = predict_y_scaled -DN_TE;
err_mse2 = mean(ERR2.^2);
perr2 = err_mse2/var(data)
predict_y=mapminmax('reverse',predict_y_scaled', Xp);%����һ��
test_y=mapminmax('reverse',DN_TE', Xp);
predict_y(predict_y<0)=1;
%--------------------------------------------------------------------------
% �洢���
% xlswrite('RBFpredict_TentFH.xls', predict_y); 
% xlswrite('RBFtrue_TentFH.xls', test_y); 

% �����ͼ
figure;
% subplot(211);
plot(1:length(ERR2),test_y/100,'r*-',1:length(ERR2),predict_y/100,'bo-');
title('��ʵֵ(*)��Ԥ��ֵ(o)')
% subplot(212);
% plot(ERR2,'k');
% title('Ԥ��������')

