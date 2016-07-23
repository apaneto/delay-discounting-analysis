classdef ModelSeparateLogK < Model
	%ModelHierarchical A model to estimate the magnitide effect
	%   Detailed explanation goes here

	properties
	end


	methods (Access = public)

		function obj = ModelSeparateLogK(data, varargin)
			obj = obj@Model(data, varargin{:});

			obj.modelType = 'separateLogK';
			obj.discountFuncType = 'logk';

			% 'Decorate' the object with appropriate plot functions
			obj.plotFuncs.participantFigFunc = @figParticipantLOGK;
			%obj.plotFuncs.plotGroupLevel = @(x) []; % null function
			obj.plotFuncs.clusterPlotFunc = @plotLOGKclusters;

			%% Create variables
			obj.varList.participantLevel = {'logk','alpha','epsilon'};
			%obj.varList.participantLevelPriors = {'logk_prior','alpha_prior','epsilon_prior'};
			%obj.varList.groupLevel = {};
			obj.varList.monitored = {'logk','alpha','epsilon',...
				'Rpostpred', 'P'};
		end

		function obj = setInitialParamValues(obj)
            % Generate initial values of the leaf nodes
			nParticipants = obj.data.nParticipants;
			for chain = 1:obj.sampler.mcmcparams.nchains
				obj.initialParams(chain).logk = normrnd(log(1/365),10, [nParticipants+1,1]);
				obj.initialParams(chain).epsilon = 0.1 + rand([nParticipants+1,1])/10;
				obj.initialParams(chain).alpha = abs(normrnd(0.01,10,[nParticipants+1,1]));
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
