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
set(gca, 'YLim', [5 15], 'YTick', [5 10 15]);

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

%errorbar(x,y,ci,marker) where ci is the height of the line. This can be
%computed from your confidence intervals. 
%lower bound
%pArcL = (-1 * inflecTable.MultInflecX(rowsL(1))) + 6.893721466;
%pArcR = (-1 * inflecTable.MultInflecX(rowsR(1))) + 6.161891567;
%splL = (-1 * inflecTable.MultInflecX(rowsL(2))) + 6.02040946;
%splR = (-1 * inflecTable.MultInflecX(rowsR(2))) + 6.140460497;
%angL = (-1 * inflecTable.MultInflecX(rowsL(3))) + 6.138552923;
%angR = (-1 * inflecTable.MultInflecX(rowsR(3))) + 6.166994631;
%tpcL = (-1 * inflecTable.MultInflecX(rowsL(4))) + 6.156368105;
%tpcR = (-1 * inflecTable.MultInflecX(rowsR(4))) + 6.280257157;

%neg = [pArcL pArcR splL splR angL angR tpcL tpcR];

%upper bound
%pArcL2 = 17.42338265 - (inflecTable.MultInflecX(rowsL(1)));
%pArcR2 = 18.64703393 - (inflecTable.MultInflecX(rowsR(1)));
%splL2 = 19.15793856 - (inflecTable.MultInflecX(rowsL(2)));
%splR2 = 18.85889364 - (inflecTable.MultInflecX(rowsR(2)));
%angL2 = 18.20414596 - (inflecTable.MultInflecX(rowsL(3)));
%angR2 = 18.88247928 - (inflecTable.MultInflecX(rowsR(3)));
%tpcL2 = 18.89348668 - (inflecTable.MultInflecX(rowsL(4)));
%tpcR2 = 18.40364571 - (inflecTable.MultInflecX(rowsR(4)));

%pos = [pArcL2 pArcR2 splL2 splR2 angL2 angR2 tpcL2 tpcR2];

%lower bound
pArcL = 0.288056093;
pArcR = 0.35568899;
splL = 0.384462403;
splR = 0.36780094;
angL = 0.334102559;
angR = 0.36806937;
tpcL = 0.367812558;
tpcR = 0.341291798;

neg = [pArcL pArcR splL splR angL angR tpcL tpcR];

%upper bound
pArcL2 = 0.288056093;
pArcR2 = 0.35568899;
splL2 = 0.384462403;
splR2 = 0.36780094;
angL2 = 0.334102559;
angR2 = 0.36806937;
tpcL2 = 0.367812558;
tpcR2 = 0.341291798;

pos = [pArcL2 pArcR2 splL2 splR2 angL2 angR2 tpcL2 tpcR2];


e = errorbar([1 2 3 4 5 6 7 8], y1, neg, pos, 'o');
e.set("Color", 'black', 'LineWidth', 2, 'CapSize', 10); 

hold off
