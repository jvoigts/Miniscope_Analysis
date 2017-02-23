%% Generates the initial ms data struct for data set contained in current folder
ms = msGenerateVideoObj(pwd,'msCam');  
ms = msColumnCorrection(ms,5); %Generally not used 
ms = msFluorFrameProps(ms);

%% Select fluorescence thresh for good frames
% The output of msSelectFluorThresh(), ms.goodFrames, is not implemented. 
% Therefore the threshold selected has no effect on the rest of the analysis. 
% msSelectFluorThresh() does generate a potentially interesting plot of  
% fluorescence changes across recording sessions. 
ms = msSelectFluorThresh(ms);

%% Allows user to select ROIs for each data folder
ms = msSelectROIs(ms);
%% Run alignment across all ROIs
plotting = true;
tic
ms = msAlignmentFFT(ms,plotting);
toc
%% Calculate mean frames
downsample = 5;
ms = msMeanFrame(ms,downsample);

%% Manually inspect and select best alignment
ms = msSelectAlignment(ms);

%% Segment Sessions
plotting = true;
ms = msFindBrightSpots(ms,20,[],.08,0.06,plotting);

%%
try 
    ms=rmfield(ms,'segments');
end;

ms = msAutoSegment2(ms,[],[60 8000],5,.85,plotting);

%% Calculate Segment relationships
calcCorr = false;
calcDist = true;
calcOverlap = true;
ms = msCalcSegmentRelations(ms, calcCorr, calcDist, calcOverlap);

%% Clean Segments
corrThresh = [];
distThresh = 7;
overlapThresh = .8;
ms = msCleanSegments(ms,corrThresh,distThresh,overlapThresh);

%% Calculate Segment relationships
calcCorr = false;
calcDist = true;
calcOverlap = true;
ms = msCalcSegmentRelations(ms, calcCorr, calcDist, calcOverlap);

%% Calculate segment centroids
ms = msSegmentCentroids(ms);

%% Extract dF/F
ms = msExtractdFFTraces(ms);
ms = msCleandFFTraces(ms);
ms = msExtractFiring(ms);

%% Align across sessions
% ms = msAlignBetweenSessions(msRef,ms);

%% Count segments in common field
% msBatchSegmentsInField(pwd);

%% Match segments across sessions
% distThresh = 5;
% msBatchMatchSegmentsBetweenSessions(pwd, distThresh);


%% BEHAV STUFF

%% Generate behav.m
behav = msGenerateVideoObj(pwd,'behavCam');

%% Select ROI and HSV for tracking
behav = msSelectPropsForTracking(behav); 

%% Extract position
trackLength = 200;%cm
behav = msExtractBehavoir(behav, trackLength); 