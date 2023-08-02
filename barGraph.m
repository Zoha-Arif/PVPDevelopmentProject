%Generate bar graphs for the inflection point and fastest rate of change.
clc
close all

%insert local path of Tshort.csv and Tlong.csv file
Tlong = '/Users/land/Desktop/projectTrackProfiles/supportFiles/Tlong.csv';
colorProfiles = '/Users/land/Desktop/projectTrackProfiles/supportFiles/colorProfiles.csv';
inflecTable = '/Users/land/Desktop/projectTrackProfiles/supportFiles/inflecTable.csv';
anovaBootTable = '/Users/land/Desktop/projectTrackProfiles/supportFiles/anovaBootTable.csv';

%convert csv into a table.
Tlong = readtable(Tlong); 
colorProfiles = readtable(colorProfiles);
inflecTable = readtable(inflecTable); 
anovaBootTable = readtable(anovaBootTable); 

%generate column of tracts of interest ids
mask = ismember(Tlong.structureID, colorProfiles{:, 1});
tractIDs = Tlong(mask, :);
tractIDs = unique(tractIDs.structureID);

%convert colorProfiles from cell to string
colorProfiles.NameOfTrack = string(colorProfiles.NameOfTrack);

%get color of bars
[rows, ~] = find(colorProfiles.NameOfTrack == ["leftpArc", "leftMDLFspl", "leftMDLFang", "leftTPC"]);
pArcColor = table2array([colorProfiles(rows(1), 'Red') colorProfiles(rows(1), 'Green') colorProfiles(rows(1), 'Blue')]);
MDLFsplColor = table2array([colorProfiles(rows(2), 'Red') colorProfiles(rows(2), 'Green') colorProfiles(rows(2), 'Blue')]);
MDLFangColor = table2array([colorProfiles(rows(3), 'Red') colorProfiles(rows(3), 'Green') colorProfiles(rows(3), 'Blue')]);
TPCColor = table2array([colorProfiles(rows(4), 'Red') colorProfiles(rows(4), 'Green') colorProfiles(rows(4), 'Blue')]);

%Left Hemisphere Tracts
[rowsL, ~] = find(inflecTable.tractIDs == ["leftpArc", "leftMDLFspl", "leftMDLFang", "leftTPC"]);

%Right Hemisphere Tracts
[rowsR, ~] = find(inflecTable.tractIDs == ["rightpArc", "rightMDLFspl", "rightMDLFang", "rightTPC"]);

%==========================================================================
%Plot Left Hemisphere Inflection
f = figure(1);
%startingx, startingy, width height
f.Position = [1000 1000 600 500];

%change figure background to white
set(gcf, 'color', 'w')
set(gca, 'YLim', [0 15], 'YTick', [0 7.5 15]);

hold on

%generate bar graph
x1 = categorical({'pArc Left', 'pArc Right', 'MDLF-spl Left', 'MDLF-spl Right', 'MDLF-ang Left','MDLF-ang Right','TPC Left', ...
    'TPC Right'});
x1 = reordercats(x1, {'pArc Left', 'pArc Right', 'MDLF-spl Left', 'MDLF-spl Right', 'MDLF-ang Left','MDLF-ang Right','TPC Left', ...
    'TPC Right'});

y1 = [inflecTable.MultInflecX(rowsL(1)), inflecTable.MultInflecX(rowsR(1)), ...
    inflecTable.MultInflecX(rowsL(2)), inflecTable.MultInflecX(rowsR(2)), ...
    inflecTable.MultInflecX(rowsL(3)),inflecTable.MultInflecX(rowsR(3)), ...
    inflecTable.MultInflecX(rowsL(4)), inflecTable.MultInflecX(rowsR(4))];

b = bar(x1, y1, 'facecolor', 'flat', 'LineWidth', 2);

%for hatched pattern: need to plot it twice and rearrange group!

clr = [pArcColor(1)/255 pArcColor(2)/255 pArcColor(3)/255;
        pArcColor(1)/255 pArcColor(2)/255 pArcColor(3)/255;
        MDLFsplColor(1)/255 MDLFsplColor(2)/255 MDLFsplColor(3)/255;
        MDLFsplColor(1)/255 MDLFsplColor(2)/255 MDLFsplColor(3)/255;
        MDLFangColor(1)/255 MDLFangColor(2)/255 MDLFangColor(3)/255; 
        MDLFangColor(1)/255 MDLFangColor(2)/255 MDLFangColor(3)/255; 
        TPCColor(1)/255 TPCColor(2)/255 TPCColor(3)/255;
        TPCColor(1)/255 TPCColor(2)/255 TPCColor(3)/255];
b.CData = clr;

title('Inflection')
xlabel('Tract')
ylabel('Age')
set(gca, 'FontSize', 24, 'FontName', 'Arial', 'LineWidth', 2);
yax = get(gca,'yaxis');
yax.FontAngle = 'italic';

%==========================================================================
%ANOVA

idxRpArc = find(strcmp(anovaBootTable.TractIDs, char('rightpArc')) == 1);
idxLpArc = find(strcmp(anovaBootTable.TractIDs, char('leftpArc')) == 1);

idxLMDLFang = find(strcmp(anovaBootTable.TractIDs, char('leftMDLFang')) == 1);
idxRMDLFang = find(strcmp(anovaBootTable.TractIDs, char('rightMDLFang')) == 1);

idxLMDLFspl = find(strcmp(anovaBootTable.TractIDs, char('leftMDLFspl')) == 1);
idxRMDLFspl = find(strcmp(anovaBootTable.TractIDs, char('rightMDLFspl')) == 1);

idxLTPC = find(strcmp(anovaBootTable.TractIDs, char('leftTPC')) == 1);
idxRTPC = find(strcmp(anovaBootTable.TractIDs, char('rightTPC')) == 1);

anovaTable = vertcat(anovaBootTable(idxRpArc, :), anovaBootTable(idxLpArc, :), anovaBootTable(idxLMDLFang, :), ...
    anovaBootTable(idxRMDLFang, :), anovaBootTable(idxLMDLFspl, :), anovaBootTable(idxRMDLFspl, :), ...
    anovaBootTable(idxLTPC, :), anovaBootTable(idxRTPC, :));
anovaTable2 = anovaTable(:, {'MultInflecX', 'Hemisphere', 'Tract'});

anovaTable2.Hemisphere = categorical(anovaTable2.Hemisphere); 
anovaTable2.Hemisphere(anovaTable2.Hemisphere == 'right') = "0";
anovaTable2.Hemisphere(anovaTable2.Hemisphere == 'left') = "1";
anovaTable2.Hemisphere = str2num(char(anovaTable2.Hemisphere));

anovaTable2.Tract = categorical(anovaTable2.Tract); 
anovaTable2.Tract(anovaTable2.Tract == 'pArc') = "1";
anovaTable2.Tract(anovaTable2.Tract == 'MDLFang') = "2";
anovaTable2.Tract(anovaTable2.Tract == 'MDLFspl') = "3";
anovaTable2.Tract(anovaTable2.Tract == 'TPC') = "4";
anovaTable2.Tract = str2num(char(anovaTable2.Tract));

%anovaMatrix = anovaTable2{:,:}; 
%table array
Meas = table([1 2]', 'VariableNames', {'Categories'});
rm = fitrm(anovaTable2, 'Hemisphere*Tract ~MultInflecX', 'WithinDesign', Meas); 
ranovatbl = ranova(rm); 

aov = anova(anovaTable2, 'MultInflecX');
c = groupmeans(aov, ["Hemisphere", "Tract"]);

%errlow = [c.MeanLower(1, :) c.MeanLower(2, :) c.MeanLower(5, :) c.MeanLower(6, :) ...
%    c.MeanLower(3, :) c.MeanLower(4, :) c.MeanLower(7, :) c.MeanLower(8, :)];
%errhigh = [c.MeanUpper(1, :) c.MeanUpper(2, :) c.MeanUpper(5, :) c.MeanUpper(6, :) ...
%    c.MeanUpper(3, :) c.MeanUpper(4, :) c.MeanUpper(7, :) c.MeanUpper(8, :)];

%errlow = [c.SE(1, :) c.SE(2, :) c.SE(3, :) c.SE(4, :) c.SE(5, :) c.SE(6, :) c.SE(7, :) c.SE(8, :)];    
%errhigh = [c.SE(1, :) c.SE(2, :) c.SE(3, :) c.SE(4, :) c.SE(5, :) c.SE(6, :) c.SE(7, :) c.SE(8, :)]; 

%er = errorbar(x1, y1, errlow, errhigh);
%er.Color = [0 0 0];

hold off


%Other things: 
%1. Need to perform ANOVA
%2. Need to find results form ANOVA
%3. Need to plot onto final results.

%{
%==========================================================================
%Plot Left Hemisphere Fastest Rate of Change
f = figure(3);
%startingx, startingy, width height
f.Position = [1000 1000 600 500];

%change figure background to white
set(gcf, 'color', 'w')
set(gca, 'YLim', [0 5], 'YTick', [0 2.5 5]);

hold on

%generate bar graph
x = categorical({'pArc', 'MDLF-spl', 'MDLF-ang', 'TPC'});
[rows4, ~] = find(inflecTable.tractIDs == ["leftpArc", "leftMDLFspl", "leftMDLFang", "leftTPC"]);
y = [inflecTable.MultFastRateX(rowsL(1)), inflecTable.MultFastRateX(rowsL(2)), inflecTable.MultFastRateX(rowsL(3)), inflecTable.MultFastRateX(rowsL(4))];

b = bar(x, y, 'facecolor', 'flat', 'LineWidth', 2);

clr = [MDLFangColor(1)/255 MDLFangColor(2)/255 MDLFangColor(3)/255; 
        MDLFsplColor(1)/255 MDLFsplColor(2)/255 MDLFsplColor(3)/255;
        TPCColor(1)/255 TPCColor(2)/255 TPCColor(3)/255;
        pArcColor(1)/255 pArcColor(2)/255 pArcColor(3)/255];
b.CData = clr; 

title('Left Hemisphere Fastest Rate of Change')
xlabel('Tract')
ylabel('Age')
set(gca, 'FontSize', 24, 'FontName', 'Arial', 'LineWidth', 2);
yax = get(gca,'yaxis');
yax.FontAngle = 'italic';

hold off

%==========================================================================
%Plot Right Hemisphere Fastest Rate of Change
f = figure(4);
%startingx, startingy, width height
f.Position = [1000 1000 600 500];

%change figure background to white
set(gcf, 'color', 'w')
set(gca, 'YLim', [0 5], 'YTick', [0 2.5 5]);

hold on

%generate bar graphs
x = categorical({'pArc', 'MDLF-spl', 'MDLF-ang', 'TPC'});
[rows3, ~] = find(inflecTable.tractIDs == ["rightpArc", "rightMDLFspl", "rightMDLFang", "rightTPC"]);
y = [inflecTable.MultFastRateX(rowsR(1)), inflecTable.MultFastRateX(rowsR(2)), inflecTable.MultFastRateX(rowsR(3)), inflecTable.MultFastRateX(rowsR(4))];

b = bar(x, y, 'facecolor', 'flat', 'LineWidth', 2);

clr = [MDLFangColor(1)/255 MDLFangColor(2)/255 MDLFangColor(3)/255; 
        MDLFsplColor(1)/255 MDLFsplColor(2)/255 MDLFsplColor(3)/255;
        TPCColor(1)/255 TPCColor(2)/255 TPCColor(3)/255;
        pArcColor(1)/255 pArcColor(2)/255 pArcColor(3)/255];
b.CData = clr; 

title('Right Hemisphere Fastest Rate of Change')
xlabel('Tract')
ylabel('Age')
set(gca, 'FontSize', 24, 'FontName', 'Arial', 'LineWidth', 2);
yax = get(gca,'yaxis');
yax.FontAngle = 'italic';

hold off 
%}

%==========================================================================