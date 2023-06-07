%use this script if you downloaded tractmeasures.csv from brainlife.

%redirecting folder to correct path. clear.
clear all; clc;

%(!) % define measure (!)
measure = 'fa';

%fetching all subject's subfolders and storing them in subfolders
%insert local path to track profiles here by changing value of mainpath.
fileName = '/Users/land/Desktop/projectTrackProfiles/tractmeasures.csv';

%============== Generate Tlong ==============
Tlong = readtable(fileName);

%insert local path to csv here by changing value of mainpath.
mainpath = '/Users/land/Desktop/projectTrackProfiles/supportFiles/participants.csv'; 
T = readtable(mainpath);

%get only subject ids
subIDs = T.Subject;

%create new columns in Tlong for Age, Sex, Handedness, and Bin
Tlong.Age = repmat("NA", height(Tlong), 1);
Tlong.Sex = repmat("NA", height(Tlong), 1);
Tlong.Handedness = repmat("NA", height(Tlong), 1);
Tlong.Bins = repmat("NA", height(Tlong), 1);

%fill in Age, Sex, and Handedness data in Tlong by copying from csv. 
for i = 1:length(subIDs)
    idx = find(strcmp(Tlong.subjectID, char(subIDs(i))) == 1);
    Tlong.Age(idx) = repmat(num2cell(T.Age(i)), [1 length(idx)]);
    Tlong.Sex(idx) = repmat(num2cell(T.Sex(i)), [1 length(idx)]);
    Tlong.Handedness(idx) = repmat(num2cell(T.Handedness(i)), [1 length(idx)]);
    clear idx; 
end

%fill in bin assignments in Tlong
for i = 1:length(subIDs)
    idx = find(strcmp(Tlong.subjectID, char(subIDs(i))) == 1);
    Tlong.Bins(idx) = repmat(num2cell(round(T.Age(i))), [1 length(idx)]);
    T.Bins(i) = num2cell(round(T.Age(i))); 
end

%convert data types in columns from strings to doubles
Tlong.Age = str2double(Tlong.Age);
Tlong.Sex = str2double(Tlong.Sex);
Tlong.Handedness = str2double(Tlong.Handedness);
Tlong.Bins = str2double(Tlong.Bins);

%============== Generate Tshort ==============
Tshort = T; 
tractIDs = unique(Tlong.structureID);

for s = 1:length(subIDs)
    Sidx = find(strcmp(Tlong.subjectID, char(subIDs(s))) == 1);
    for t = 1:length(tractIDs)
        Tidx = find(strcmp(Tlong.structureID, char(tractIDs(t))) == 1);
        STidx = intersect(Tidx, Sidx);
        faTract = Tlong(STidx, measure);
        faTract = table2array(faTract);
        Tshort.(char(tractIDs(t)))(s) = repmat(mean(faTract, 1), [1 length(s)]); 
    end
end

%============== Export Tshort and Tlong as a csv ==============
%local path to save table: 
mainpath = '/Users/land/Desktop/projectTrackProfiles/supportFiles';

table_path_format_tshort = fullfile(mainpath, 'Tshort.csv');
table_path_format_tlong = fullfile(mainpath, 'Tlong.csv');

%funally, save tables
writetable(Tshort, table_path_format_tshort);
writetable(Tlong, table_path_format_tlong);