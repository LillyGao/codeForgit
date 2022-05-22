close all;
clear all;
clc
estim=xlsread('FH_128_4095estim.csv');
real=xlsread('FH_128_4095fre.csv');
estimplot=estim(500:600)/100;
realplot=real(500:600)/100;
figure
plot(0:length(estimplot)-1,estimplot,'g-o');hold on;
plot(0:length(realplot)-1,realplot,'r-+')
xlabel('Time series')
ylabel('Frequency')
legend('Real frequency','Estimation frequency')
% test_error = real/100 - estim/100;
% test_mse =  sum(test_error.^2) / length(test_error );
% test_rmse =  sqrt(sum(test_error.^2)/ length(test_error ));% rmse=sqrt((sum((a-b).^2))./n);
% ylabel('Frequency/MHz'); xlabel('hop');
% legend('Real value','Estimation value')