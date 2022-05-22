

% 混沌时间序列的 rbf 预测(多步预测) -- 主函数
% 使用平台 - Matlab7.1
% 作者：陆振波，海军工程大学
% 欢迎同行来信交流与合作，更多文章与程序下载请访问我的个人主页
% 电子邮件：luzhenbo@yahoo.com.cn
% 个人主页：http://blog.sina.com.cn/luzhenbo2

clc
clear
close all

%--------------------------------------------------------------------------
% 产生混沌序列
% dx/dt = sigma*(y-x)
% dy/dt = r*x - y - x*z
% dz/dt = -b*z + x*y

% sigma = 16;             % Lorenz 方程参数 a
% b = 4;                  %                 b
% r = 45.92;              %                 c            
% 
% y = [-1,0,1];           % 起始点 (1 x 3 的行向量)
% h = 0.01;               % 积分时间步长
% 
% k1 = 30000;             % 前面的迭代点数
% k2 = 5000;              % 后面的迭代点数 (总样本数)
% 
% Z = LorenzData(y,h,k1+k2,sigma,r,b);
% X = Z(k1+1:end,1);
% X = normalize_1(X);     % 归一化到均值为0，方差1
X = csvread('logisFH.csv');
% X = normalize_1(X);     % 归一化到均值为0，方差1
%--------------------------------------------------------------------------
% 相关参数

t = 6;                  % 时延 原值是1
d = 4;                  % 嵌入维数 原值是3
n_tr = 0.9*length(X);            % 训练样本数
n_te = 0.1*length(X);            % 测试样本数
%--------------------------------------------------------------------------
% 相空间重构
X_TR = X(1:n_tr);
min_X_TR = min(X_TR)
max_X_TR = max(X_TR)
[X_TR_scaled,Xp]= mapminmax(X_TR',0,1);
min_X_TRscaled=min(X_TR_scaled)
max_X_TRscaled=max(X_TR_scaled)

X_TE = X(n_tr+1:n_tr+n_te);
X_TE_scaled= mapminmax(X_TE',Xp);
X_TR=X_TR_scaled';
X_TE=X_TE_scaled';

[XN_TR,DN_TR] = PhaSpaRecon(X_TR,t,d);
[XN_TE,DN_TE] = PhaSpaRecon(X_TE,t,d);
%--------------------------------------------------------------------------
% 训练

P = XN_TR;
T = DN_TR;
spread = 3;         % 此值越大,覆盖的函数值就大(默认为1)
net = newrbe(XN_TR,DN_TR);
ERR1 = sim(net,XN_TR)-DN_TR;
err_mse1 = sqrt(sum(ERR1.^2)/length(ERR1))   %rmse         

%--------------------------------------------------------------------------
% 多步预测

n_pr = 30;

X_ST = X_TR(n_tr-(d-1)*t:n_tr);
DN_PR = zeros(n_pr,1);
for i=1:n_pr
    XN_ST = PhaSpaRecon(X_ST,t,d);
    predict(i) = sim(net,XN_ST);
    X_ST = [X_ST(2:end);predict(i)];
end
test = X_TE(1:n_pr);
predict_y=mapminmax('reverse',predict', Xp);%反归一化
test_y=mapminmax('reverse',test', Xp);
%--------------------------------------------------------------------------
% 作图

figure;
subplot(211)
plot(n_tr+1:n_tr+n_pr,test_y,'r*-',...
     n_tr+1:n_tr+n_pr,predict_y,'bo-');
title('真实值(*)与预测值(o)')
subplot(212)
plot(n_tr+1:n_tr+n_pr,abs(DN_TE(end-29:end)-DN_PR'),'k'); grid;
title('预测绝对误差')

