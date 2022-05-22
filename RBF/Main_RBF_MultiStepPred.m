

% ����ʱ�����е� rbf Ԥ��(�ಽԤ��) -- ������
% ʹ��ƽ̨ - Matlab7.1
% ���ߣ�½�񲨣��������̴�ѧ
% ��ӭͬ�����Ž���������������������������������ҵĸ�����ҳ
% �����ʼ���luzhenbo@yahoo.com.cn
% ������ҳ��http://blog.sina.com.cn/luzhenbo2

clc
clear
close all

%--------------------------------------------------------------------------
% ������������
% dx/dt = sigma*(y-x)
% dy/dt = r*x - y - x*z
% dz/dt = -b*z + x*y

% sigma = 16;             % Lorenz ���̲��� a
% b = 4;                  %                 b
% r = 45.92;              %                 c            
% 
% y = [-1,0,1];           % ��ʼ�� (1 x 3 ��������)
% h = 0.01;               % ����ʱ�䲽��
% 
% k1 = 30000;             % ǰ��ĵ�������
% k2 = 5000;              % ����ĵ������� (��������)
% 
% Z = LorenzData(y,h,k1+k2,sigma,r,b);
% X = Z(k1+1:end,1);
% X = normalize_1(X);     % ��һ������ֵΪ0������1
X = csvread('logisFH.csv');
% X = normalize_1(X);     % ��һ������ֵΪ0������1
%--------------------------------------------------------------------------
% ��ز���

t = 6;                  % ʱ�� ԭֵ��1
d = 4;                  % Ƕ��ά�� ԭֵ��3
n_tr = 0.9*length(X);            % ѵ��������
n_te = 0.1*length(X);            % ����������
%--------------------------------------------------------------------------
% ��ռ��ع�
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
% ѵ��

P = XN_TR;
T = DN_TR;
spread = 3;         % ��ֵԽ��,���ǵĺ���ֵ�ʹ�(Ĭ��Ϊ1)
net = newrbe(XN_TR,DN_TR);
ERR1 = sim(net,XN_TR)-DN_TR;
err_mse1 = sqrt(sum(ERR1.^2)/length(ERR1))   %rmse         

%--------------------------------------------------------------------------
% �ಽԤ��

n_pr = 30;

X_ST = X_TR(n_tr-(d-1)*t:n_tr);
DN_PR = zeros(n_pr,1);
for i=1:n_pr
    XN_ST = PhaSpaRecon(X_ST,t,d);
    predict(i) = sim(net,XN_ST);
    X_ST = [X_ST(2:end);predict(i)];
end
test = X_TE(1:n_pr);
predict_y=mapminmax('reverse',predict', Xp);%����һ��
test_y=mapminmax('reverse',test', Xp);
%--------------------------------------------------------------------------
% ��ͼ

figure;
subplot(211)
plot(n_tr+1:n_tr+n_pr,test_y,'r*-',...
     n_tr+1:n_tr+n_pr,predict_y,'bo-');
title('��ʵֵ(*)��Ԥ��ֵ(o)')
subplot(212)
plot(n_tr+1:n_tr+n_pr,abs(DN_TE(end-29:end)-DN_PR'),'k'); grid;
title('Ԥ��������')

