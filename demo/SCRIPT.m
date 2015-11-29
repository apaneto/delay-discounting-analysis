function SCRIPT
% code used in the preparation of the paper

%% Preamble
% Update the path below to point toward the '/ddToolbox' folder
toolboxPath = setToolboxPath('/Users/btvincent/git-local/delay-discounting-analysis/ddToolbox')
% Ensure the current directory is the 'project folder', in this case '\demo'
cd('/Users/btvincent/git-local/delay-discounting-analysis/demo')

% set some graphics preferences
setPlotTheme

%% Create data object

% create a cell array of which participant files to import
fnames={'AC-kirby27-DAYS.txt',...
'CS-kirby27-DAYS.txt',...
'NA-kirby27-DAYS.txt',...
'SB-kirby27-DAYS.txt',...
'bv-kirby27.txt',...
'rm-kirby27.txt',...
'vs-kirby27.txt',...
'BL-kirby27.txt',...
'EP-kirby27.txt',...
'JR-kirby27.txt',...
'KA-kirby27.txt',...
'LJ-kirby27.txt',...
'LY-kirby27.txt',...
'SK-kirby27.txt',...
'VD-kirby27.txt'};
% Participant-level data will be aggregated into a larger group-level text
% file and saved in \data\groupLevelData for inspection. Choose a
% meaningful filename for this group-level data. This data is not used, it
% is just provided so you can confirm everything is working properly.
saveName = 'methodspaper-kirby27.txt';

% create the group-level data object
pathToData='data';
myData = DataClass(saveName,pathToData);
myData.loadDataFiles(fnames);

% It is important to visualise your participant data. It may well be that
% some participant's have produced meaningless data, in which case you may
% want to discard these participants at this stage. The quickAnalysis()
% method of the DataClass provides some simple visualisation and analysis.
myData.quickAnalysis();

%% Analyse the data with the hierarchical model

% First we create a model object, which we will call hModel. This is an
% instance of the class 'ModelHierarchical'
hModel = ModelHierarchical(toolboxPath);

% Here we should change default parameters
hModel.setMCMCtotalSamples(5000); % default is 10^5
% If you have more than 2 cores on your machine you can uncomment this next
% line
%hModel.setMCMCnumberOfChains(4);

% This will initiate MCMC sampling. This can take some time to run,
% depending on number of samples, chains, computer speed and cores etc.
% It's probably best to start with a low number of MCMC samples to get a
% feel for how long the sampling takes.
hModel.conductInference(myData);

% Export posterior mode (and credible intervals) of all parameter and group
% level parameters to a text file
hModel.exportParameterEstimates(myData);

% Plot all the results
hModel.plot(myData)

%% Example research conclusions...

% Calculate Bayes Factor, and plot 95% CI on the posterior
hModel.HTgroupSlopeLessThanZero(myData)

% Summary information of the group and participant level infererences are
% stored in a structure in the model object, eg:
%  hModel.analyses.univariate
% So if you wanted to find the group level posterior mode for the slope of
% the magnitude effect, you can type:
%	hModel.analyses.univariate.glM
%	hModel.analyses.univariate.glM.CI95
% and if you wanted estimates for each participant, for example the slope
% of the magnitude effect, then you can type:
%	hModel.analyses.univariate.m.mode'

% Modal values of m_p for all participants
% Export these point estimates into a text file and analyse with JASP
%	hModel.analyses.univariate.m.mode'
%	hModel.analyses.univariate.m.CI95'

% This information can be more neatly arranged by putting into a Matlab
% table, for example
participant_level_m = array2table([hModel.analyses.univariate.m.mode' hModel.analyses.univariate.m.CI95'],...
	'VariableNames',{'posteriorMode' 'CI5' 'CI95'})


%% Discount rate for a particular reward magnitude
% You may be interested in the discount rate (at the group and participant
% levels) at a particular reward magnitude. The method
% conditionalDiscountRatePlots() plots participant and group level
% conditional posterior (predictive) distributions. That is...
% The posterior distribution of discount rate (log(k)) for a given reward
% magnitude.

% Below we calculate and plot the discount rates for reward magnitudes of
% �100 and �1,000

figure(1), clf
plotFlag=true;
ax(1) = subplot(1,2,1);
hModel.conditionalDiscountRates(100, plotFlag);
ax(2) = subplot(1,2,2);
hModel.conditionalDiscountRates(1000, plotFlag);
linkaxes(ax,'xy')


%% PARTICIPANT-LEVEL ONLY INFERENCES
% If you want to avoid group-level hierarchical inference, then you can use
% a different model class. Code below shows an example

saveName = 'nonHierarchical.txt';
pathToData='data';
sepData = DataClass(saveName,pathToData);
sepData.loadDataFiles(fnames);

sModel = ModelSeperate(toolboxPath);
sModel.setMCMCtotalSamples(5000); 
sModel.setMCMCnumberOfChains(4);
sModel.conductInference(sepData);
sModel.exportParameterEstimates(sepData);
sModel.plot(sepData)

return