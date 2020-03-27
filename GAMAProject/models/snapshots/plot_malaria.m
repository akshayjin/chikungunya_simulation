weeks = 0:14;

%cases /1000
no_strategy =    [2 2 2 4 4 6 8 12 12 12 12 12 12 12 12];
abs_quarantine = [2 2 4 12 20 28 36 38 38 46 46 50 50 50 50];
ess_quarantine = [2 2 6 10 14 20 26 34 34 34 34 34 34 34 34];

samplingRateIncrease = 10;
newXSamplePoints = linspace(0, length(weeks)-1, (length(weeks)-1) * samplingRateIncrease);
smoothed_no_strategy = spline(weeks, no_strategy, newXSamplePoints);
smoothed_ess_quarantine = spline(weeks, ess_quarantine, newXSamplePoints);
smoothed_abs_quarantine = spline(weeks, abs_quarantine, newXSamplePoints);

plot(newXSamplePoints,smoothed_ess_quarantine, 'b','HandleVisibility','off');
title('Malaria Epidemiology')
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