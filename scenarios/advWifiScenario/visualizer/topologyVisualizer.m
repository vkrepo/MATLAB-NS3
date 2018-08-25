%% Topology related script

%
% Copyright (C) Vamsi.  2017-18 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

clear;
fileID = fopen('../stats_file.txt','r');
configFileID = fopen('../config.txt','r');
configFormatSpec = '%f %f %f %d %d';
%Format in which each line of log file should be parsed.
formatSpec = '%d %d %d %d %d %d ';
sizeLog = [6,Inf];
sizeConfigLog = [1,Inf];
StatsTimeMatrix = fscanf(fileID,formatSpec,sizeLog);
configValueMatrix = fscanf(configFileID,configFormatSpec,sizeConfigLog);
numOfStats =  3;
fclose(fileID);
%Transposing the event time matrix scanned from log file
StatsTimeMatrix = StatsTimeMatrix';
TxRxPacketsMatrix = StatsTimeMatrix(:,4:5);
RxDropMatrix =StatsTimeMatrix(:,6);
MacRxMatrix = StatsTimeMatrix(:,2);
PlotMatrix = [TxRxPacketsMatrix RxDropMatrix MacRxMatrix];
%PacketsDroppedMatrix = StatsTimeMatrix(:,3:4);
% matrix = [TxRxPacketsMatrix;PacketsDroppedMatrix];
fig=figure();
figAxis = gca;

Distance = configValueMatrix(1);
TxGain = configValueMatrix(2);
RxGain = configValueMatrix(3);
noOfNodes = configValueMatrix(4);
noOfAPs = configValueMatrix(5);
string = sprintf("Distance:%f\nTxGain   :%f\nRxGain   :%f\n",Distance,TxGain,RxGain);

[row,column] = size(StatsTimeMatrix);
annotation('textbox',[.15 .6 .6 .3],'String',string,'FitBoxToText','on','BackgroundColor',[0.9  0.9 0.9]);


set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]);
x = 1:1:row;
%subplot(2,2,1);
h=bar(x,PlotMatrix,'histc');
h(4).FaceColor = 'magenta';
h(4).EdgeColor = 'magenta';
h(3).FaceColor = 'red';
h(3).EdgeColor = 'red';
h(2).FaceColor = 'green';
h(2).EdgeColor = 'green';
% set(h,'FaceColor','r');
legend('Phy Tx','Phy Rx','Phy Drop','Mac Rx');
title('Node id versus their TX/RX packets');
xlabel('Node ids') % x-axis label
ylabel('Tx/Rx packets') % y-axis label
xticks(1:1:noOfNodes+noOfAPs);
% xtickformat('sta%,.0f');
station = strings(100);
for i = 1:noOfNodes
    station{i} = ['sta' '-' num2str(i-1,'%d')];
end
for i = noOfNodes+1:noOfNodes+noOfAPs
    station{i} = ['ap' '-' num2str(i-noOfNodes-1,'%d')];
end
figAxis.XTickLabel = station;
xtickangle(45);


