%Generating Tract Profiles

%redirecting folder to correct path. clear.
clear all; clc; clf; 

%define measure
measure = 'fa';
numNodes = 200 - 20; 

%insert local path of Tlong.csv file
Tlong = '/Volumes/LANDLAB/projects/hbn/projectTrackProfiles/supportFiles/Tlong.csv';
colorProfiles = '/Volumes/LANDLAB/projects/hbn/projectTrackProfiles/supportFiles/colorProfiles.csv';

%convert csv into a table.
Tlong = readtable(Tlong); 
colorProfiles = readtable(colorProfiles);

%close all previous plots
close all

%============== Generate Plots ==============

%generate column of tracts of interest ids
mask = ismember(Tlong.structureID, colorProfiles{:, 1});
tractIDs = Tlong(mask, :);
tractIDs = unique(tractIDs.structureID);

%Overall average age tract profile table
sizeOfTbl = numNodes * length(tractIDs); %because we are only generating for four tracts
mean6666Tbl = table('Size', [sizeOfTbl 3], 'VariableTypes', ["string", "double", "double"], 'VariableNames', ["tract", "X", "Y"]);
mean7777Tbl = table('Size', [sizeOfTbl 3], 'VariableTypes', ["string", "double", "double"], 'VariableNames', ["tract", "coord_comb1", "coord_comb2"]);
idxMean = 1:161; 
idxMean2 = 1:322; 

for z = 1:length(tractIDs)

    %plotting a model
    ageColumn = Tlong.Age(strcmp(Tlong.structureID, tractIDs(z)));
    nodeIDsColumn = Tlong.nodeID(strcmp(Tlong.structureID, tractIDs(z)));
    measureColumn = Tlong.(measure)(strcmp(Tlong.structureID, tractIDs(z)));
    subIDsColumn = Tlong.subjectID(strcmp(Tlong.structureID, tractIDs(z)));

    subs = unique(subIDsColumn);
 
    nodeMeasureTbl.Age = ageColumn; 
    nodeMeasureTbl.nodeIDs = nodeIDsColumn; 
    nodeMeasureTbl.measure = measureColumn; 
    nodeMeasureTbl.subID = subIDsColumn; 

    nodeMeasureTbl4 = struct2table(nodeMeasureTbl);

    %Calculating average 5-8 Mean Measure

    Headers = {'5-6 Measure'};

    nodeMeasureTbl3 = nodeMeasureTbl4((nodeMeasureTbl4.Age <= 8),:); 
    mean56Tbl = table('Size', [numNodes 2], 'VariableTypes', ["double", "double"], 'VariableNames', ["X", "Y"]);

    for h = 20:numNodes
        meanTbl = nodeMeasureTbl3((nodeMeasureTbl3.nodeIDs == h), :);
        mean56Tbl(h, "X") = num2cell(h); 
        mean56Tbl(h, "Y") = num2cell(mean(meanTbl.measure));
        mean56Tbl(h, "SD") = num2cell(std(meanTbl.measure)/sqrt(numNodes)); 
    end

    mean56Tbl((~any(mean56Tbl.Y,2) & (~any(mean56Tbl.X,2))), :) = []; %remove empty rows 

    %Calculating average 8-12 Mean Measure

    Headers = {'7-8 Measure'};

    nodeMeasureTbl3 = nodeMeasureTbl4((nodeMeasureTbl4.Age > 8 & nodeMeasureTbl4.Age <= 12),:); 
    mean78Tbl = table('Size', [numNodes 2], 'VariableTypes', ["double", "double"], 'VariableNames', ["X", "Y"]);

    for h = 20:numNodes
        meanTbl = nodeMeasureTbl3((nodeMeasureTbl3.nodeIDs == h), :);
        mean78Tbl(h, "X") = num2cell(h); 
        mean78Tbl(h, "Y") = num2cell(mean(meanTbl.measure));
        mean78Tbl(h, "SD") = num2cell(std(meanTbl.measure)/sqrt(numNodes)); 
    end

    mean78Tbl((~any(mean78Tbl.Y,2) & (~any(mean78Tbl.X,2))), :) = []; %remove empty rows 

    %Calculating average 12-16 Mean Measure

    Headers = {'9-10 Measure'};

    nodeMeasureTbl3 = nodeMeasureTbl4((nodeMeasureTbl4.Age > 12  & nodeMeasureTbl4.Age <= 16),:); 
    mean910Tbl = table('Size', [numNodes 2], 'VariableTypes', ["double", "double"], 'VariableNames', ["X", "Y"]);

    for h = 20:numNodes
        meanTbl = nodeMeasureTbl3((nodeMeasureTbl3.nodeIDs == h), :);
        mean910Tbl(h, "X") = num2cell(h); 
        mean910Tbl(h, "Y") = num2cell(mean(meanTbl.measure));
        mean910Tbl(h, "SD") = num2cell(std(meanTbl.measure)/sqrt(numNodes)); 
    end

    mean910Tbl((~any(mean910Tbl.Y,2) & (~any(mean910Tbl.X,2))), :) = []; %remove empty rows 

    %Calculating average 16-20 Mean Measure

    Headers = {'11-12 Measure'};

    nodeMeasureTbl3 = nodeMeasureTbl4((nodeMeasureTbl4.Age > 16  & nodeMeasureTbl4.Age <= 20),:); 
    mean1112Tbl = table('Size', [numNodes 2], 'VariableTypes', ["double", "double"], 'VariableNames', ["X", "Y"]);

    for h = 20:numNodes
        meanTbl = nodeMeasureTbl3((nodeMeasureTbl3.nodeIDs == h), :);
        mean1112Tbl(h, "X") = num2cell(h); 
        mean1112Tbl(h, "Y") = num2cell(mean(meanTbl.measure));
        mean1112Tbl(h, "SD") = num2cell(std(meanTbl.measure)/sqrt(numNodes)); 
    end

    mean1112Tbl((~any(mean1112Tbl.Y,2) & (~any(mean1112Tbl.X,2))), :) = []; %remove empty rows 

    %Calculating average 20-up Mean Measure

    Headers = {'13-14 Measure'};

    nodeMeasureTbl3 = nodeMeasureTbl4((nodeMeasureTbl4.Age > 20),:); 
    mean1314Tbl = table('Size', [numNodes 2], 'VariableTypes', ["double", "double"], 'VariableNames', ["X", "Y"]);

    for h = 20:numNodes
        meanTbl = nodeMeasureTbl3((nodeMeasureTbl3.nodeIDs == h), :);
        mean1314Tbl(h, "X") = num2cell(h); 
        mean1314Tbl(h, "Y") = num2cell(mean(meanTbl.measure));
        mean1314Tbl(h, "SD") = num2cell(std(meanTbl.measure)/sqrt(numNodes)); 
    end

    mean1314Tbl((~any(mean1314Tbl.Y,2) & (~any(mean1314Tbl.X,2))), :) = []; %remove empty rows

    %===========================================================================
    %plotting the model

    f = figure(z);

    %startingx, startingy, width height
    f.Position = [1000 1000 900 700];

    hold on

    %Plot background gray lines
    for j = 1:length(unique(subIDsColumn))
        newNodeTbl2.nodeIDs = nodeMeasureTbl.nodeIDs(strcmp(nodeMeasureTbl.subID, subs(j)));
        newNodeTbl2.measures = nodeMeasureTbl.measure(strcmp(nodeMeasureTbl.subID, subs(j)));

        remove_rows = any((newNodeTbl2.nodeIDs < 20) | (newNodeTbl2.nodeIDs > 180), 2);
        m_toDelete = newNodeTbl2(remove_rows, :); 
        newNodeTbl2(remove_rows, :) = [];

        plot(newNodeTbl2.nodeIDs, newNodeTbl2.measures, 'LineWidth', 3,'color', [237/255 237/255 237/255])
   
    end

    idx = find(strcmp(colorProfiles.NameOfTrack, char(tractIDs(z))) == 1);
    markerColor = [str2double(colorProfiles.Red{idx})/255, ...
               str2double(colorProfiles.Green{idx})/255, ...
               str2double(colorProfiles.Blue{idx})/255];

    %===========================================================================
    plotTitle = {char(tractIDs(z))};
    plotTitle = strjoin(['Tract Profiles for', plotTitle]);
    title(plotTitle);
    xlabel('Location along tract');
    ylabel('Fractional anistropy');

    %===========================================================================
    %getting shaded confidence intervals for 56

    yMean = mean56Tbl.Y; %Mean measure at each node (or value of 'x')
    ySEM = mean56Tbl.SD; %Computing 'Standard Error of the mean' of All Experiments at each node

    CI95 = tinv([0.025 0.975], numNodes-1); %Calculate 95% Probability Inversals of t-distribution
    yCI95 = bsxfun(@times, ySEM, CI95); %Calculate 95% Confidence Intervals of All nodes

    x2 = [mean56Tbl.X, mean56Tbl.X]; 
    inBetween = [yCI95(:, 1)+yMean, yMean+yCI95(:, 2)]; 
    coord_up = [mean56Tbl.X, yCI95(:, 2)+yMean];
    coord_low = [mean56Tbl.X, yCI95(:, 1)+yMean];
    coord_combine = [coord_up; flipud(coord_low)];

    %facealpha controls opacity: 0 (invisible) and 1 (opaque)
    fill(coord_combine(:, 1), coord_combine(:, 2), [markerColor(1)*0.95  markerColor(2)*0.95 markerColor(3)*0.95], 'LineStyle', 'none', 'facealpha', '0.3')

    
    
    %getting shaded confidence intervals for 78

    yMean = mean78Tbl.Y; %Mean measure at each node (or value of 'x')
    ySEM = mean78Tbl.SD; %Computing 'Standard Error of the mean' of All Experiments at each node

    CI95 = tinv([0.025 0.975], numNodes-1); %Calculate 95% Probability Inversals of t-distribution
    yCI95 = bsxfun(@times, ySEM, CI95); %Calculate 95% Confidence Intervals of All nodes

    x2 = [mean78Tbl.X, mean78Tbl.X]; 
    inBetween = [yCI95(:, 1)+yMean, yMean+yCI95(:, 2)]; 
    coord_up = [mean78Tbl.X, yCI95(:, 2)+yMean];
    coord_low = [mean78Tbl.X, yCI95(:, 1)+yMean];
    coord_combine = [coord_up; flipud(coord_low)];

    fill(coord_combine(:, 1), coord_combine(:, 2), [markerColor(1)*0.85  markerColor(2)*0.85 markerColor(3)*0.85], 'LineStyle', 'none', 'facealpha', '0.3')


    %getting shaded confidence intervals for 910

    yMean = mean910Tbl.Y; %Mean measure at each node (or value of 'x')
    ySEM = mean910Tbl.SD; %Computing 'Standard Error of the mean' of All Experiments at each node

    CI95 = tinv([0.025 0.975], numNodes-1); %Calculate 95% Probability Inversals of t-distribution
    yCI95 = bsxfun(@times, ySEM, CI95); %Calculate 95% Confidence Intervals of All nodes

    x2 = [mean910Tbl.X, mean910Tbl.X]; 
    inBetween = [yCI95(:, 1)+yMean, yMean+yCI95(:, 2)]; 
    coord_up = [mean910Tbl.X, yCI95(:, 2)+yMean];
    coord_low = [mean910Tbl.X, yCI95(:, 1)+yMean];
    coord_combine = [coord_up; flipud(coord_low)];

    fill(coord_combine(:, 1), coord_combine(:, 2), [markerColor(1)*0.75  markerColor(2)*0.75 markerColor(3)*0.75], 'LineStyle', 'none', 'facealpha', '0.3')

    
    %getting shaded confidence intervals for 1112

    yMean = mean1112Tbl.Y; %Mean measure at each node (or value of 'x')
    ySEM = mean1112Tbl.SD; %Computing 'Standard Error of the mean' of All Experiments at each node

    CI95 = tinv([0.025 0.975], numNodes-1); %Calculate 95% Probability Inversals of t-distribution
    yCI95 = bsxfun(@times, ySEM, CI95); %Calculate 95% Confidence Intervals of All nodes

    x2 = [mean1112Tbl.X, mean1112Tbl.X]; 
    inBetween = [yCI95(:, 1)+yMean, yMean+yCI95(:, 2)]; 
    coord_up = [mean1112Tbl.X, yCI95(:, 2)+yMean];
    coord_low = [mean1112Tbl.X, yCI95(:, 1)+yMean];
    coord_combine = [coord_up; flipud(coord_low)];

    fill(coord_combine(:, 1), coord_combine(:, 2), [markerColor(1)*0.65  markerColor(2)*0.65 markerColor(3)*0.65], 'LineStyle', 'none', 'facealpha', '0.3')


    %getting shaded confidence intervals for 1314

    yMean = mean1314Tbl.Y; %Mean measure at each node (or value of 'x')
    ySEM = mean1314Tbl.SD; %Computing 'Standard Error of the mean' of All Experiments at each node

    CI95 = tinv([0.025 0.975], numNodes-1); %Calculate 95% Probability Inversals of t-distribution
    yCI95 = bsxfun(@times, ySEM, CI95); %Calculate 95% Confidence Intervals of All nodes

    x2 = [mean1314Tbl.X, mean1314Tbl.X]; 
    inBetween = [yCI95(:, 1)+yMean, yMean+yCI95(:, 2)]; 
    coord_up = [mean1314Tbl.X, yCI95(:, 2)+yMean];
    coord_low = [mean1314Tbl.X, yCI95(:, 1)+yMean];
    coord_combine = [coord_up; flipud(coord_low)];

    fill(coord_combine(:, 1), coord_combine(:, 2), [markerColor(1)*0.55  markerColor(2)*0.55 markerColor(3)*0.55], 'LineStyle', 'none', 'facealpha', '0.3')


    %===========================================================================
    %lighter is youngest; darkest is older
    plot(mean56Tbl.X, mean56Tbl.Y, 'LineWidth', 3, 'color',  [markerColor(1)*0.90  markerColor(2)*0.90 markerColor(3)*0.90]);
    plot(mean78Tbl.X, mean78Tbl.Y, 'LineWidth', 3, 'color', [(markerColor(1)*0.80)  (markerColor(2)*0.80) (markerColor(3)*0.80)]);
    plot(mean910Tbl.X, mean910Tbl.Y, 'LineWidth', 3, 'color', [(markerColor(1)*0.70)  (markerColor(2)*0.70) (markerColor(3)*0.70)]);
    plot(mean1112Tbl.X, mean1112Tbl.Y, 'LineWidth', 3,'color', [(markerColor(1)*0.60)  (markerColor(2)*0.60) (markerColor(3)*0.60)]);
    plot(mean1314Tbl.X, mean1314Tbl.Y, 'LineWidth', 3, 'color', [(markerColor(1)*0.50)  (markerColor(2)*0.50) (markerColor(3)*0.50)]);

    %Create legend
    %legend
    %lines = [a, b, c, d, e];

    %lgd = legend(lines, ["3-8 Years", "8-12 Years", "12-16 Years", "16-20 Years", ...
    %    "20-22 Years"]);
    %lgd.FontName = 'Arial';
    %lgd.FontSize = 16;
    %legend box off;
    %pbaspect([1 1 1]);

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
    set(gca, 'XLim', [20 180], 'XTick', [20 100 180]);
    xax.FontName = fontname;
    xax.FontSize = fontsize;
 
    % yaxis
    yax = get(gca,'yaxis');
    yax.TickDirection = 'out';
    yax.TickLength = [yticklength yticklength];
    set(gca, 'YLim', [0.2 0.6], 'YTick', [0.2 0.4 0.6]);
    yax.FontName = fontname;
    yax.FontSize = fontsize;
    yax.FontAngle = fontangle;

    %change figure background to white
    set(gcf, 'color', 'w')

    %===========================================================================

    hold off

    %===========================================================================

    nodeMeasureTbl5 = nodeMeasureTbl4((nodeMeasureTbl4.Age > 20),:); 
    mean5555Tbl = table('Size', [numNodes 2], 'VariableTypes', ["double", "double"], 'VariableNames', ["X", "Y"]);

    for h = 20:numNodes
        meanTbl = nodeMeasureTbl5((nodeMeasureTbl5.nodeIDs == h), :);
        mean5555Tbl(h, "X") = num2cell(h); 
        mean5555Tbl(h, "Y") = num2cell(mean(meanTbl.measure));
        mean5555Tbl(h, "SD") = num2cell(std(meanTbl.measure)/sqrt(numNodes)); 
    end

    mean5555Tbl((~any(mean5555Tbl.Y,2) & (~any(mean5555Tbl.X,2))), :) = []; %remove empty rows 

    %getting shaded confidence intervals for 1314

    yMean = mean5555Tbl.Y; %Mean measure at each node (or value of 'x')
    ySEM = mean5555Tbl.SD; %Computing 'Standard Error of the mean' of All Experiments at each node

    CI95 = tinv([0.025 0.975], numNodes-1); %Calculate 95% Probability Inversals of t-distribution
    yCI95 = bsxfun(@times, ySEM, CI95); %Calculate 95% Confidence Intervals of All nodes

    x2 = [mean5555Tbl.X, mean5555Tbl.X]; 
    inBetween = [yCI95(:, 1)+yMean, yMean+yCI95(:, 2)]; 
    coord_up = [mean5555Tbl.X, yCI95(:, 2)+yMean];
    coord_low = [mean5555Tbl.X, yCI95(:, 1)+yMean];
    coord_combine = [coord_up; flipud(coord_low)];

    mean6666Tbl.tract(idxMean) = repmat(tractIDs(z), [1 length(idxMean)]);
    mean6666Tbl.X(idxMean) = mean5555Tbl.X;
    mean6666Tbl.Y(idxMean) = mean5555Tbl.Y;

    mean7777Tbl.tract(idxMean2)= repmat(tractIDs(z), [1 length(idxMean2)]); 
    mean7777Tbl.coord_comb1(idxMean2) = coord_combine(:,1);
    mean7777Tbl.coord_comb2(idxMean2) = coord_combine(:,2);

    idxMean(1) = idxMean(1) + 161; 
    idxMean(161) = idxMean(161) + 161; 
    idxMean = idxMean(1):idxMean(161); 

    idxMean2(1) = idxMean2(1) + 322; 
    idxMean2(322) = idxMean2(322) + 322; 
    idxMean2 = idxMean2(1):idxMean2(322); 

end

%just need to generate two pltos with just the right and left hemisphere

%Right Hemisphere Plots
f = figure(length(tractIDs) + 1);

%Startingx, Startingy, Width x Height
f.Position = [1000 1000 900 700];

hold on

%===========================================================================
plotTitle = {'Right Hemisphere Tracts'};
plotTitle = strjoin(['Tract Profiles for ', plotTitle]);
title(plotTitle);
xlabel('Location along tract');
ylabel('Fractional anistropy');
%===========================================================================

coordpArc = find(strcmp(mean7777Tbl.tract, 'rightpArc') == 1);
coordpArcX = mean7777Tbl.coord_comb1(coordpArc);
coordpArcY = mean7777Tbl.coord_comb2(coordpArc);
plotpArc = find(strcmp(mean6666Tbl.tract, 'rightpArc') == 1);
plotpArcX = mean6666Tbl.X(plotpArc);
plotpArcY = mean6666Tbl.Y(plotpArc);

coordFang = find(strcmp(mean7777Tbl.tract, 'rightMDLFang') == 1);
coordFangX = mean7777Tbl.coord_comb1(coordFang);
coordFangY = mean7777Tbl.coord_comb2(coordFang);
plotFang = find(strcmp(mean6666Tbl.tract, 'rightMDLFang') == 1);
plotFangX = mean6666Tbl.X(plotFang);
plotFangY = mean6666Tbl.Y(plotFang);

coordFspl = find(strcmp(mean7777Tbl.tract, 'rightMDLFspl') == 1);
coordFsplX = mean7777Tbl.coord_comb1(coordFspl);
coordFsplY = mean7777Tbl.coord_comb2(coordFspl);
plotFspl = find(strcmp(mean6666Tbl.tract, 'rightMDLFspl') == 1);
plotFsplX = mean6666Tbl.X(plotFspl);
plotFsplY = mean6666Tbl.Y(plotFspl);

coordTPC = find(strcmp(mean7777Tbl.tract, 'rightTPC') == 1);
coordTPCX = mean7777Tbl.coord_comb1(coordTPC);
coordTPCY = mean7777Tbl.coord_comb2(coordTPC);
plotTPC = find(strcmp(mean6666Tbl.tract, 'rightTPC') == 1);
plotTPCX = mean6666Tbl.X(plotTPC);
plotTPCY = mean6666Tbl.Y(plotTPC);

idxColor = find(strcmp(colorProfiles.NameOfTrack, 'rightpArc') == 1);
markerColor = [str2double(colorProfiles.Red{idxColor})/255, ...
               str2double(colorProfiles.Green{idxColor})/255, ...
               str2double(colorProfiles.Blue{idxColor})/255];
fill(coordpArcX, coordpArcY, [markerColor(1)*0.75  markerColor(2)*0.75 markerColor(3)*0.75], 'LineStyle', 'none', 'facealpha', '0.3')
plot(plotpArcX, plotpArcY, 'LineWidth', 3, 'color',  [markerColor(1)*0.90  markerColor(2)*0.90 markerColor(3)*0.90]);

idxColor = find(strcmp(colorProfiles.NameOfTrack, 'rightMDLFang') == 1);
markerColor = [str2double(colorProfiles.Red{idxColor})/255, ...
               str2double(colorProfiles.Green{idxColor})/255, ...
               str2double(colorProfiles.Blue{idxColor})/255];
fill(coordFangX, coordFangY, [markerColor(1)*0.75  markerColor(2)*0.75 markerColor(3)*0.75], 'LineStyle', 'none', 'facealpha', '0.3')
plot(plotFangX, plotFangY, 'LineWidth', 3, 'color',  [markerColor(1)*0.90  markerColor(2)*0.90 markerColor(3)*0.90]);

idxColor = find(strcmp(colorProfiles.NameOfTrack, 'rightMDLFspl') == 1);
markerColor = [str2double(colorProfiles.Red{idxColor})/255, ...
               str2double(colorProfiles.Green{idxColor})/255, ...
               str2double(colorProfiles.Blue{idxColor})/255];
fill(coordFsplX, coordFsplY, [markerColor(1)*0.75  markerColor(2)*0.75 markerColor(3)*0.75], 'LineStyle', 'none', 'facealpha', '0.3')
plot(plotFsplX, plotFsplY, 'LineWidth', 3, 'color',  [markerColor(1)*0.90  markerColor(2)*0.90 markerColor(3)*0.90]);

idxColor = find(strcmp(colorProfiles.NameOfTrack, 'rightTPC') == 1);
markerColor = [str2double(colorProfiles.Red{idxColor})/255, ...
               str2double(colorProfiles.Green{idxColor})/255, ...
               str2double(colorProfiles.Blue{idxColor})/255];
fill(coordTPCX, coordTPCY, [markerColor(1)*0.75  markerColor(2)*0.75 markerColor(3)*0.75], 'LineStyle', 'none', 'facealpha', '0.3')
plot(plotTPCX, plotTPCY, 'LineWidth', 3, 'color',  [markerColor(1)*0.90  markerColor(2)*0.90 markerColor(3)*0.90]);

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
set(gca, 'XLim', [20 180], 'XTick', [20 100 180]);
xax.FontName = fontname;
xax.FontSize = fontsize;
 
% yaxis
yax = get(gca,'yaxis');
yax.TickDirection = 'out';
yax.TickLength = [yticklength yticklength];
set(gca, 'YLim', [0.2 0.6], 'YTick', [0.2 0.4 0.6]);
yax.FontName = fontname;
yax.FontSize = fontsize;
yax.FontAngle = fontangle;

%change figure background to white
set(gcf, 'color', 'w')

%===========================================================================

hold off

%===========================================================================
%Left Hemisphere Plots
f = figure(length(tractIDs) + 2);

%Startingx, Startingy, Width x Height
f.Position = [1000 1000 900 700];

hold on

%===========================================================================
plotTitle = {'Left Hemisphere Tracts'};
plotTitle = strjoin(['Tract Profiles for ', plotTitle]);
title(plotTitle);
xlabel('Location along tract');
ylabel('Fractional anistropy');
%===========================================================================

coordpArc = find(strcmp(mean7777Tbl.tract, 'leftpArc') == 1);
coordpArcX = mean7777Tbl.coord_comb1(coordpArc);
coordpArcY = mean7777Tbl.coord_comb2(coordpArc);
plotpArc = find(strcmp(mean6666Tbl.tract, 'leftpArc') == 1);
plotpArcX = mean6666Tbl.X(plotpArc);
plotpArcY = mean6666Tbl.Y(plotpArc);

coordFang = find(strcmp(mean7777Tbl.tract, 'leftMDLFang') == 1);
coordFangX = mean7777Tbl.coord_comb1(coordFang);
coordFangY = mean7777Tbl.coord_comb2(coordFang);
plotFang = find(strcmp(mean6666Tbl.tract, 'leftMDLFang') == 1);
plotFangX = mean6666Tbl.X(plotFang);
plotFangY = mean6666Tbl.Y(plotFang);

coordFspl = find(strcmp(mean7777Tbl.tract, 'leftMDLFspl') == 1);
coordFsplX = mean7777Tbl.coord_comb1(coordFspl);
coordFsplY = mean7777Tbl.coord_comb2(coordFspl);
plotFspl = find(strcmp(mean6666Tbl.tract, 'leftMDLFspl') == 1);
plotFsplX = mean6666Tbl.X(plotFspl);
plotFsplY = mean6666Tbl.Y(plotFspl);

coordTPC = find(strcmp(mean7777Tbl.tract, 'leftTPC') == 1);
coordTPCX = mean7777Tbl.coord_comb1(coordTPC);
coordTPCY = mean7777Tbl.coord_comb2(coordTPC);
plotTPC = find(strcmp(mean6666Tbl.tract, 'leftTPC') == 1);
plotTPCX = mean6666Tbl.X(plotTPC);
plotTPCY = mean6666Tbl.Y(plotTPC);

idxColor = find(strcmp(colorProfiles.NameOfTrack, 'leftpArc') == 1);
markerColor = [str2double(colorProfiles.Red{idxColor})/255, ...
               str2double(colorProfiles.Green{idxColor})/255, ...
               str2double(colorProfiles.Blue{idxColor})/255];
fill(coordpArcX, coordpArcY, [markerColor(1)*0.75  markerColor(2)*0.75 markerColor(3)*0.75], 'LineStyle', 'none', 'facealpha', '0.3')
plot(plotpArcX, plotpArcY, 'LineWidth', 3, 'color',  [markerColor(1)*0.90  markerColor(2)*0.90 markerColor(3)*0.90]);

idxColor = find(strcmp(colorProfiles.NameOfTrack, 'leftMDLFang') == 1);
markerColor = [str2double(colorProfiles.Red{idxColor})/255, ...
               str2double(colorProfiles.Green{idxColor})/255, ...
               str2double(colorProfiles.Blue{idxColor})/255];
fill(coordFangX, coordFangY, [markerColor(1)*0.75  markerColor(2)*0.75 markerColor(3)*0.75], 'LineStyle', 'none', 'facealpha', '0.3')
plot(plotFangX, plotFangY, 'LineWidth', 3, 'color',  [markerColor(1)*0.90  markerColor(2)*0.90 markerColor(3)*0.90]);

idxColor = find(strcmp(colorProfiles.NameOfTrack, 'leftMDLFspl') == 1);
markerColor = [str2double(colorProfiles.Red{idxColor})/255, ...
               str2double(colorProfiles.Green{idxColor})/255, ...
               str2double(colorProfiles.Blue{idxColor})/255];
fill(coordFsplX, coordFsplY, [markerColor(1)*0.75  markerColor(2)*0.75 markerColor(3)*0.75], 'LineStyle', 'none', 'facealpha', '0.3')
plot(plotFsplX, plotFsplY, 'LineWidth', 3, 'color',  [markerColor(1)*0.90  markerColor(2)*0.90 markerColor(3)*0.90]);

idxColor = find(strcmp(colorProfiles.NameOfTrack, 'leftTPC') == 1);
markerColor = [str2double(colorProfiles.Red{idxColor})/255, ...
               str2double(colorProfiles.Green{idxColor})/255, ...
               str2double(colorProfiles.Blue{idxColor})/255];
fill(coordTPCX, coordTPCY, [markerColor(1)*0.75  markerColor(2)*0.75 markerColor(3)*0.75], 'LineStyle', 'none', 'facealpha', '0.3')
plot(plotTPCX, plotTPCY, 'LineWidth', 3, 'color',  [markerColor(1)*0.90  markerColor(2)*0.90 markerColor(3)*0.90]);

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
set(gca, 'XLim', [20 180], 'XTick', [20 100 180]);
xax.FontName = fontname;
xax.FontSize = fontsize;
 
% yaxis
yax = get(gca,'yaxis');
yax.TickDirection = 'out';
yax.TickLength = [yticklength yticklength];
set(gca, 'YLim', [0.2 0.6], 'YTick', [0.2 0.4 0.6]);
yax.FontName = fontname;
yax.FontSize = fontsize;
yax.FontAngle = fontangle;

%change figure background to white
set(gcf, 'color', 'w')

%===========================================================================

hold off
