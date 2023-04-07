%redirecting folder to correct path. clear.
clear all; clc;

%define measure -> make sure it is the same name in Tshort/Tlong
measure = 'fa';

%insert local path of Tshort.csv, Tlong.csv file, and colorProfiles
Tshort = '/Users/land/Desktop/projectTrackProfiles/supportFiles/Tshort.csv';
Tlong = '/Users/land/Desktop/projectTrackProfiles/supportFiles/Tlong.csv';
colorProfiles = '/Users/land/Desktop/projectTrackProfiles/supportFiles/colorProfiles.csv';

%convert csv into a table.
Tshort = readtable(Tshort); 
Tlong = readtable(Tlong); 
colorProfiles = readtable(colorProfiles);

%============== Generate Plots ==============

%generate column of tracts of interest ids
mask = ismember(Tlong.structureID, colorProfiles{:, 1});
tractIDs = Tlong(mask, :);
tractIDs = unique(tractIDs.structureID);

%close all previous plots
close all

for t = 1:length(tractIDs)
    figure(t + 61)

    %calculate average measure for each bin.

    binNames = unique(Tshort.Bins);

    TbinLines = table(binNames);

    for i = 1:(length(binNames))
        tempTable = Tlong((Tlong.Bins == binNames(i)) & strcmp(Tlong.structureID, char(tractIDs(t))) == 1, :);
        col = tempTable.(measure);
        meanVar = mean(col);
        TbinLines.MeanVar(i) = meanVar;  
    end

    %generate scatter plot.
    hold on

    %get appropriate RGB color for tract by indexing into colorProfiles.csv
    idx = find(strcmp(colorProfiles.NameOfTrack, char(tractIDs(t))) == 1);
    markerColor = [colorProfiles.Red(idx)/255, colorProfiles.Green(idx)/255, colorProfiles.Blue(idx)/255];

    %generate scatter
    scatter(Tshort.Bins, Tshort.(char(tractIDs(t))), 40, markerColor, 'filled')
    %replace above line with this line if you want a scatterhist
    %scatterhist(Tshort.Bins, Tshort.(char(tractIDs(t))), "Color", markerColor)

    hold off

    titleVar = {'Age as a Discontinuous Variable for'};
    title(strjoin([titleVar, char(tractIDs(t))]));
    xlabel('Age (years)');
    ylabel(measure);


    %plot lines onto scatter plot.
    for k = 1:length(binNames)
        y = TbinLines.MeanVar(k);
        line1 = line([binNames(k) - 0.5, binNames(k) + 0.5], [y, y]);
        line1.Color = markerColor;
    end

end