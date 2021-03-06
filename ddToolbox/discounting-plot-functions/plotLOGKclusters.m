function plotLOGKclusters(mcmcContainer, data, col, pointEstimateType, savePath, modelType, shouldExportPlots)

% TODO:
% remove input:
% - mcmcContainer, just pass in the data
% - data, just pass in 
% rename to plotUnivariateDistributions

% plot posteriors over log(k) for all participants

figure(12), clf

%% REAL EXPERIMENT DATA
% build samples
for p = 1:data.nExperimentFiles
	logkSamples(:,p) = mcmcContainer.getSamplesFromExperimentAsMatrix(p, {'logk'});
end

uniG1 = mcmc.UnivariateDistribution(logkSamples(:,[1:data.nRealExperimentFiles]),...
    'xLabel', '$\log(k)$',...
    'plotHDI', false,...
	'pointEstimateType', pointEstimateType,...
	'patchProperties',definePlotOptions4Participant(col));

% keep axes zoomed in on all participants
axis tight
participantAxisBounds = axis;

%% GROUP LEVEL (UNOBSERVED PARTICIPANT)
%if size(logkSamples,2) == data.nExperimentFiles+1
groupLogkSamples = logkSamples(:,data.nExperimentFiles);

if data.unobservedPartipantPresent && ~any(isnan(groupLogkSamples))
	mcmc.UnivariateDistribution(groupLogkSamples,...
		'xLabel', '$\log(k)$',...
		'plotHDI', false,...
		'pointEstimateType', pointEstimateType,...
		'patchProperties', definePlotOptions4Group(col));
end

%% Formatting
set(gca,'PlotBoxAspectRatio',[3,1,1])
axis(participantAxisBounds)
% set(gca,'XAxisLocation','origin',...
% 	'YAxisLocation','origin')
drawnow

if shouldExportPlots
	myExport(savePath, 'summary_plot',...
		'suffix', modelType)
end


	function plotOpts = definePlotOptions4Participant(col)
		plotOpts = {'FaceAlpha', 0.2,...
			'FaceColor', col,...
			'LineStyle', 'none'};
	end

	function plotOpts = definePlotOptions4Group(col)
		plotOpts = {'FaceColor', 'none',...
			'EdgeColor', col/2,...
			'LineWidth', 3};
	end
end
