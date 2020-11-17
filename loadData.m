clear; close all;
dat_path = '/Users/dtakeshi/Documents/Data/VibrationExperiment';
%fname = '200710æŒ¯å‹•å®Ÿé¨“ï¼“ã??è¢«é¨“è??å°ç”°ã€?ãŸãŸãç§‹åŸ';
fname = '200710U“®ÀŒ±‚R@”íŒ±Ò¬“c@‚½‚½‚«HŒ´';
load(fullfile(dat_path,fname))
Fz = data;
Fs = unique(samplerate(:));
t = [0:length(data)-1]/Fs;
%plot(t,data)
%plot(data)

%% detect  oscillation automatically
%band-pass may not be enough - convolute with damped oscillation??

%% read Excel files 
xls_name = 'indices.xlsx';
C = readcell(fullfile(dat_path,xls_name));
idx_set = cell2mat(C(2:end,:));
n_indices =  size(idx_set,1);
%% plot
plot(t,data,'linewidth',2)
hold on
arrayfun(@(t)xline(t,'linestyle','--','linewidth',1),t(idx_set(:,1)))



%% by hand:)
% idx_st = 467581;
% idx_ed = 4.688e5;
%  idx_st = 3281090;
%  idx_ed = 3282050;
k = zeros(n_indices,1);
f = k;
figure;
for n=1:n_indices
    idx_st = idx_set(n,1);
    idx_ed = idx_set(n,2);
    [~,i_max] = max(data(idx_st:idx_ed));
    idx_st = idx_st + i_max -1;
    
    %plot(t(idx_st:idx_ed),data(idx_st:idx_ed),'o')
    X = t(idx_st:idx_ed)'-t(idx_st); Y = data(idx_st:idx_ed)';
    %Y = Y-mean(Y);

    % fitting
    init = [1, 70, 0, 30, 0, 80];
    fitfun = fittype( @(gm, ac, as, omega, c, d, t)exp(-gm*t).*(ac*cos(omega*t)...
        + as*sin(omega*t))+c*t+d, 'independent','t');
    %fitresult = fit(X, Y, fitfun, 'Lower',[0.1,0,0],'Upper',[20, 100,100]);%set lower bound for [x0 m0 m1]
    fitresult = fit(X, Y, fitfun,'start',init);%set lower bound for [x0 m0 m1]
    coefs = coeffvalues(fitresult);%[x0 m]
    % parameters
    g = 9.8;
    ra = 0.17;%need to know
    rb = 0.05;
    gamma = coefs(1);
    omega1 = coefs(4);
    M = coefs(6)/g;
    K = M*(omega1^2 + gamma^2);
    k(n) = (ra/rb)^2*K/1000; %kN/m
    f(n) = ra/rb*M*g;
    Yfit = fitresult(X);
    idx_plot = idx_st:idx_st + length(Y)-1;
    subplot(4,3,n)
    plot(idx_plot,Y,'bo')
    hold on
    plot(idx_plot,Yfit,'linewidth',2)
    %plot(fitresult, X,Y);
    str_ttl = sprintf('i=%d, k=%.2g',idx_st,k(n));
    title(str_ttl)
end
fitfun = fittype( @(ki,kd, f)(ki*kd*f)./(ki+kd*f), 'independent','f');
init = [350, 540];
fit_fk = fit(f, k, fitfun,'start',init);
f_max = ceil(max(f)/100)*100;
f_fit = [0:0.1:f_max];
k_fit = fit_fk(f_fit);
figure
plot(f,k,'o')
hold on
plot(f_fit, k_fit)
set(gca,'xlim',[0 f_max],'ylim',[0 ceil(max(k)/100)*100])
xlabel('f (N)');ylabel('k (kN/m)')
str_ttl = sprintf('k_t=%d(kN/m), k_d=%d(N/m)/N',round(fit_fk.ki),round(fit_fk.kd*1000));
title(str_ttl)

