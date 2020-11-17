clear; close all;
dat_path = '/Users/dtakeshi/Documents/Data/VibrationExperiment';
%fname = '200710æŒ¯å‹•å®Ÿé¨“ï¼“ã??è¢«é¨“è??å°ç”°ã€?ãŸãŸãç§‹åŸ';
fname = '200710U“®ÀŒ±‚R@”íŒ±Ò¬“c@‚½‚½‚«HŒ´';
load(fullfile(dat_path,fname));
[t_set, Fz_set] = detection(data, datastart, dataend,samplerate);
hasData = ~cellfun(@isempty,Fz_set);
Fz_set = Fz_set(hasData);
t_set = t_set(hasData);
%offset time
%t_set_fit = cellfun(@(t)t-t(1),t_set{1},'unif',0) 
t_set_fit = cellfun(@(s)cellfun(@(t)t-t(1),s,'unif',0),t_set,'unif',0);


n_weights = length(Fz_set);
k = cell(n_weights,1);
f = k;
figure;
%for n=1:n_weights
for n=1:5%fitting does'nt work well for n=6&7
    dat_set = Fz_set{n}
    %idx_st = idx_set(n,1);
    %idx_ed = idx_set(n,2);
    %[~,i_max] = max(data(idx_st:idx_ed));
    %idx_st = idx_st + i_max -1;
    
    %plot(t(idx_st:idx_ed),data(idx_st:idx_ed),'o')
    %X = t(idx_st:idx_ed)'-t(idx_st); Y = data(idx_st:idx_ed)';
    %Y = Y-mean(Y);
    X = t_set_fit{n}; Y = Fz_set{n};

    % fitting
    init = [1, 70, 0, 30, 0, 80];
    fitfun = fittype( @(gm, ac, as, omega, c, d, t)exp(-gm*t).*(ac*cos(omega*t)...
        + as*sin(omega*t))+c*t+d, 'independent','t');
    %fitresult = fit(X, Y, fitfun, 'Lower',[0.1,0,0],'Upper',[20, 100,100]);%set lower bound for [x0 m0 m1]
    
%     fitresult = cellfun(@(X,Y)fit(X, Y, fitfun,'start',init,...
%         'Lower',[0.1,0,0,0,-20,0],'Upper',[20, 200,200,50,20,200]),X,Y,'unif',0);%set lower bound for [x0 m0 m1]
    fitresult = cellfun(@(X,Y)fit(X, Y, fitfun,'start',init),X,Y,'unif',0);
    Yfit = cellfun(@(r,x)r(x),fitresult,X,'unif',0);
    coefs = cellfun(@coeffvalues,fitresult,'unif',0);%[x0 m]
    [k{n},f{n}] = cellfun(@fitcoefs2params,coefs);
   

    figure;
    for nd=1:length(Yfit)
        subplot(2,3,nd)
        plot(X{nd},Y{nd},'bo')
        hold on
        plot(X{nd},Yfit{nd},'linewidth',2)
%     %plot(fitresult, X,Y);
        str_ttl = sprintf('k=%.2g',k{n}(nd));
    title(str_ttl)
    end
end
f_vec = cell2mat(f');
k_vec = cell2mat(k');
fitfun = fittype( @(ki,kd, f)(ki*kd*f)./(ki+kd*f), 'independent','f');
init = [350, 540];
fit_fk = fit(f_vec', k_vec', fitfun,'start',init);
f_max = ceil(max(f_vec)/100)*100;
f_fit = [0:0.1:f_max];
k_fit = fit_fk(f_fit);
figure
plot(f_vec,k_vec,'o')
hold on
plot(f_fit, k_fit)
set(gca,'xlim',[0 f_max],'ylim',[0 ceil(max(k_vec)/100)*100])
xlabel('f (N)');ylabel('k (kN/m)')
str_ttl = sprintf('k_t=%d(kN/m), k_d=%d(N/m)/N',round(fit_fk.ki),round(fit_fk.kd*1000));
title(str_ttl)

