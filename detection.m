function [t_set, Fz_set] = detection(data, datastart, dataend,samplerate)
    isDebug = false;
    if nargin == 0
        %clear; 
        close all;
        isDebug = false;
        dat_path = '/Users/dtakeshi/Documents/Data/VibrationExperiment';
        %fname = '200710æŒ¯å‹•å®Ÿé¨“ï¼“ã??è¢«é¨“è??å°ç”°ã€?ãŸãŸãç§‹åŽŸ';
        fname = '200710U“®ŽÀŒ±‚R@”íŒ±ŽÒ¬“c@‚½‚½‚«HŒ´';
        load(fullfile(dat_path,fname))
    end
    rawFz = 9;%channel number
    n_dat = size(datastart,2);
    idx_peak_set = cell(n_dat,1);
    Fz_set =cell(n_dat,1);
    t_set = Fz_set;
    for colFz = 1:n_dat
    %for colFz = 9
        Fz =data(datastart(rawFz,colFz):dataend(rawFz,colFz));
        Fs = unique(samplerate(:));
        t_Fz = [0:length(Fz)-1]/Fs;
        Fz_hp = highpass(Fz,2,Fs);
        %Fz_hp = bandpass(Fz,[3 10],Fs);
        %% extract peaks
        h_peak = max(Fz_hp);
        [pk_val, pk_idx]=  findpeaks(Fz_hp,'MinPeakHeight',30,'MinPeakDistance',1000);
        %findpeaks(Fz_hp,'MinPeakHeight',10,'MinPeakDistance',2000);
        t_peak = t_Fz(pk_idx);
        Fz_peak = Fz(pk_idx);
        dt_peak = diff(t_peak);
        idx_dt_real = find(dt_peak > 1 & dt_peak < 5);
        idx_peak_real=[];
        % choose the right peaks - might need more work
        if length(idx_dt_real) >=4%assumig 5 trials are done
            idx_dt_real = idx_dt_real(end-3:end);
            idx_peak_real = pk_idx([idx_dt_real idx_dt_real(end)+1]);
        end
        t_peak = t_Fz(idx_peak_real);
        Fz_peak = Fz(idx_peak_real);
        idx_peak_set{colFz}=idx_peak_real;
        % cut data into trials
        Fz_set{colFz} = arrayfun(@(i)Fz(i:i+1500)',idx_peak_real,'unif',0);
        t_set{colFz} = arrayfun(@(i)t_Fz(i:i+1500)',idx_peak_real,'unif',0);
        % debugging purpose
        if isDebug == true
            figure;
            plot(t_Fz, Fz)
            hold on
            plot(t_peak, Fz_peak,'v') 
            if isempty(idx_peak_real)
                title('No signal detected')
            end
        end
    end

%t_tmplt = [0:5000]/Fs;
% p_tmplt=[2.6 100 0 20 0 120];
% tmplt = dampedOsci(p_tmplt,t_tmplt);
% findsignal(Fz,tmplt,'MaxNumSegments',8)

% p_tmplt=[2.6 100 0 20 0 0];
% tmplt = dampedOsci(p_tmplt,t_tmplt);
% findsignal(Fz_hp,tmplt,'MaxNumSegments',5)
end



