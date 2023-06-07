%redirecting folder to correct path. clear.
clear all; clc;

%define measure
measure = 'fa';

%insert local path of Tshort.csv and Tlong.csv file
Tshort = '/Users/land/Desktop/projectTrackProfiles/supportFiles/Tshort.csv';
Tlong = '/Users/land/Desktop/projectTrackProfiles/supportFiles/Tlong.csv';
colorProfiles = '/Users/land/Desktop/projectTrackProfiles/supportFiles/colorProfiles.csv';
rsqTableAdj = '/Users/land/Desktop/projectTrackProfiles/supportFiles/rsqTableAdj.csv';
rsqTableOrd = '/Users/land/Desktop/projectTrackProfiles/supportFiles/rsqTableOrd.csv';
inflecTable = '/Users/land/Desktop/projectTrackProfiles/supportFiles/inflecTable.csv';

%convert csv into a table.
Tshort = readtable(Tshort); 
Tlong = readtable(Tlong); 
colorProfiles = readtable(colorProfiles);
rsqTableAdj = readtable(rsqTableAdj);
rsqTableOrd = readtable(rsqTableOrd);
inflecTable = readtable(inflecTable);

%============== Generate Plots ==============

%generate column of tracts of interest ids
mask = ismember(Tlong.structureID, colorProfiles{:, 1});
tractIDs = Tlong(mask, :);
tractIDs = unique(tractIDs.structureID);
rsqSimpleLin = table(tractIDs); 
inflectionPt = table(tractIDs);

%close all previous plots
close all

for t = 1:length(tractIDs)

    figure(t)
    
    hold on 
    
    %plotting a nonlinear aggression model 
    Age = Tshort.Age; 
    yVar = Tshort.(char(tractIDs(t)));
   
    tbl = table(Age, yVar); 
    tbl(any(ismissing(tbl), 2), :) = [];

    Age = tbl.Age; 
    yVar = tbl.yVar; 

    %replace all outliers with zero
    %remove outliers from yVar that is more than 3 sd from the mean
    yVar = filloutliers(yVar, 0, "mean"); 

    tbl = table(Age, yVar); 

    %delete rows with missing data and yVar = 0 (outliers)
    tbl(any(ismissing(tbl), 2), :) = [];
    tbl(~yVar, :) = []; 

    %%defining the line to fit the model to
    Q = 'yVar ~ Age^2';

    %generating the model
    mdl = fitlm(tbl, Q);

    %get appropriate RGB color for tract by indexing into colorProfiles.csv
    idx = find(strcmp(colorProfiles.NameOfTrack, char(tractIDs(t))) == 1);
    markerColor = [colorProfiles.Red(idx)/255, colorProfiles.Green(idx)/255, colorProfiles.Blue(idx)/255];

    %plotting the model
    plot(mdl, 'Marker', 'o', 'MarkerEdgeColor', markerColor, 'MarkerFaceColor', markerColor)
    legend('', 'Fit', 'Confidence Intervals');

    %adding title and color to the model
    plotTitle = {char(tractIDs(t))};
    plotTitle = strjoin(['Simple Nonlinear Model for', plotTitle]);
    title(plotTitle);
    xlabel('Age (years)');
    ylabel(measure);

    %set scale of y-axis
    ylim([0.3 0.6])

    %add adjusted r squared to table.
    rsqTableAdj.SimpleNonLin(t) = mdl.Rsquared.Adjusted;
    rsqTableOrd.SimpleNonLin(t) = mdl.Rsquared.Ordinary;

    %======= Calculating Inflection & Fastest Rate of Change =======
    y = predict(mdl, Age);
    x = Age; 
    ydt = detrend(y,1);                                     % Detrend 'y' To Facilitate Analysis
    framelen = 101;                                         % Choose Appropriate Value
    dydx = gradient(ydt) ./ gradient(x);                   % Calculate Numerical Derivative

    ratetbl = table(x, y);                                 %save unordered derivatives in ratetbl
    ratetbl.dydx = dydx; 
    ratetbl.dydx = abs(ratetbl.dydx);                      %save absolute value of derivatives

    dydx = sort(dydx);                                      %sort derivatives 

    [maxdydx,idxmax] = max(dydx);                           % Interpolation Index Lower Limit
    [mindydx,idxmin] = min(dydx);                           % Interpolation Index Upper Limit
    idxrng = idxmin : idxmax;
    inflptx = interp1(dydx(idxrng), x(idxrng), 0);           % Find Inflection Point X-Value
    inflpty = interp1(x, y, inflptx);                        % Find Inflection Point Y-Value
    
    plot(inflptx, inflpty, 's', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r', ...
        'MarkerSize', 7, 'DisplayName','Inflection Point')

    %calculating fastest rate of change by finding maximum dy/dx in
    %magnitude
    [~, fastestRate] = max(ratetbl.dydx); 
    fr = ratetbl(fastestRate, :);

    plot(fr.x(1), fr.y(1), 's', 'MarkerEdgeColor', 'g', 'MarkerFaceColor', 'g', ...
        'MarkerSize', 7, 'DisplayName','Fastest Rate of Change')

    hold off

     %add adjusted inflection point and fastest rate to table.
    inflecTable.SimpleInflecX(t) = inflptx; 
    inflecTable.SimpleInflecY(t) = inflpty; 
    inflecTable.SimpleFastRateX(t) = fr.x(1); 
    inflecTable.SimpleFastRateY(t) = fr.y(1); 

end



%============== Export rsqTable as a csv ==============
%local path to save table: 
mainpath = '/Users/land/Desktop/projectTrackProfiles/supportFiles';

table_path_format_rsqTAdj = fullfile(mainpath, 'rsqTableAdj.csv');
table_path_format_rsqTOrd = fullfile(mainpath, 'rsqTableOrd.csv');
table_path_format_inflecT = fullfile(mainpath, 'inflecTable.csv');

%funally, save tables
writetable(rsqTableAdj, table_path_format_rsqTAdj);
writetable(rsqTableOrd, table_path_format_rsqTOrd);
writetable(inflecTable, table_path_format_inflecT);