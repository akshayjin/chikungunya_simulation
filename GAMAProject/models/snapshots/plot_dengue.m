weeks = 0:14;

%cases /1000
no_strategy =    [2 2 4 4 8 12 14 14 14 16 18 20 20 20 20];
abs_quarantine = [2 2 4 8 18 18 18 18 18 24 24 26 28 28 28];
ess_quarantine = [2 2 4 6 14 16 18 18 18 22 22 22 22 22 22];

samplingRateIncrease = 10;
newXSamplePoints = linspace(0, length(weeks)-1, (length(weeks)-1) * samplingRateIncrease);
smoothed_no_strategy = spline(weeks, no_strategy, newXSamplePoints);
smoothed_ess_quarantine = spline(weeks, ess_quarantine, newXSamplePoints);
smoothed_abs_quarantine = spline(weeks, abs_quarantine, newXSamplePoints);

plot(newXSamplePoints,smoothed_ess_quarantine, 'b','HandleVisibility','off');
title('Dengue Epidemiology')
xlabel('Epidemiological Week')
ylabel('Number of Cumulative Cases (/1000)')

hold on
scatter(weeks, ess_quarantine, 'sb', 'DisplayName','Quarantine(+Essential Services)');

plot(newXSamplePoints, smoothed_no_strategy, 'r','HandleVisibility','off');
scatter(weeks, no_strategy, 'or', 'DisplayName', 'No Strategy');

plot(newXSamplePoints, smoothed_abs_quarantine, 'm','HandleVisibility','off');
scatter(weeks, abs_quarantine, 'dm', 'DisplayName', 'Absolute Qurantine');

hold off
legend