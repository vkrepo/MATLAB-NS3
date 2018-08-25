% Visualization script for showing all vehicles, highway topology, and all
% other physical objects and events.

%
% Copyright (C) Vamsi.  2017-18 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

%% Read the log file and store in the form of matrices
clear;
global sliderVal;
sliderVal = 1;
fileID1 = fopen('../log_file.txt','r');
fileID2 = fopen('../scenarioInfo.txt','r');
fileID3 = fopen('../configInfo.txt','r');

%Format of event log file.
eventLogformatSpec = '%lf %d %d %f %f %f %f %f %d';
%Format of scenario information log file.
scenarioInfoFormatSpec = '%f %f %f %f %f %f %f %f';
%Format of config information log file.
configInfoFormatSpec = '%f %f %f %f %f %f %f';


sizeLog1 = [9,Inf];
sizeLog2 = [8,Inf];
sizeLog3 = [7,Inf];

EventTimeMatrix = fscanf(fileID1, eventLogformatSpec, sizeLog1);
ScenarioInfo = fscanf(fileID2, scenarioInfoFormatSpec, sizeLog2);
ConfigInfo = fscanf(fileID3, configInfoFormatSpec, sizeLog3);

fclose(fileID1);
fclose(fileID2);
fclose(fileID3);
%Transposing the event time matrix scanned from log file
EventTimeMatrix = EventTimeMatrix';
GridConfigMatrx = ScenarioInfo';
ConfigInfoMatrix = ConfigInfo';

numOfTrucks = ScenarioInfo(6);
numOfOtherVeh = ScenarioInfo(7);
truckLen = ScenarioInfo(8);
otherVehLength = 4;
%Graphical objects declaration
nodeObject = gobjects(numOfTrucks + numOfOtherVeh+1+1);
nodeIdTxtObjects = gobjects(numOfTrucks);

%% Create Figure axis
fig = figure();
figAxis = gca;
% Set the curent figure to have units to be normalized and the outer
% position as [0 0 1 1] i.e the actual borders of figure to be at the
% bottom left corner(0,0) and span the whole screen (1,1).
set(fig, 'Units', 'normalized', 'Position', [0 0 1 1]);
figAxis.Box = 'off';
xStart = 0;
xEnd = 1000;
yStart = -30;
yEnd = 300;
axis([xStart xEnd yStart yEnd]);
xLen = xEnd - xStart;
figXEnd = xLen;

title = title('Traffic Visualizer' );
% figAxis.DataAspectRatio = [1 1 1];
title.FontSize = 20;
title.Color = 'r';
title.FontWeight = 'bold';
xlabel('X -Location') % x-axis label
ylabel('Y -Location') % y-axis label
hold on;

%% Create push buttons
btn1 = uicontrol('Style', 'pushbutton', 'String', 'Pause',...
    'Position', [880 800 120 35],...
    'Callback', @call1);
btn1.BackgroundColor = [.5 .5 .5];
set(btn1,'Units','normalized');
hold on;

btn3 = uicontrol('Style', 'pushbutton', 'String', '1X',...
    'Position', [880 850 40 30],'Tag','pushbutton1',...
    'Callback', @call4);
btn3.BackgroundColor = [.5 .5 .5];
set(btn3,'Units','normalized');

btn6 = uicontrol('Style', 'pushbutton', 'String', '4X',...
    'Position', [1040 850 40 30],'Tag','pushbutton1',...
    'Callback', @call6);
btn6.BackgroundColor = [.5 .5 .5];
set(btn6,'Units','normalized');

btn7 = uicontrol('Style', 'pushbutton', 'String', '0.5X',...
    'Position', [800 850 40 30],'Tag','pushbutton1',...
    'Callback', @call7);
btn7.BackgroundColor = [.5 .5 .5];
set(btn7,'Units','normalized');

btn8 = uicontrol('Style', 'pushbutton', 'String', '2X',...
    'Position', [960 850 40 30],'Tag','pushbutton1',...
    'Callback', @call8);
btn8.BackgroundColor = [.5 .5 .5];
set(btn8,'Units','normalized');


%% Create slider
global sld;
sld = uicontrol('Style', 'slider',...
    'Min',0.5,'Max',4,'Value',1,... %        'SliderStep',[1/99 0.1],...
    'Position', [800 900 280 20],'Tag','slider1',...
    'Callback', @call2);
set(sld,'Units','normalized');


%% Create table for populating platoon mobility info
mobilityHeading = uicontrol('Style', 'text', 'Position',[320 (600+(28*numOfTrucks)) 280 30], 'String', 'Platoon Mobility','FontSize', 12, ...
    'FontWeight', 'bold');
set(mobilityHeading,'Units','normalized');

mobilityTable = uitable('data', zeros(numOfTrucks, 3),'Position', [320 600 280 (28*numOfTrucks)]  );
mobilityTable.ColumnName = {'Gap', 'Velocity', 'Acceleration'};
mobilityTable.ColumnEditable = false;
set(mobilityTable,'Units','normalized');

%% Create table to show key configuration parameters
configurationHeading = uicontrol('Style', 'text', 'Position',[310 535 350 30], 'String', 'Configuration Table','FontSize', 15, ...
    'FontWeight', 'bold');
set(configurationHeading,'Units','normalized');
%configTable = uitable('data', zeros(7, 1),'Position', [320 300 310 156]);
configTable = uitable('Position', [310 350 360 180]);
configTable.ColumnName = {' Values'};

configTable.RowName = ["Platoon Beacon Freq(ms)", "Platoon Failure Comm Gap", ...
    "Other Veh Pkt Freq(ms)", "TxGain Platoon", "TxGain OtherVeh", ...
    "Rough Patch Speed Lim", "Max Speed Lim"];
configTable.ColumnEditable = false;
data = get(configTable, 'Data');
% b= configList( 1, 2);
totalRows = 7;
for i=1:totalRows
    val = (ConfigInfoMatrix(1, i));
    data(i, 1) = val;
end
set(configTable, 'Data',data);
set(configTable,'Units','normalized');




%% Create table for populating Packet Counts
packetMeasureHeading = uicontrol('Style', 'text', 'Position',[1080 (600+(28*numOfTrucks)) 640 30], 'String', 'Packet Measurements','FontSize', 12, ...
    'FontWeight', 'bold');
packetTable = uitable('data', zeros(numOfTrucks, 6),'Position', [1080 600 640 (28*numOfTrucks)] , 'FontSize', 8 );
packetTable.ColumnName = {'<html><font size=3>AppTx</font size></html>', '<html><font size=3>AppRx</font size></html>', ...
    '<html><font size=3>AppRx(Preceding Truck)</font size></html>', ...
    '<html><font size=3>AppRx loss(PB)</font size></html>', ...
    '<html><font size=3>Worst Update Gap</font size></html>', ...
    '<html><font size=3>PhyRxError </font size></html>'
    };
packetTable.ColumnEditable = false;
set(packetTable,'Units','normalized');
set(packetMeasureHeading,'Units','normalized');

%% Creating Commmunication loss information table for intra platoon packets
title = uicontrol('Style', 'text', 'Position',[650 (600+(28*numOfTrucks)) 380 30], 'String', 'Intra-Platoon Communication Loss','FontSize', 12, ...
    'FontWeight', 'bold');
commLossTable = uitable('data', zeros(numOfTrucks, 4),'Position', [650 600 380 (28*numOfTrucks)] , 'FontSize', 8 );
commLossTable.ColumnName = {'<html><font size=3>2 Pkts burst</font size></html>', ...
    '<html><font size=3>3 Pkts burst</font size></html>', ...
    '<html><font size=3>4 Pkts burst</font size></html>', ...
    '<html><font size=3> >=5 Pkts burst </font size></html>', ...
    };
commLossTable.ColumnEditable = false;
set(commLossTable,'Units','normalized');
set(title,'Units','normalized');

%% Drawing highway topology and all its lanes

laneCount = ScenarioInfo(1,1);
laneWidth = ScenarioInfo(2,1);
highwayLength = ScenarioInfo(3,1);
roughPatchStart = ScenarioInfo(4,1);
roughPatchLen = ScenarioInfo(5,1);

xCor=0;
yCor=0;
laneInfo = {'Platoon Lane ', 'Non-Platoon Lane:1', 'Non-Platoon Lane:2', 'Non-Platoon Lane:3'};
% Draw each lane
for laneIndex=1:(laneCount+1)
    line([xCor (xCor+highwayLength)], [yCor yCor],'LineWidth',3,'Color',[0 0 1]);
    if(laneIndex <= laneCount)
        text(xCor, yCor + 4, laneInfo{laneIndex}, 'Fontsize', 8, 'FontWeight', 'bold', 'Color', 'magenta');
    end
    yCor = yCor + laneWidth;
end

% Draw rough patch
rectangle('Position', [roughPatchStart, 0, roughPatchLen, laneWidth], ...
    'FaceColor', [0 0.5 0.5]);

text(roughPatchStart + roughPatchLen/3,-6, 'Rough Patch', 'Color', 'blue', 'Fontsize', 15, 'FontWeight', 'bold');

drawnow limitrate
hold on
[row, column] = size(EventTimeMatrix);
pause(3);
hold on;
ii = 1;
platoonFailureCount=0;

%% Scanning through each row of event matrix with each row being a separate event
%  Events are classified based on event type and displayed in visualizer
%  window
while(ii< row)
    global slid;
    global restart;
    % Vehicle Entry event
    if(EventTimeMatrix(ii,2) == 1)
        if(EventTimeMatrix(ii,3) >= numOfTrucks)
            color = 'black';
            size = otherVehLength;
        else
            color = 'yellow';
            size = truckLen;
        end
        nodeObject(EventTimeMatrix(ii,3)+1) = rectangle('Position', [EventTimeMatrix(ii,4) ...
            EventTimeMatrix(ii,5)-1, size, 4], 'FaceColor', ...
            color);
        if(EventTimeMatrix(ii,3) < numOfTrucks)
            nodeIdTxtObjects(EventTimeMatrix(ii,3) + 1) = text('Position', ...
                [EventTimeMatrix(ii,4)+2 EventTimeMatrix(ii,5)+1], ...
                'string' , num2str(EventTimeMatrix(ii,3)+1), ...
                'FontSize', 6, 'FontWeight', 'bold');
        end
        
        drawnow limitrate
        % Update position of nodes
    elseif(EventTimeMatrix(ii,2) == 2)
        if(EventTimeMatrix(ii,3) >= numOfTrucks)
            size = otherVehLength;
        else
            size = truckLen;
        end
        nodeObject(EventTimeMatrix(ii,3)+1).Position = [EventTimeMatrix(ii,4) ...
            EventTimeMatrix(ii,5)-1 size 4];
        % Shift the start of X-axis as a platoon truck has reached the current X limit
        if(EventTimeMatrix(ii,3) < numOfTrucks)
            if(EventTimeMatrix(ii,3) < numOfTrucks)
                nodeIdTxtObjects(EventTimeMatrix(ii,3) + 1).Position = ...
                    [EventTimeMatrix(ii,4)+2 EventTimeMatrix(ii,5)+1];
                
            end
            if(EventTimeMatrix(ii,4) > figXEnd )
                ax = gca;
                figShift = xLen; % Shifting X-axis by half of the current len
                ax.XLim = [(figXEnd-(xLen - figShift)) (figXEnd + figShift)];
                figXEnd =  figXEnd+figShift;
            end
        end
        drawnow limitrate
        % Update mobilty info tabe
    elseif(EventTimeMatrix(ii,2) == 3)
        nodeId = EventTimeMatrix(ii,3);
        gap  = EventTimeMatrix(ii,4);
        speed = EventTimeMatrix(ii,5);
        acceleration= EventTimeMatrix(ii,6);
        data = get(mobilityTable, 'Data');
        data(nodeId+1,1) = uint32(gap);
        data(nodeId+1,2) = uint32(speed);
        data(nodeId+1,3) = int32(acceleration);
        set(mobilityTable, 'Data',data);
        % Update packet count table
    elseif(EventTimeMatrix(ii,2) == 4)
        
        nodeId = EventTimeMatrix(ii,3);
        txCount  = EventTimeMatrix(ii,4);
        rxCount = EventTimeMatrix(ii,5);
        precedingRxCount= EventTimeMatrix(ii,6);
        precedingRxLossPBCount= EventTimeMatrix(ii,7);
        data = get(packetTable, 'Data');
        data(nodeId+1, 1) = txCount;
        data(nodeId+1, 2) = rxCount;
        data(nodeId+1, 3) = precedingRxCount;
        data(nodeId+1, 4) = precedingRxLossPBCount;
        data(nodeId+1, 5) = EventTimeMatrix(ii,8);
        data(nodeId+1, 6) = EventTimeMatrix(ii,9);
        set(packetTable, 'Data',data);
        % RSU installation
    elseif(EventTimeMatrix(ii,2) == 5)
        base = 20;
        height = 7;
        EventTimeMatrix(ii,4) = EventTimeMatrix(ii,4) - base;
        nodeObject(EventTimeMatrix(ii,3)+1) = patch([EventTimeMatrix(ii,4) EventTimeMatrix(ii,4) + base/2 EventTimeMatrix(ii,4) + base], ...
            [-3  height-3  -3], 'green');
        text(EventTimeMatrix(ii,4)-4 , -10,'RSU','Color','magenta','Fontsize',15,'FontWeight', 'bold');
        drawnow limitrate
        
        % Show intra-platoon communication loss
    elseif(EventTimeMatrix(ii,2) == 7)
        data = get(commLossTable, 'Data');
        data(EventTimeMatrix(ii,3)+1, 1) = EventTimeMatrix(ii,4);
        data(EventTimeMatrix(ii,3)+1, 2) = EventTimeMatrix(ii,5);
        data(EventTimeMatrix(ii,3)+1, 3) = EventTimeMatrix(ii,6);
        data(EventTimeMatrix(ii,3)+1, 4) = EventTimeMatrix(ii,7);
        set(commLossTable, 'Data',data);
        
        % Safe to Unsafe zone transition of trucks
    elseif(EventTimeMatrix(ii,2) == 8)
        nodeObject(EventTimeMatrix(ii,3)+1).FaceColor = 'red';
        % UnSafe to safe zone transition of trucks
    elseif(EventTimeMatrix(ii,2) == 9)
        nodeObject(EventTimeMatrix(ii,3)+1).FaceColor = 'yellow';
        % Platoon Failure
    elseif(EventTimeMatrix(ii,2) == 6)
        str = '** PLATOON FAILURE: Communication lost at truck: ';
        node = num2str(EventTimeMatrix(ii,3)+1);
        str = strcat(str, node);
        str = strcat(str, ' ** ');
        nodeObject(numOfTrucks + numOfOtherVeh+1+1) = text(300, 100 -(12*platoonFailureCount) , str, 'Fontsize', 15, 'Color', 'red', 'FontWeight', 'bold');
        platoonFailureCount = platoonFailureCount+1;
        %break;
        
    end
    
    if(slid == 1)
        slid = 0;
        h1 = findobj('Tag','slider1');
        sliderVal = get(h1,'val');
    end
    pause((EventTimeMatrix(ii+1,1) - EventTimeMatrix(ii,1))/(1.5*sliderVal));
    ii = ii+1;
end
clear all;
%% Button press event callbacks

function call1(source,event)
val = source.String;
if(strcmp(val,'Pause'))
    source.String = 'Play';
    uiwait();
elseif(strcmp(val,'Play'))
    source.String = 'Pause';
    uiresume();
end

end

function call2(source,event1)
global slid;
global sld;
val = get(sld,'value');
new_val = round(val);
source.Value = new_val;
slider_val = new_val;
data = struct('val',slider_val);
source.UserData = data;
set(sld,'Value',val);
slid = 1;

end

function call4(source,event4)
global sld;
global sliderVal;
sliderVal = 1;
set(sld, 'Value', 1);
end


function call6(source,event4)
global sld;
global sliderVal;
sliderVal = 4;
set(sld, 'Value', 4);
end

function call7(source,event4)
global sld;
global sliderVal;
sliderVal = 0.5;
set(sld, 'Value', 0.5);
end

function call8(source,event4)
global sld;
global sliderVal;
sliderVal = 2;
set(sld, 'Value', 2);
end

