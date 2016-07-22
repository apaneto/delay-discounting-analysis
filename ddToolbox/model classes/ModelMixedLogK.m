classdef ModelMixedLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)

    		function obj = ModelMixedLogK(data, varargin)

            obj = obj@Model(data, varargin{:});

			obj.modelType = 'mixedLogK';
			obj.discountFuncType = 'logk';

			% 'Decorate' the object with appropriate plot functions
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;
			obj.plotFuncs.plotGroupLevel = @plotGroupLevelStuff;
			obj.plotFuncs.clusterPlotFunc = @plotLOGKclusters;
			
			%% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
            obj.varList.participantLevelPriors = {'logk_group_prior','alpha_group_prior','epsilon_group_prior'};
			obj.varList.groupLevel = {'logk_group','alpha_group','epsilon_group'};
			obj.varList.monitored = {'logk','alpha','epsilon',...
				'logk_group','alpha_group','epsilon_group',...
				'logk_group_prior','epsilon_group_prior','alpha_group_prior',...
				'groupW','groupK','groupALPHAmu','groupALPHAsigma',...
				'groupLogKmu_prior', 'groupLogKsigma_prior','groupW_prior','groupK_prior','groupALPHAmu_prior','groupALPHAsigma_prior',...
				'Rpostpred', 'P'};
		end

		% Generate initial values of the leaf nodes
		function obj = setInitialParamValues(obj)
			nParticipants = obj.data.nParticipants;
			for chain = 1:obj.sampler.mcmcparams.nchains
				obj.initialParams(chain).groupW             = rand;
				obj.initialParams(chain).groupALPHAmu		= rand*100;
				obj.initialParams(chain).groupALPHAsigma	= rand*100;
			end
		end

		function conditionalDiscountRates(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end

		function conditionalDiscountRates_GroupLevel(obj, reward, plotFlag)
			error('Not applicable to this model that calculates log(k)')
		end


	end

	methods (Access = protected)
		
		function obj = calcDerivedMeasures(obj)
		end
		
	end
	
end
