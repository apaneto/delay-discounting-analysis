function testScript

numberOfMCMCSamples = 10^4;
chains = 2;

%% Setup stuff
environment = ddAnalysisSetUp(...
	'toolboxPath', '~/git-local/delay-discounting-analysis/ddToolbox',...
	'projectPath', '~/git-local/delay-discounting-analysis/demo',...
	'dataPath', '~/git-local/delay-discounting-analysis/demo/data');

listOfModels = {'ModelHierarchicalME',...
	'ModelHierarchicalMEUpdated',...
	'ModelHierarchicalLogK',...
	'ModelSeparateME',...
	'ModelMixedLogK',...
	'ModelSeparateLogK'};

%% Load data
filesToAnalyse = allFilesInFolder(environment.dataPath, 'txt');
%filesToAnalyse={'AC-kirby27-DAYS.txt', 'CS-kirby27-DAYS.txt'};
%filesToAnalyse={'AC-kirby27-DAYS.txt'};
myData = DataClass(environment.dataPath, 'files', filesToAnalyse);




%% Do the analysis, loop over each of the models
for modelName = listOfModels
	makeModelFunction = str2func(modelName{:});
	models.(modelName{:}) = makeModelFunction('JAGS', myData, modelName{:},...
		'pointEstimateType','mode',...
		'mcmcSamples', numberOfMCMCSamples,...
		'chains', chains);
	models.(modelName{:}).conductInference();
	models.(modelName{:}).exportParameterEstimates();
	models.(modelName{:}).plot()
end


%% Compare hierarchical and non-hierarchical inferences for log(k) models
figure
subplot(2,1,1)
plotLOGKclusters(models.(ModelSeparateLogK).mcmc, models.(ModelSeparateLogK).data, [0.7 0 0], 'mode')
title('non-hierarchical')

subplot(2,1,2)
plotLOGKclusters(models.(ModelHierarchicalLogK).mcmc, models.(ModelHierarchicalLogK).data, [0.7 0 0], 'mode')
title('hierarchical')

subplot(2,1,2), a=axis; subplot(2,1,1), axis(a);




%% test all plot functions, without re-running fit
% h_me.plot()
% h_me_updated.plot()
% h_logk.plot()
% s_me.plot()
% s_logk.plot()








%% GAUSSIAN RANDOM WALK MODEL
% *** This model is NOT really appropriate to apply to the Kirby data, but
% I am including it here to see what it will do. ***
grw = ModelGaussianRandomWalkSimple('JAGS', myData,...
	'ModelGaussianRandomWalkSimple',...
	'pointEstimateType','mode',...
	'mcmcSamples', numberOfMCMCSamples,...
	'chains', chains);
grw.conductInference(); 
grw.plot()




% --------------------------------------------------------
%% INFERENCE WITH STAN
% --------------------------------------------------------

%% HIERARCHICAL ===========================================================

%% Separate
% sModel = ModelSeparateME('STAN', myData, 'separateME',...
% 		'pointEstimateType','mean');
% sModel.sampler.setStanHome('~/cmdstan-2.9.0')
% sModel.conductInference();
% sModel.exportParameterEstimates();
% sModel.plot()

%% Mixed
% sModel = ModelMixedME('STAN', myData, 'mixedME',...
% 		'pointEstimateType','mean');
% sModel.sampler.setStanHome('~/cmdstan-2.9.0')
% sModel.conductInference();
% sModel.exportParameterEstimates();
% sModel.plot()

%% Hierarchical  **** MODEL NOT WORKING PROPERLY ****
sModel = ModelHierarchicalME('STAN', myData, 'hierarchicalME',...
		'pointEstimateType','mean');
sModel.sampler.setStanHome('~/cmdstan-2.9.0')
sModel.conductInference();
sModel.exportParameterEstimates();
sModel.plot()


%% Hierarchical, updated  **** MODEL NOT WORKING PROPERLY ****
sModel = ModelHierarchicalMEUpdated('STAN', myData, 'hierarchicalMEupdated',...
		'pointEstimateType','mean');
sModel.sampler.setStanHome('~/cmdstan-2.9.0')
sModel.conductInference();
sModel.exportParameterEstimates();
sModel.plot()





%% LOG K ==================================================================

%% Separate
sModel = ModelSeparateLogK('STAN', myData, 'separateLogK',...
		'pointEstimateType','mean');
sModel.sampler.setStanHome('~/cmdstan-2.9.0')
sModel.conductInference();
sModel.exportParameterEstimates();
sModel.plot()

%% Mixed
sModel = ModelMixedLogK('STAN', myData, 'mixedLogK',...
		'pointEstimateType','mean');
sModel.sampler.setStanHome('~/cmdstan-2.9.0')
sModel.conductInference();
sModel.exportParameterEstimates();
sModel.plot()

%% Hierarchical **** MODEL NOT WORKING PROPERLY ****
sModel = ModelHierarchicalLogK('STAN', myData, 'hierarchicalLogK',...
		'pointEstimateType','mean');
sModel.sampler.setStanHome('~/cmdstan-2.9.0')
sModel.conductInference();
sModel.exportParameterEstimates();
sModel.plot()






%% HOW TO GET STATS VALUES
% can get summary by typing this into TERMINAL
% bin/stansummary /Users/benvincent/git-local/delay-discounting-analysis/demo/output-1.csv

sModel.sampler.stanFit.print()
% 
% 
% 
% 
% sModel.sampler.stanFit
% clf
% sModel.sampler.stanFit.print()
% 
% temp = sModel.sampler.stanFit.extract('pars','logk_group').logk_group;
% hist(temp,100)
% 
% temp = sModel.sampler.stanFit.extract('pars','epsilon_group').epsilon_group;
% hist(temp,100)
% 
% temp = sModel.sampler.stanFit.extract('pars','alpha_group').alpha_group;
% hist(temp,100)
% 
% % EXTRACT ALL
% all = sModel.sampler.stanFit.extract('permuted',true);


%stanModel.sampler.stanFit.traceplot() % use with care
