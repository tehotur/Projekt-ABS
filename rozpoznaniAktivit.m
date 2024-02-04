function classADL = rozpoznaniAktivit(D)

% Rozdělení na osy x,y a z
x = D(:,1);
y = D(:,2);
z = D(:,3);
% Odečtění stejnosměrné složky
x1 = x - mean(x);
y1 = y - mean(y);
z1 = z - mean(z);
% Spočítání průchodu signálu 0 pro hodnoty y1 > ±0.02
y_polarity_changes = 0;
for j = 2:length(y1)
    if abs(y1(j)) > 0.02
        if sign(y1(j)) ~= sign(y1(j-1))
            y_polarity_changes = y_polarity_changes + 1;
        end
    end
end
% Nalezení maximální frekvence ve spektru pro y1
Fs = 200;
X = fft(y1);
X_one_sided = abs(X(1:floor(length(X)/2)+1));
f = (0:length(X_one_sided)-1)*Fs/length(y1);
[pks, loks] = findpeaks(X_one_sided);
[~, max_idx] = max(pks);
freq_of_max_peak = f(loks(max_idx));


if y_polarity_changes < 25 || freq_of_max_peak < 0.7  % pády, lehnutí, jump
    
    % Použití filtrace pro y1
    fc = 2; % frekvence řezu
    order = 3; % řád filtru
    % Vytvoření filtru
    [b,a] = butter(order, fc/(Fs/2), 'low');
    % Filtrování signálu
    y_filtered = filtfilt(b, a, y1);
    % Spočítání průchodu 0 pro filtrovaný signál
    yf_polar_changes = 0;
    for n = 2:length(y_filtered)
        if sign(y_filtered(n)) ~= sign(y_filtered(n-1))
            yf_polar_changes = yf_polar_changes + 1;
        end
    end

    % Průchody 0 u filtrovaného signálu a velikost maxima u y1
    if yf_polar_changes > 6 && max(y1) > 2
        classADL = 3; % Jump
    
    % Pády a lehnutí
    elseif yf_polar_changes < 6
        % Absolutní hodnota maxima x1
        [max_x, ~] = max(abs(x1));
        % Maximum z1.^2
        [max_z, ~] = max(z1.^2);
        % Sumy pozitivních a negativních hodnot na začátku x1 a y1
        num_positive_x = sum(x1(1:100) >= 0);
        num_negative_x = sum(x1(1:100) < 0);
        num_positive_y = sum(y1(1:100) >= 0);
        num_negative_y = sum(y1(1:100) < 0);
        % Maxima a minima x1
        mmx = max(x1);
        mmi = min(x1)*-1;
        minn = min(x1);
        % Výpočet rozdílu maxim a minim x1
        difmm = abs(mmx-mmi);
        difmm2 = abs(minn-mmx);
        if num_positive_y > num_negative_y && num_positive_x < num_negative_x
            classADL = 6; % FF - Pád dopředu
        elseif max_x > 3.5 && max_z > 1.5 && difmm > 3
            classADL = 8; % FB - Pád dozadu
        elseif x1(2) > 0 && x1(end) < 0 && difmm2 < 5
            classADL = 9; % LD - Lehnutí
        elseif max_z > 3
            classADL = 7; % FS - Pád do boku    
        else
            classADL = 10; % OT
        end

    else
        classADL = 10; % OT
    end
    
   
elseif y_polarity_changes > 25 || freq_of_max_peak > 0.7  % chůze,běh
   
   % Spojení os x1,y1,z1
   xyz = sqrt(x1.^2 + y1.^2 + z1.^2);
   % Nalezení píků
   [pcs, ~] = findpeaks(xyz);
   % Spočítání píků větší než 2
   num_peaks = sum(pcs > 2);

   if num_peaks >= 8
       classADL = 2; % Běh

   elseif num_peaks < 8
       % Filtrace xyz
       fc = 0.5; % frekvence řezu
       order = 2; % řád filtru
       % Vytvoření filtru
       [b1,a1] = butter(order, fc/(Fs/2), 'low');
       s_filtered = filtfilt(b1, a1, xyz);
       % Vyhlazení filtrovaného signálu
       window_size = 1000;
       smoothed_signal = movmean(s_filtered, window_size);
       % Nalezení píků ve vyhlazeném signálu
       [peakss, ~] = findpeaks(smoothed_signal);
       if length(peakss) >= 2
           % Nalezení vzdálenosti mezi píky ve vyhlazeném signálu
           [~, l] = findpeaks(smoothed_signal, 'SortStr', 'descend', 'NPeaks', 2);
           distance = abs(diff(l));
           % Oříznutí druhé poloviny z1
           z2 = z1(round(length(z1)/2):end);
           % Umocnění z1
           z2 = z2.^2;
           % Použití filtrace pro z2
           f = 20; % frekvence řezu
           ord = 1; % řád filtru
           % Vytvoření filtru
           [b,a] = butter(ord, f/(Fs/2), 'low');
           % Filtrování signálu
           z_filtered = filtfilt(b, a, z2); 
           [pc, ~] = findpeaks(z_filtered);
           % Spočítání píků větší než 0.25
           nm_peaks = sum(pc > 0.25);
           if distance > 2000 && nm_peaks > 2
               classADL = 4; % Chůze dolů po schodech
           elseif distance > 2000 && nm_peaks < 2
               classADL = 5; % Chůze nahoru po schodech
           else
               classADL = 1; % Chůze
           end
       else
           classADL = 1; % Chůze
       end
   else
       classADL = 10; % OT
   end


else
    classADL = 10; % OT
end

end
