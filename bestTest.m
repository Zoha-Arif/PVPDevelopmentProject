%Extract which test is the best

%insert local path of Tshort.csv and Tlong.csv file
Tlong = '/Users/land/Desktop/projectTrackProfiles/supportFiles/Tlong.csv';
colorProfiles = '/Users/land/Desktop/projectTrackProfiles/supportFiles/colorProfiles.csv';
rsqTableAdj = '/Users/land/Desktop/projectTrackProfiles/supportFiles/rsqTableAdj.csv';
rsqTableOrd = '/Users/land/Desktop/projectTrackProfiles/supportFiles/rsqTableOrd.csv';
aicTable = '/Users/land/Desktop/projectTrackProfiles/supportFiles/aicTable.csv';

%convert csv into a table.
Tlong = readtable(Tlong); 
colorProfiles = readtable(colorProfiles);
rsqTableAdj = readtable(rsqTableAdj);
rsqTableOrd = readtable(rsqTableOrd);
aicTable = readtable(aicTable); 

%generate column of tracts of interest ids
mask = ismember(Tlong.structureID, colorProfiles{:, 1});
tractIDs = Tlong(mask, :);
tractIDs = unique(tractIDs.structureID);
bestTests = table(tractIDs); 

tempRSQAdjTbl = table();
tempRSQAdjTbl.SimpleLin = rsqTableAdj.SimpleLin;
tempRSQAdjTbl.MultLin = rsqTableAdj.MultLin;
tempRSQAdjTbl.SimpleNonLin = rsqTableAdj.SimpleNonLin;
tempRSQAdjTbl.MultNonLin = rsqTableAdj.MultNonLin;

tempAICTbl = table();
tempAICTbl.SimpleLin = aicTable.SimpleLin;
tempAICTbl.MultLin = aicTable.MultLin;
tempAICTbl.SimpleNonLin = aicTable.SimpleNonLin;
tempAICTbl.MultNonLin = aicTable.MultNonLin;

%find maximum RSQ
[maxVals, maxLocs] = max(tempRSQAdjTbl{:, :}, [], 2);
maxVarNames = tempRSQAdjTbl.Properties.VariableNames(maxLocs);
maxVarNames = (maxVarNames(1, :))';
bestTests.TestsRSQ = maxVarNames; 

%find minimum AIC
[minVals, minLocs] = min(tempAICTbl{:, :}, [], 2);
minVarNames = tempAICTbl.Properties.VariableNames(minLocs);
minVarNames = (minVarNames(1, :))';
bestTests.TestsAIC = minVarNames; 
