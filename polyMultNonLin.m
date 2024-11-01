%Redirecting folder to correct path. clear.
clear all; clc;

%Define measure
measure = 'fa';

%Insert local path of Tshort.csv and Tlong.csv file
Tshort = '/Users/land/Desktop/projectTrackProfiles/supportFiles/Tshort.csv';
Tlong = '/Users/land/Desktop/projectTrackProfiles/supportFiles/Tlong.csv';
colorProfiles = '/Users/land/Desktop/projectTrackProfiles/supportFiles/colorProfiles.csv';
rsqTableAdj = '/Users/land/Desktop/projectTrackProfiles/supportFiles/rsqTableAdj.csv';
rsqTableOrd = '/Users/land/Desktop/projectTrackProfiles/supportFiles/rsqTableOrd.csv';
inflecTable = '/Users/land/Desktop/projectTrackProfiles/supportFiles/inflecTable.csv';
aicTable = '/Users/land/Desktop/projectTrackProfiles/supportFiles/aicTable.csv';
anovaBootTable = '/Users/land/Desktop/projectTrackProfiles/supportFiles/anovaBootTable.csv';

%Convert csv into a table.
Tshort = readtable(Tshort); 
Tlong = readtable(Tlong); 
colorProfiles = readtable(colorProfiles);
rsqTableAdj = readtable(rsqTableAdj);
rsqTableOrd = readtable(rsqTableOrd);
inflecTable = readtable(inflecTable);
aicTable = readtable(aicTable); 
anovaBootTable = readtable(anovaBootTable); 
anovaBootTable.Hemisphere = categorical(anovaBootTable.Hemisphere);
anovaBootTable.Tract = categorical(anovaBootTable.Tract);

%For ANOVA table
lastRow = 1; 

%============== Generate Plots ==============

%Generate column of tracts of interest ids
mask = ismember(Tlong.structureID, colorProfiles{:, 1});
tractIDs = Tlong(mask, :);
tractIDs = unique(tractIDs.structureID);
rsqSimpleLin = table(tractIDs); 

%Close all previous plots
close all

for t = 1:length(tractIDs)

    f = figure(t);

    %f.Position = [startingx startingy width height];
    f.Position = [1000 1000 800 700];

    hold on 

    %Defining model variables
    Age = Tshort.Age; 
    %define sex as a categorical variable.
    Sex = categorical(Tshort.Sex); 
    yVar = Tshort.(char(tractIDs(t)));
   
    %Create table
    tbl = table(Age, Sex, yVar); 
    
    %Remove any rows with missing data (NaN or empty character) from tbl 
    tbl(any(ismissing(tbl), 2), :) = [];

    %Assign Age, Sex, and yVar to new tbl columns with removed rows
    %that had missing values
    Age = tbl.Age; 
    Sex = tbl.Sex; 
    yVar = tbl.yVar; 

    %======================================================================
    % Outliers Identification 
    
    %Replace all outliers with zero
    %Removes outliers from yVar that is more than 3 sd from the mean
    yVar = filloutliers(yVar, 0, "mean"); 

    %Delete rows with outliers (identified because all outliers have been
    %replaced with zero)
    tbl(any(ismissing(tbl), 2), :) = [];
    tbl(~yVar, :) = []; 

    %Define the line to fit the model to
    Q = 'yVar ~ Age^2 + Sex';
 
    %Generating the model
    mdl = fitlm(tbl, Q);
    
    %Get appropriate RGB color for tract by indexing into colorProfiles.csv
    idx = find(strcmp(colorProfiles.NameOfTrack, char(tractIDs(t))) == 1);
    markerColor = [colorProfiles.Red(idx)/255, colorProfiles.Green(idx)/255, colorProfiles.Blue(idx)/255];

    %Plotting the model
    h = plotAdjustedResponse(mdl, 'Age', 'MarkerFaceColor', markerColor); 
    
    %Get data for plotting the confidence intervals and add CI to plot.
    j = array2table(cat(2, h(1).XData', h(1).YData')); j.Properties.VariableNames =  {'x', 'y'};
    mdlci = fitlm(j, 'y~x^2');

    clear f; 

    outliers = [];

    %Examine model residuals: boxplot of raw residuals.
    figure(t + length(tractIDs)); k = figure('visible', 'off');
    m = mdlci.Residuals.Raw;
    e = eps(max(m(:)));
    boxplot(m)
    
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

    clf;

    %Remove outliers
    tbl(outliers, :) = []; 
  
    %======================================================================
    %Recalculate the model & confidence intervals without outliers

    %Generating the new model
    mdl = fitlm(tbl, Q);

    %Plotting the new model
    h = plotAdjustedResponse(mdl, 'Age', 'MarkerEdgeColor', markerColor, 'MarkerFaceColor', markerColor);  
    pltLeg = legend('', '', '');
    set(pltLeg,'visible','off')
    z = get(gca, 'children'); 
    set(0, 'DefaultFigureVisible', 'off');


    %Get data for plotting the confidence intervals and add CI to plot.
    j = array2table(cat(2, h(1).XData', h(1).YData')); j.Properties.VariableNames =  {'x', 'y'};
    mdlci = fitlm(j, 'y~x^2');

    clf(figure(t));

    f = figure(t);
    %%f.Position = [startingx startingy width height];
    f.Position = [1000 1000 800 700];

    hold on 

    %Plot the model
    pci = plot(mdlci);
    set(pci, 'MarkerEdgeColor', 'white', 'MarkerFaceColor', markerColor, 'MarkerSize', 12, 'Marker', 'o')
    x = tbl.Age; y = tbl.yVar; CI = (tbl.yVar)/2; 
    
    %Fill in confidence interval
    cbHandles = findobj(pci,'DisplayName','Confidence bounds');
    cbHandles = findobj(pci,'LineStyle', cbHandles.LineStyle, 'Color', cbHandles.Color);

    upperCBHandle = cbHandles(2,:);
    lowerCBHandle = cbHandles(1,:);
    
    xData = upperCBHandle.XData; 
    k = patch([xData xData(end:-1:1) xData(1)], [lowerCBHandle.YData upperCBHandle.YData(end:-1:1) lowerCBHandle.YData(1)], 'b');
    set(k, 'EdgeColor', 'none', 'FaceColor', [markerColor(1)*0.55  markerColor(2)*0.55 markerColor(3)*0.55], 'FaceAlpha', '0.2')

    %Grab trendline and datapoints
    dataHandle = findobj(h,'DisplayName','data');
    fitHandle = findobj(h,'DisplayName','fit');
    dataHandle2 = findobj(pci,'DisplayName','Data');
    fitHandle2 = findobj(pci,'DisplayName','Fit');

    %===========================================================================
    %Style Settings for the Plot

    %Style the trendline
    set(fitHandle2, 'Color', [markerColor(1) markerColor(2) markerColor(3)], 'LineWidth', 3)

    %Style the plot
    pltLeg = legend('', '', '');
    set(fitHandle2, 'Marker', 'none')
    set(pltLeg,'visible','off')
    set(fitHandle, 'Visible', 'off')
    set(h, 'Visible', 'off')
    plot(h(1).XData, h(1).YData, 'MarkerEdgeColor', 'white', 'MarkerFaceColor', markerColor, 'MarkerSize', 12, 'Marker', 'o', 'LineStyle', 'none')

    %Add title and color to the model
    plotTitle = {char(tractIDs(t))};
    plotTitle = strjoin(['Multiple Nonlinear Model for', plotTitle]);
    title(plotTitle);
    xlabel('Age (years)');
    ylabel(measure);

    %Delete confidence bounds border 
    delete(pci(3))
    delete(pci(4))

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
    %Add adjusted R-squared & AIC values to table.
    rsqTableAdj.MultNonLin(t) = mdlci.Rsquared.Adjusted;
    rsqTableOrd.MultNonLin(t) = mdlci.Rsquared.Ordinary;
    aicTable.MultNonLin(t)= mdlci.ModelCriterion.AIC;

     %======= Calculating Inflection & Fastest Rate of Change =======
     x = unique(mdlci.Variables.x);
     y = predict(mdlci, x);

     %mdlFormula = 'yVar ~ -0.00373Age^2 + 0.4082Sex';
     %f2 = diff(mdlFormula);
     %f3 = diff(f2);
     %inflec_pt = fsolve(f2, 'MaxDegree', 3);
     %double(inflex_pt); 

     % Detrend 'y' To Facilitate Analysis
     y = detrend(y,1);                                     

     %Store x and y values in ratetbl
     ratetbl = table(x, y);
     %remove duplicate points
     ratetbl = unique(ratetbl, 'rows');
     
     %Assign x and y variables to new x and y vectors without duplicate
     %points
     y = ratetbl.y; 
     x = ratetbl.x;
    
     % Calculate Numerical Derivative
     dydx = gradient(y) ./ gradient(x);
     dyydx  = gradient(dydx) ./ gradient(x);

     %Save unordered derivatives in ratetbl                              
     ratetbl.dydx = dydx;
     ratetbl.dyydx = dyydx;

     %Sort derivatives 
     ratetbl = sortrows(ratetbl, 'dydx');                                      
     [~, ind] = unique(ratetbl(:,1), 'first');
     ratetbl = ratetbl(ind, :);
     
     [~, ind] = unique(ratetbl(:,"dydx"), 'first');
     ratetbl = ratetbl(ind, :);
     dydx = ratetbl.dydx; 
    
     %Interpolation Index Lower Limit
     [maxdydx, idxmax] = max(dydx);
     [mindydx, idxmin] = min(dydx);
     idxrng = idxmin: idxmax; 
    
     %inflection_idx = find(diff(sign(diff(y)))) + 1;
    
     %Find Inflection Point X-Value
     %xi = 3:1:21; 
     inflptx = interp1(dydx(idxrng), ratetbl.x(idxrng), 0, 'linear');           

     %Find Inflection Point Y-Value
     x = unique(mdlci.Variables.x);
     y = predict(mdlci, x);
     inflpty = interp1(x, y, inflptx, 'linear');      
    
    %=========================================================================================
    f(1) = plot(inflptx, inflpty, 's', 'MarkerEdgeColor', 'white', 'MarkerFaceColor', 'r', ...
        'MarkerSize', 50, 'DisplayName','Inflection Point');

    %calculating fastest rate of change by finding maximum dy/dx in
    %magnitude
    [~, fastestRate] = max(ratetbl.dydx); 
    fr = ratetbl(fastestRate, :);

    f(2) = plot(fr.x(1), fr.y(1), '>', 'MarkerEdgeColor', 'white', 'MarkerFaceColor', 'r', ...
        'MarkerSize', 50, 'DisplayName','Fastest Rate of Change');

    %legend
    %lgd = legend(f, {"Inflection Point","Fastest Rate of Change"});
    %lgd.FontName = 'Arial';
    %lgd.FontSize = 18;
    %legend box off;
    %pbaspect([1 1 1]);

    hold off

    %add adjusted inflection point and fastest rate to table.
    inflecTable.MultInflecX(t) = inflptx; 
    inflecTable.MultInflecY(t) = inflpty; 
    inflecTable.MultFastRateX(t) = fr.x(1); 
    inflecTable.MultFastRateY(t) = fr.y(1); 

    %============== Bootstrapping for ANOVA ==============

    hold on 

    figure(5*(t + length(tractIDs)))

    N = 100; 

    for q = 1:10000

        %Select random sample of N

        %define Age, Sex, and measurement variable
        x = tbl.Age; 
        y = tbl.yVar;
        z = tbl.Sex; 

        %randomly select x, y, and z values of size N
        msize = size(x);
        idx = randperm(msize(1), N);
        x = x(idx(1,:));
        y = y(idx(1,:));
        z = z(idx(1,:));

        tbl2 = table(x, y, z);

        %generating the model
        Q2 = 'y ~ x^2 + z'; 
        mdl2 = fitlm(tbl2, Q2);

        %plotting the model
        h2 = plotAdjustedResponse(mdl2, 'x', 'visible', 'off');  
        set(h2, 'DefaultFigureVisible', 'off');

        %get data for plotting the confidence intervals and add CI to plot.
        j2 = array2table(cat(2, h2(1).XData', h2(1).YData')); j2.Properties.VariableNames =  {'x', 'y'};
        mdlci2 = fitlm(j2, 'y~x^2');

        %Find the inflection points
        %ydt = detrend(y,1); 
        % Detrend 'y' To Facilitate Analysis
      

        %plot(x, y, '-*'); hold on;

        %======= Calculating Inflection & Fastest Rate of Change =======
        x = unique(mdlci2.Variables.x); 
        y = predict(mdlci2, x);

        % Detrend 'y' To Facilitate Analysis
        y = detrend(y,1);                                     

        %Store x and y values in ratetbl
        ratetbl = table(x, y);
        %remove duplicate points
        ratetbl = unique(ratetbl, 'rows');
     
        %Assign x and y variables to new x and y vectors without duplicate
        %points
        y = ratetbl.y; 
        x = ratetbl.x;
    
        % Calculate Numerical Derivative
        dydx = gradient(y) ./ gradient(x);
        dyydx  = gradient(dydx) ./ gradient(x);

        %Save unordered derivatives in ratetbl                              
        ratetbl.dydx = dydx;
        ratetbl.dyydx = dyydx;

        %Sort derivatives 
        ratetbl = sortrows(ratetbl, 'dydx');                                      
        [~, ind] = unique(ratetbl(:,1), 'first');
        ratetbl = ratetbl(ind, :);
     
        [~, ind] = unique(ratetbl(:,"dydx"), 'first');
        ratetbl = ratetbl(ind, :);
        dydx = ratetbl.dydx; 
    
        %Interpolation Index Lower Limit
        [maxdydx, idxmax] = max(dydx);
        [mindydx, idxmin] = min(dydx);
        idxrng = idxmin: idxmax; 
    
        %inflection_idx = find(diff(sign(diff(y)))) + 1;
    
        %Find Inflection Point X-Value
        inflptx = interp1(dydx(idxrng), ratetbl.x(idxrng), 0, 'linear');           

        %Find Inflection Point Y-Value
        x = unique(mdlci.Variables.x);
        y = predict(mdlci, x);
        inflpty = interp1(x, y, inflptx, 'linear');   

        %plot(inflptx, inflpty, '*'); hold off;

        anovaBootTable.SampleNum(lastRow) = q; 
        anovaBootTable.TractIDs(lastRow) = tractIDs(t); 
        anovaBootTable.MultInflecX(lastRow) = inflptx; 
        anovaBootTable.MultInflecY(lastRow) = inflpty; 
        
        if (string(extract(tractIDs(t), 1)) == 'l')
            anovaBootTable.Hemisphere(lastRow) = 'left';
            anovaBootTable.Tract(lastRow) = string(extractAfter(tractIDs(t), 4));
        end

        if (string(extract(tractIDs(t), 1)) == 'r')
            anovaBootTable.Hemisphere(lastRow) = 'right';
            anovaBootTable.Tract(lastRow) = string(extractAfter(tractIDs(t), 5));
        end

        lastRow = lastRow + 1; 

    end
    
    hold off 

end

%============== Export rsqTable as a csv ==============
%local path to save table: 
mainpath = '/Users/land/Desktop/projectTrackProfiles/supportFiles';

table_path_format_rsqTAdj = fullfile(mainpath, 'rsqTableAdj.csv');
table_path_format_rsqTOrd = fullfile(mainpath, 'rsqTableOrd.csv');
table_path_format_inflecT = fullfile(mainpath, 'inflecTable.csv');
table_path_format_aicTable = fullfile(mainpath, 'aicTable.csv');
table_path_format_anovaBootTable = fullfile(mainpath, 'anovaBootTable.csv');

%finally, save tables
writetable(rsqTableAdj, table_path_format_rsqTAdj);
writetable(rsqTableOrd, table_path_format_rsqTOrd);
writetable(inflecTable, table_path_format_inflecT);
writetable(aicTable, table_path_format_aicTable);
writetable(anovaBootTable, table_path_format_anovaBootTable);
