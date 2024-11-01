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
aicTable = '/Users/land/Desktop/projectTrackProfiles/supportFiles/aicTable.csv';

%convert csv into a table.
Tshort = readtable(Tshort); 
Tlong = readtable(Tlong); 
colorProfiles = readtable(colorProfiles);
rsqTableAdj = readtable(rsqTableAdj);
rsqTableOrd = readtable(rsqTableOrd);
aicTable = readtable(aicTable); 

%============== Generate Plots ==============

%generate column of tracts of interest ids
mask = ismember(Tlong.structureID, colorProfiles{:, 1});
tractIDs = Tlong(mask, :);
tractIDs = unique(tractIDs.structureID);
rsqSimpleLin = table(tractIDs); 

%close all previous plots
close all

for t = 1:length(tractIDs)

    f = figure(t);

    %startingx, startingy, width height
    f.Position = [1000 1000 800 700];

    hold on 

    %defining variables
    Age = Tshort.Age; 
    %define sex as a categorical variable.
    Sex = categorical(Tshort.Sex); 
    yVar = Tshort.(char(tractIDs(t)));
   
    tbl = table(Age, Sex, yVar); 
    tbl(any(ismissing(tbl), 2), :) = [];

    Age = tbl.Age; 
    Sex = tbl.Sex; 
    yVar = tbl.yVar; 

    %replace all outliers with zero
    %remove outliers from yVar that is more than 3 sd from the mean
    yVar = filloutliers(yVar, 0, "mean"); 

    tbl = table(Age, Sex, yVar);

    %delete rows with missing data and yVar = 0 (outliers)
    tbl(any(ismissing(tbl), 2), :) = [];
    tbl(~yVar, :) = []; 

    %defining the line to fit the model to
    Q = 'yVar ~ Age + Sex';

    %generating the model
    mdl = fitlm(tbl, Q);

    %get appropriate RGB color for tract by indexing into colorProfiles.csv
    idx = find(strcmp(colorProfiles.NameOfTrack, char(tractIDs(t))) == 1);
    markerColor = [colorProfiles.Red(idx)/255, colorProfiles.Green(idx)/255, colorProfiles.Blue(idx)/255];

    %plotting the model
    h = plotAdjustedResponse(mdl, 'Age', 'MarkerEdgeColor', markerColor, 'MarkerFaceColor', markerColor);  
    pltLeg = legend('', '', '');
    set(pltLeg,'visible','off')

    %get data for plotting the confidence intervals and add CI to plot.
    j = array2table(cat(2, h(1).XData', h(1).YData')); j.Properties.VariableNames =  {'x', 'y'};
    mdlci = fitlm(j, 'y~x');

    clear f; 

    %======================================================================
    %Outliers

    outliers = [];
    % Examine model residuals: boxplot of raw residuals.
    figure(t + length(tractIDs)); k = figure('visible', 'off');
    m = mdlci.Residuals.Raw;
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
    m = mdlci.Robust;
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

    %plotting the model
    h = plotAdjustedResponse(mdl, 'Age', 'MarkerEdgeColor', markerColor, 'MarkerFaceColor', markerColor);  
    pltLeg = legend('', '', '');
    set(pltLeg,'visible','off')
    z = get(gca, 'children'); 
    set(0, 'DefaultFigureVisible', 'off');


    %get data for plotting the confidence intervals and add CI to plot.
    j = array2table(cat(2, h(1).XData', h(1).YData')); j.Properties.VariableNames =  {'x', 'y'};
    mdlci = fitlm(j, 'y~x');

    clf(figure(t));

    f = figure(t);
    %startingx, startingy, width height
    f.Position = [1000 1000 800 700];

    hold on 

    pci = plot(mdlci);
    set(pci, 'MarkerEdgeColor', 'white', 'MarkerFaceColor', markerColor, 'MarkerSize', 12, 'Marker', 'o')
    x = tbl.Age; y = tbl.yVar; CI = (tbl.yVar)/2; 

    %fill in confidence interval
    cbHandles = findobj(pci,'DisplayName','Confidence bounds');
    cbHandles = findobj(pci,'LineStyle', cbHandles.LineStyle, 'Color', cbHandles.Color);

    upperCBHandle = cbHandles(2,:);
    lowerCBHandle = cbHandles(1,:);
    
    xData = upperCBHandle.XData; 
    k = patch([xData xData(end:-1:1) xData(1)], [lowerCBHandle.YData upperCBHandle.YData(end:-1:1) lowerCBHandle.YData(1)], 'b');
    set(k, 'EdgeColor', 'none', 'FaceColor', [markerColor(1)*0.55  markerColor(2)*0.55 markerColor(3)*0.55], 'FaceAlpha', '0.2')

    %grab trendline and datapoints
    dataHandle = findobj(h,'DisplayName','data');
    fitHandle = findobj(h,'DisplayName','fit');
    dataHandle2 = findobj(pci,'DisplayName','Data');
    fitHandle2 = findobj(pci,'DisplayName','Fit');

    %style the trendline
    set(fitHandle2, 'Color', [markerColor(1) markerColor(2) markerColor(3)], 'LineWidth', 3)

    %w = plot(mdl, 'Marker', 'o', 'MarkerFaceColor', markerColor, 'MarkerSize', 12);
    pltLeg = legend('', '', '');
    set(fitHandle2, 'Marker', 'none')
    set(pltLeg,'visible','off')
    %set(fitHandle, 'Visible', 'off')
    %set(dataHandle, 'Visible', 'off')
    %set(h, 'Visible', 'off')
    plot(pci(1).XData, pci(1).YData, 'MarkerEdgeColor', 'white', 'MarkerFaceColor', markerColor, 'MarkerSize', 12, 'Marker', 'o', 'LineStyle', 'none')

    %delete confidence bounds border 
    delete(pci(3))
    delete(pci(4))

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

    hold off

    %adding title and color to the model
    plotTitle = {char(tractIDs(t))};
    plotTitle = strjoin(['Multiple Linear Model for', plotTitle]);
    title(plotTitle);
    xlabel('Age (years)');
    ylabel(measure);

    %add adjusted r squared and aic to table.
    rsqTableAdj.MultLin(t) = mdlci.Rsquared.Adjusted;
    rsqTableOrd.MultLin(t) = mdlci.Rsquared.Ordinary;
    aicTable.MultLin(t)= mdlci.ModelCriterion.AIC;


end

%============== Export rsqTables and aicTable as a csv ==============
%local path to save table: 
mainpath = '/Users/land/Desktop/projectTrackProfiles/supportFiles';

table_path_format_rsqTAdj = fullfile(mainpath, 'rsqTableAdj.csv');
table_path_format_rsqTOrd = fullfile(mainpath, 'rsqTableOrd.csv');
table_path_format_aicTable = fullfile(mainpath, 'aicTable.csv');

%funally, save tables
writetable(rsqTableAdj, table_path_format_rsqTAdj);
writetable(rsqTableOrd, table_path_format_rsqTOrd);
writetable(aicTable, table_path_format_aicTable);
