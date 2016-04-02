
toolboxPath = setToolboxPath('/Users/benvincent/git-local/delay-discounting-analysis/ddToolbox')
cd('/Users/benvincent/git-local/delay-discounting-analysis/demo')
setPlotTheme

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

pathToData='data';
myData = DataClass(pathToData);
myData.loadDataFiles(fnames);
saveFolder = 'methodspaper-kirby27';

%% ModelHierarchical
stanModel = ModelHierarchical(toolboxPath, 'STAN', myData, saveFolder);
clc
stanModel.conductInference();
stanModel.sampler.stanFit

temp = stanModel.sampler.stanFit.extract('pars','logk_group').logk_group;
hist(temp,100)



%% ModelHierarchicalNOMAG
stanModel = ModelHierarchicalNOMAG(toolboxPath, 'STAN', myData, saveFolder);
clc
stanModel.conductInference();

stanModel.sampler.stanFit
stanModel.sampler.stanFit.print()

temp = stanModel.sampler.stanFit.extract('pars','logk_group').logk_group;
hist(temp,100)

%stanModel.sampler.stanFit.traceplot() % use with care