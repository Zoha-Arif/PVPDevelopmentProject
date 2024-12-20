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
aicTable = '/Users/land/Desktop/projectTrackProfiles/supportFiles/aicTable.csv';

%convert csv into a table.
Tshort = readtable(Tshort); 
Tlong = readtable(Tlong); 
colorProfiles = readtable(colorProfiles);
rsqTableAdj = readtable(rsqTableAdj);
rsqTableOrd = readtable(rsqTableOrd);
inflecTable = readtable(inflecTable);
aicTable = readtable(aicTable); 

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

    f = figure(t);

    %startingx, startingy, width height
    f.Position = [1000 1000 800 700];
    
    hold on 
    
%     Tshort(any(Tshort.anterioFrontalCC == 0,2), :) = [];

    %plotting a nonlinear aggression model 
    Age = Tshort.Age; 
    yVar = Tshort.(char(tractIDs(t)));
   
    tbl = table(Age, yVar); 
    tbl(any(ismissing(tbl), 2), :) = [];

    Age = tbl.Age; 
    yVar = tbl.yVar; 

    %replace all outliers with zero
    %remove outliers from yVar that is more than 3 sd from the mean
    %yVar = filloutliers(yVar, NaN, "mean"); 

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

    clear f; 

    %======================================================================
    %Outliers

    outliers = [];
    % Examine model residuals: boxplot of raw residuals.
    figure(t + length(tractIDs)); k = figure('visible', 'off');
    m = mdl.Residuals.Raw;
    e = eps(max(m(:)));
    boxplot(m)
    % ylabel('Raw Residuals')
    % Suppress figure display.
    set(gcf,'Visible','off');              
    set(0,'DefaultFigureVisible','off');
%​
    % Get indices of the outliers.
    h1 = flipud(findobj(gcf,'tag','Outliers')); % flip order of handles
    for jj = 1 : length( h1 )
        x =  get( h1(jj), 'XData' );
        y =  get( h1(jj), 'YData' );
        for ii = 1 : length( x )
            if not( isnan( x(ii) ) )
                ix = find( abs( m(:,jj)-y(ii) ) < e );
                outliers = cat(1, outliers, ix);
                %                 text( x(ii), y(ii), sprintf( '\\leftarrowY%02d', ix ) )
            end
        end
    end
%​
    k = gcf; close(k);
%​
    % Examine robust weights: boxplot of robust weights.
    figure(t + length(tractIDs) + 1); k = figure('visible', 'off');
    m = mdl.Robust;
    e = eps(max(m(:)));
    boxplot(m);
    % ylabel('Robust Beta-Weights')
    % Suppress figure display.
    set(gcf, 'Visible', 'off');              
    set(0, 'DefaultFigureVisible', 'off');
%​
    % Get indices of the outliers.
    h1 = flipud(findobj(gcf,'tag','Outliers')); % flip order of handles
    for jj = 1 : length( h1 )
        x =  get( h1(jj), 'XData' );
        y =  get( h1(jj), 'YData' );
        for ii = 1 : length( x )
            if not( isnan( x(ii) ) )
                ix = find( abs( m(:,jj)-y(ii) ) < e );
                outliers = cat(1, outliers, ix);
                %                 text( x(ii), y(ii), sprintf( '\\leftarrowY%02d', ix ) )
            end
        end
    end
%​
    outliers = sort(outliers);
%​
    k = gcf; close(k);
%​
    k = figure('visible', 'on');
    set(gcf, 'Visible', 'off');              
    set(0, 'DefaultFigureVisible', 'off');
%

    %======================================================================

    clf;

    %Remove outliers
    tbl(outliers, :) = []; 

    %recalculate the model

    %generating the model
    mdl = fitlm(tbl, Q);

    clf(figure(t));

    f = figure(t);
    %startingx, startingy, width height
    f.Position = [1000 1000 800 700];

    hold on 

    %plotting the model
    h = plot(mdl, 'Marker', 'o', 'MarkerEdgeColor', 'white', 'MarkerFaceColor', markerColor, 'MarkerSize', 12);
    
    %grab trendline and datapoints
    dataHandle = findobj(h,'DisplayName','Data');
    fitHandle = findobj(h,'DisplayName','Fit');

    %fill in confidence interval
    cbHandles = findobj(h,'DisplayName','Confidence bounds');
    cbHandles = findobj(h,'LineStyle', cbHandles.LineStyle, 'Color', cbHandles.Color);

    upperCBHandle = cbHandles(2,:);
    lowerCBHandle = cbHandles(1,:);
    
    xData = upperCBHandle.XData; 
    k = patch([xData xData(end:-1:1) xData(1)], [lowerCBHandle.YData upperCBHandle.YData(end:-1:1) lowerCBHandle.YData(1)], 'b');
    set(k, 'EdgeColor', 'none', 'FaceColor', [markerColor(1)*0.55  markerColor(2)*0.55 markerColor(3)*0.55], 'FaceAlpha', '0.2')

    %style the trendline
    set(fitHandle, 'Color', [markerColor(1) markerColor(2) markerColor(3)], 'LineWidth', 3)

    w = plot(mdl, 'Marker', 'o', 'MarkerEdgeColor', 'white', 'MarkerFaceColor', markerColor, 'MarkerSize', 12);
    pltLeg = legend('', '', '');
    set(pltLeg,'visible','off')
    fitHandle2 = findobj(w,'DisplayName','Fit');
    set(fitHandle2, 'Visible', 'off')

    %delete confidence bounds border 
    delete(h(3))
    delete(h(4))
    delete(w(3))
    delete(w(4))

    %===========================================================================
    % Set up plot and measure-specific details.
    capsize = 0;
    marker = 'o';
    linewidth = 1.5;
    linestyle = 'none';
    markersize = 100;
    xtickvalues = [1 2 3 4];
    xlim_lo = min(xtickvalues)-0.5; xlim_hi = max(xtickvalues)+0.5;
    fontname = 'Arial';
    fontsize = 50;
    fontangle = 'italic';
    yticklength = 0;
    xticklength = 0.02;

    % xaxis
    xax = get(gca, 'xaxis');
    xax.TickDirection = 'out';
    xax.TickLength = [xticklength xticklength];
    set(gca, 'XLim', [3 22], 'XTick', [3 12.5 22]);
    xax.FontName = fontname;
    xax.FontSize = fontsize;

    % yaxis
    yax = get(gca,'yaxis');
    yax.TickDirection = 'out';
    yax.TickLength = [yticklength yticklength];
    set(gca, 'YLim', [0.3 0.6], 'YTick', [0.3 0.45 0.6]);
    yax.FontName = fontname;
    yax.FontSize = fontsize;
    yax.FontAngle = fontangle;

    %change figure background to white
    set(gcf, 'color', 'w')

    %===========================================================================

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
    aicTable.SimpleNonLin(t)= mdl.ModelCriterion.AIC;

    %======= Calculating Inflection & Fastest Rate of Change =======

    x = unique(mdl.Variables.Age);  
    y = predict(mdl, x);

    %issue: interp1 wants unique x values, but you can't because the age is
    %the same for some subjects. one solution would be to modify each x value so that they are v slightly different! 

    %Protect again X being and Y being NAN
    %nanx = isnan(x(:,1));
    %sum(x(nanx));

    ydt = detrend(y,1);                                     % Detrend 'y' To Facilitate Analysis
    dydx = gradient(ydt) ./ gradient(x);                   % Calculate Numerical Derivative

    ratetbl = table(x, y);                                 %save unordered derivatives in ratetbl
    ratetbl.dydx = dydx; 
    ratetbl = ratetbl(~any(isinf(ratetbl.dydx), 2), :);
    %ratetbl.dydx = abs(ratetbl.dydx);                      %save absolute value of derivatives

    ratetbl = unique(ratetbl, 'rows');
 
    ratetbl = sortrows(ratetbl, 'dydx');                                      %sort derivatives 
    dydx = ratetbl.dydx; 

    [maxdydx,idxmax] = max(dydx);                           % Interpolation Index Lower Limit
    [mindydx,idxmin] = min(dydx);                           % Interpolation Index Upper Limit
    idxrng = idxmin : idxmax;
    inflptx = interp1(dydx(idxrng), ratetbl.x(idxrng), 0, 'linear');           % Find Inflection Point X-Value
    inflpty = interp1(ratetbl.x, ratetbl.y, inflptx, 'linear');                        % Find Inflection Point Y-Value
    
    f(1) = plot(inflptx, inflpty, 's', 'MarkerEdgeColor', 'white', 'MarkerFaceColor', 'r', ...
        'MarkerSize', 25, 'DisplayName','Inflection Point');

    %calculating fastest rate of change by finding maximum dy/dx in
    %magnitude
    [~, fastestRate] = max(ratetbl.dydx); 
    fr = ratetbl(fastestRate, :);

    f(2) = plot(fr.x(1), fr.y(1), '>', 'MarkerEdgeColor', 'white', 'MarkerFaceColor', 'r', ...
        'MarkerSize', 25, 'DisplayName','Fastest Rate of Change');
   
    %legend: 
    %lgd = legend(f, {"Inflection Point","Fastest Rate of Change"});
    %lgd.FontName = 'Arial';
    %lgd.FontSize = 18;
    %legend box off;
    %pbaspect([1 1 1]);

    hold off

     %add adjusted inflection point and fastest rate to table.
    inflecTable.SimpleNonLinInflecX(t) = inflptx; 
    inflecTable.SimpleNonLinInflecY(t) = inflpty; 
    inflecTable.SimpleNonLinFastRateX(t) = fr.x(1); 
    inflecTable.SimpleNonLinFastRateY(t) = fr.y(1); 

end



%============== Export rsqTable as a csv ==============
%local path to save table: 
mainpath = '/Users/land/Desktop/projectTrackProfiles/supportFiles';

table_path_format_rsqTAdj = fullfile(mainpath, 'rsqTableAdj.csv');
table_path_format_rsqTOrd = fullfile(mainpath, 'rsqTableOrd.csv');
table_path_format_inflecT = fullfile(mainpath, 'inflecTable.csv');
table_path_format_aicTable = fullfile(mainpath, 'aicTable.csv');

%funally, save tables
writetable(rsqTableAdj, table_path_format_rsqTAdj);
writetable(rsqTableOrd, table_path_format_rsqTOrd);
writetable(inflecTable, table_path_format_inflecT);
writetable(aicTable, table_path_format_aicTable);
