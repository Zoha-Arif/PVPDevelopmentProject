%redirecting folder to correct path. clear.
clear all; clc;

%define measure
measure = 'fa';

%insert local path of Tshort.csv and Tlong.csv file
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
    figure(t)

    hold on

    %get appropriate RGB color for tract by indexing into colorProfiles.csv
    idx = find(strcmp(colorProfiles.NameOfTrack, char(tractIDs(t))) == 1);
    markerColor = [colorProfiles.Red(idx)/255, colorProfiles.Green(idx)/255, colorProfiles.Blue(idx)/255];

    %generate scatterplot
    scatter(Tshort.Age, Tshort.(char(tractIDs(t))),40, markerColor,'filled')
    %replace above line with this line if you want a scatterhist
    %scatterhist(Tshort.Age, Tshort.(char(tractIDs(t))), "Color", markerColor)

    hold off

    titleVar = {'Age as a Continuous Variable for'};
    title(strjoin([titleVar, char(tractIDs(t))]));
    xlabel('Age (years)');
    ylabel(measure);

end

