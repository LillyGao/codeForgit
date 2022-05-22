
% 混沌时间序列的 rbf 预测(一步预测) -- 主函数
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2

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
% 相关参数

t =1;                  % 时延 原值是1
d = 15;                  % 嵌入维数 原值是3
% n_tr = length(data_train);            % 训练样本数
% n_te = legdata_test;            % 测试样本数

%--------------------------------------------------------------------------
% 相空间重构

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
% 训练与测试

P = XN_TR;
T = DN_TR;
spread =7;       % 此值越大,覆盖的函数值就大(默认为1)
net = newrbe(P,T,spread);

ERR1 = sim(net,XN_TR)-DN_TR;
err_mse1 = mean(ERR1.^2);
perr1 = err_mse1/var(data)

predict_y_scaled = sim(net,XN_TE);
ERR2 = predict_y_scaled -DN_TE;
err_mse2 = mean(ERR2.^2);
perr2 = err_mse2/var(data)
predict_y=mapminmax('reverse',predict_y_scaled', Xp);%反归一化
test_y=mapminmax('reverse',DN_TE', Xp);
predict_y(predict_y<0)=1;
%--------------------------------------------------------------------------
% 存储结果
% xlswrite('RBFpredict_TentFH.xls', predict_y); 
% xlswrite('RBFtrue_TentFH.xls', test_y); 

% 结果做图
figure;
% subplot(211);
plot(1:length(ERR2),test_y/100,'r*-',1:length(ERR2),predict_y/100,'bo-');
title('真实值(*)与预测值(o)')
% subplot(212);
% plot(ERR2,'k');
% title('预测绝对误差')

