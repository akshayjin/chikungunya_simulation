weeks = 0:14;

%cases /1000
no_strategy = [2 2 2 2 4 6 8 10 12 14 14 16 16 16 16];
s1 = [2 2 2 4 4 6 6 6 6 6 6 6 6 6 6]; % stopped at 5th week
s2 = [2 2 2 4 6 6 8 8 8 8 8 8 8 8 8]; % stopped at 7th week
abs_quarantine = [2 4 16 24 26 26 26 26 26 26 26 26 26 26 26];
ess_quarantine = [2 4 18 24 26 28 28 28 32 32 36 40 42 42 42 ];

samplingRateIncrease = 10;
newXSamplePoints = linspace(0, length(weeks)-1, (length(weeks)-1) * samplingRateIncrease);
smoothed_no_strategy = spline(weeks, no_strategy, newXSamplePoints);
smoothed_s1 = spline(weeks, s1, newXSamplePoints);
smoothed_s2 = spline(weeks, s2, newXSamplePoints);
smoothed_ess_quarantine = spline(weeks, ess_quarantine, newXSamplePoints);
smoothed_abs_quarantine = spline(weeks, abs_quarantine, newXSamplePoints);


plot(newXSamplePoints, smoothed_no_strategy, 'r','HandleVisibility','off');
hold on
scatter(weeks, no_strategy, 'or', 'DisplayName', 'No Lockdown');

plot(newXSamplePoints, smoothed_abs_quarantine, 'm','HandleVisibility','off');
scatter(weeks, abs_quarantine, 'dm', 'DisplayName', 'Complete Lockdown');

plot(newXSamplePoints,smoothed_ess_quarantine, 'b','HandleVisibility','off');
scatter(weeks, ess_quarantine, 'sb', 'DisplayName','Flexible Lockdown');

title('Chikungunya Epidemiology')
xlabel('Epidemiological Week')
ylabel('Number of Cumulative Cases (/1000)')
hold off
legend