%%Topology related script

%
% Copyright (C) Vamsi.  2017-18 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

clear;
logFileID = fopen('../log_file.txt','r');
gridFileID = fopen('../scenario_info.txt','r');

%Format in which each line of log file should be parsed.
eventLogFormat = '%lf %d %d %f %f %f %d %d %d';
scenarioInfoLogformat = '%f %f %f %f %f %f %f';

sizeEventLog = [9,Inf];
sizeScenarioInfoLog = [7,Inf];

% Reading log files into matrices
eventMatrix = fscanf(logFileID, eventLogFormat, sizeEventLog);
scenarioInfoMatrix = fscanf(gridFileID, scenarioInfoLogformat, sizeScenarioInfoLog);

fclose(logFileID);
fclose(gridFileID);

eventMatrix = eventMatrix';
%GridConfigMatrx = scenarioInfoMatrix';
numOfVehicles = scenarioInfoMatrix(6);
numOfRogueVehicles = scenarioInfoMatrix(7);
numOfHazards = 1;
%Graphical objects creation
nodeObject = gobjects(numOfVehicles +numOfHazards +numOfRogueVehicles );

%% Create figure
fig = figure();
% Create Figure axis
figAxis = gca;
% Set the curent figure to have units to be normalized and the outer
% position as [0 0 1 1] i.e the actual borders of figure to be at the
% bottom left corner(0,0) and span the whole screen (1,1).
set(fig, 'Units', 'normalized', 'Position', [0 0 1 1]);
figAxis.Box = 'off';
axis([-290 840 -60 580]);

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
    'Position', [880 820 120 35],...
    'Callback', @call1);
btn1.BackgroundColor = [.5 .5 .5];
set(btn1,'Units','normalized');
hold on;

btn3 = uicontrol('Style', 'pushbutton', 'String', '1X',...
    'Position', [880 870 40 30],'Tag','pushbutton1',...
    'Callback', @call2);
btn3.BackgroundColor = [.5 .5 .5];
set(btn3,'Units','normalized');


btn6 = uicontrol('Style', 'pushbutton', 'String', '4X',...
    'Position', [1040 870 40 30],'Tag','pushbutton1',...
    'Callback', @call3);
btn6.BackgroundColor = [.5 .5 .5];
set(btn6,'Units','normalized');

btn7 = uicontrol('Style', 'pushbutton', 'String', '0.5X',...
    'Position', [800 870 40 30],'Tag','pushbutton1',...
    'Callback', @call4);
btn7.BackgroundColor = [.5 .5 .5];
set(btn7,'Units','normalized');

btn8 = uicontrol('Style', 'pushbutton', 'String', '2X',...
    'Position', [960 870 40 30],'Tag','pushbutton1',...
    'Callback', @call5);
btn8.BackgroundColor = [.5 .5 .5];
set(btn8,'Units','normalized');


%% Create slider
global sld;
sld = uicontrol('Style', 'slider',...
    'Min',0.5,'Max',4,'Value',1,... %        'SliderStep',[1/99 0.1],...
    'Position', [800 920 280 20],'Tag','slider1',...
    'Callback', @call6);
set(sld,'Units','normalized');

%% Event log Box creation
eventLog = uicontrol('Style', 'text', 'Position',[320 750 280 20], 'String', 'EVENT LOG', ...
    'FontSize', 12, 'FontWeight', 'bold', 'backgroundColor', [.8 .8 .8]);
log_box = uicontrol('Style','edit','Position',[320 200 280 550],'FontSize',8,...
    'HorizontalAlignment','left','min',0,'max',2,'enable','inactive');
set(log_box,'backgroundcolor',[211,211,211]/255);
set(log_box,'foregroundColor','black');
set(eventLog,'Units','normalized');
set(log_box,'Units','normalized');
%% Packet count table
packetMeasureHeading = uicontrol('Style', 'text', 'Position',[1250 (570+(22*(numOfVehicles + ...
    numOfHazards))) 420 30], 'String', 'Packet Measurements','FontSize', ...
    12, 'FontWeight', 'bold', 'backgroundColor', [.8 .8 .8]);
packetTable = uitable('data', zeros(numOfVehicles + numOfHazards, 5),'Position', ...
    [1250 570 420 (22*(numOfVehicles + numOfHazards))]  );
%'<html><font size=3>AppTx</font size></html>'
packetTable.ColumnName = {'<html><font size=2>AppTx</font size></html>', ...
    '<html><font size=2>AppTx (Hazard)</font size></html>', ...
    '<html><font size=2>AppRx</font size></html>', ...
    '<html><font size=2>AppRx (Hazard)</font size></html>', ...
    '<html><font size=2>Rx Error</font size></html>'
    };
packetTable.ColumnEditable = false;
set(packetMeasureHeading,'Units','normalized');
set(packetTable,'Units','normalized');
%% Success/Failure count table
sucFaiEvent = uicontrol('Style', 'text', 'Position',[1250 430 380 40], 'String', 'Sucess/Failure Events','FontSize', 12, ...
    'FontWeight', 'bold', 'backgroundColor', [.8 .8 .8]);
sucFailTable = uitable('data', zeros(1, 3),'Position', [1250 400 380 50]  );
sucFailTable.ColumnName = {'Hazard Avoidance','Hazard Stoppages','Hazard Collision'};
sucFailTable.ColumnEditable = false;
set(sucFaiEvent,'Units','normalized');
set(sucFailTable,'Units','normalized');

%% Creating manhattan grid
verticalBlocks = scenarioInfoMatrix(1,1);
horizontalBlocks = scenarioInfoMatrix(2,1);
laneWidth=scenarioInfoMatrix(3,1);
blockSize = scenarioInfoMatrix(4,1);


for i=1:horizontalBlocks
    for j=1:verticalBlocks
        xCor = ((i-1)*(2*laneWidth + blockSize));
        yCor = ((j-1)*(2*laneWidth + blockSize));
        
        % Drawing rectangular blocks %
        rectangle('Position',[xCor yCor blockSize blockSize],'FaceColor',[0 .5 .5],'EdgeColor','w','LineWidth', 6);
        
        % Dividing inter-block area into 2 opposite direction roads
        if(j < verticalBlocks)
            line([xCor (xCor+blockSize) ], [(yCor+blockSize+laneWidth) (yCor+blockSize+laneWidth)],'LineWidth',3);
        end
        if(i < horizontalBlocks)
            line([(xCor+blockSize+laneWidth) (xCor+blockSize+laneWidth)], [yCor (yCor+blockSize)],'LineWidth',3);
        end
        
        % Showing Road Directions surrounding the block
        
        % Drawing arrow below the block
        if(j~=1)
            p1 =  [(xCor+blockSize) (yCor-(laneWidth/2))];
            p2 = [xCor (yCor-(laneWidth/2))];
            dp = p2-p1;
            quiver(p1(1), p1(2), dp(1), dp(2), 'color',[0.8 0.5 0.5], 'MaxHeadSize', .3);
            
        end
        
        % Drawing arrow right to the block
        if(i~= horizontalBlocks)
            p1 = [xCor+blockSize+(laneWidth/2) (yCor + blockSize)];
            p2 = [xCor+blockSize+(laneWidth/2) yCor];
            dp = p2-p1;
            quiver(p1(1), p1(2), dp(1), dp(2), 'color', [0.8 .5 .5], 'MaxHeadSize', .3);
        end
        
        % Drawing arrow above the block
        if(j~= verticalBlocks)
            p1 = [xCor (yCor + blockSize+laneWidth/2)];
            p2 = [xCor+blockSize (yCor + blockSize+laneWidth/2)];
            dp = p2-p1;
            quiver(p1(1),p1(2),dp(1),dp(2),'color',[.8 .5 .5],'MaxHeadSize', .3);
            
        end
        
        if(i~=1)
            % Drawing arrow left to the block
            p1 = [xCor-(laneWidth/2) (yCor)];
            p2 = [xCor-(laneWidth/2) (yCor + blockSize)];
            dp = p2-p1;
            quiver(p1(1),p1(2),dp(1),dp(2),'color',[.8 .5 .5],'MaxHeadSize',.3);
        end
        
    end
end

drawnow limitrate
hold on
row = size(eventMatrix, 1);
pause(3);
%j=1;
ii = 1;
hold on;

str = '';
line_no = 0;
global sliderVal;
sliderVal = 1;
global slid;
%% Sequentially read events from event matrix and display them
while(ii< row)
    % Vehicle creation on event
    if (eventMatrix(ii,2) == 1)
        nodeId = eventMatrix(ii,3);
        if(nodeId >= numOfVehicles && ....
                nodeId <numOfVehicles+numOfRogueVehicles) % Rogue Vehicles
            nodeObject(eventMatrix(ii,3)+1) = rectangle('Position',[eventMatrix(ii,4), ...
                eventMatrix(ii,5), 1, 2], 'FaceColor', 'black');
        else
            nodeObject(eventMatrix(ii,3)+1) = text(eventMatrix(ii,4), ...
                eventMatrix(ii,5),num2str(eventMatrix(ii,3)+1),'Color','blue', ...
                'Fontsize', 8, 'Fontweight', 'bold','HorizontalAlignment', 'center');
        end
        drawnow limitrate
        % Hazard Entry  Event
    elseif(eventMatrix(ii,2) == 2)
        nodeObject(eventMatrix(ii,3)+1) = text(eventMatrix(ii,4),eventMatrix(ii,5),'X','Color','red','Fontsize',12, ...
            'Fontweight', 'bold', 'HorizontalAlignment', 'center');
        drawnow limitrate
        
        % Update position of vehicles
    elseif(eventMatrix(ii,2) == 3)
        nodeId = eventMatrix(ii,3);
        if(nodeId >= numOfVehicles && ....
                nodeId <numOfVehicles+numOfRogueVehicles) % Rogue Vehicles
            nodeObject(nodeId+1).Position = [eventMatrix(ii,4), ...
                eventMatrix(ii,5), 1, 2];
        else
            set(nodeObject(nodeId+1),'Position',[eventMatrix(ii,4) eventMatrix(ii,5)]);
        end
        drawnow limitrate
        % Show vehicle stopping due to hazard.
    elseif(eventMatrix(ii,2) == 4)
        string = sprintf('\n T = %fs: Vehicle Id = %d stopped due to hazard \n',eventMatrix(ii,1),eventMatrix(ii,3)+1);
        str = strcat(str,string);
        log_box.String = '';
        set(log_box,'String',str); % display the string
        line_no = line_no+1;
        set(nodeObject(eventMatrix(ii,3)+1), 'Color', 'red');
        
        % Hazard Avoidance event by re-routing
    elseif(eventMatrix(ii,2) == 5)
        string = sprintf('\n T= %fs: Vehicle Id = %d re-routed to avoid hazard \n',eventMatrix(ii,1),eventMatrix(ii,3)+1);
        str = strcat(str,string);
        log_box.String = '';
        set(log_box,'String',str); % display the string
        line_no = line_no+1;
        
        % Update packet counts
    elseif(eventMatrix(ii,2) == 6)
        
        nodeId = eventMatrix(ii,3);
        % Not adding rogue vehicle's pkt count  to table
        if(nodeId < numOfVehicles || nodeId>=numOfVehicles+numOfRogueVehicles)
            if(nodeId >= (numOfVehicles+numOfRogueVehicles))% if hazard
                rowNum = nodeId+1 - numOfRogueVehicles;
            else
                rowNum = nodeId+1;
            end
            txCount  = eventMatrix(ii,4);
            rxCount = eventMatrix(ii,5);
            warningTxCount =  eventMatrix(ii,6);
            warningRxCount= eventMatrix(ii,7);
            phyRxErrorCount = eventMatrix(ii,8);
            %macRxErrorCount = EventTimeMatrix(ii,9);
            data = get(packetTable, 'Data');
            data(rowNum, 1) = txCount;
            data(rowNum, 2) = rxCount;
            data(rowNum, 3) = warningTxCount;
            data(rowNum, 4) = warningRxCount;
            data(rowNum, 5) = phyRxErrorCount;
            %data(nodeId+1, 6) = macRxErrorCount;
            set(packetTable, 'Data',data);
        end
        % Delete vehicle (Used for showing removal of hazard)
    elseif(eventMatrix(ii,2) == 7)
        delete(nodeObject(eventMatrix(ii,3)+1));
        % Update success failure count
    elseif(eventMatrix(ii,2) == 8)
        hazardAvoidance = eventMatrix(ii,3);
        hazardStoppage  = eventMatrix(ii,4);
        hazardCollision = eventMatrix(ii,5);
        
        data = get(sucFailTable, 'Data');
        data(1, 1) = hazardAvoidance;
        data(1, 2) = hazardStoppage;
        data(1, 3) = hazardCollision;
        
        set(sucFailTable, 'Data',data);
        % Show 'collision with hazard event'
    elseif(eventMatrix(ii,2) == 9)
        %delete(nodeObject(EventTimeMatrix(ii,3)+1));
        string = sprintf('\n T = %fs: COLLISION: Vehicle Id=%d  with hazard \n',eventMatrix(ii,1),eventMatrix(ii,3)+1);
        str = strcat(str,string);
        log_box.String = '';
        set(log_box,'String',str); % display the string
        line_no = line_no+1;
        set(nodeObject(eventMatrix(ii,3)+1),'String','X', 'Color', 'black', 'Fontsize',6+randi(8));
    end
    
    if(slid == 1)
        slid = 0;
        h1 = findobj('Tag','slider1');
        sliderVal = get(h1,'val');
    end
    pause((eventMatrix(ii+1,1) - eventMatrix(ii,1))/(sliderVal));
    
    if(line_no == 100) %  In event log showing only last 100 lines.
        currString = get(log_box,'String');
        currString = currString(3:100,:);
        log_box.String = '';
        set(log_box,'String',currString); % display the string
        line_no = 0;
    end
    ii = ii+1;
end


%% Implementing buttons and slider event action
% Play/pause push button event
function call1(source, event)
val = source.String;
if(strcmp(val,'Pause'))
    source.String = 'Play';
    uiwait();
elseif(strcmp(val,'Play'))
    source.String = 'Pause';
    uiresume();
end

end


% Push button event for 1X speed
function call2(source, event4)
global sld;
global sliderVal;
sliderVal = 1;
set(sld, 'Value', 1);
end

% Push button event for 4X speed
function call3(source, event4)
global sld;
global sliderVal;
sliderVal = 4;
set(sld, 'Value', 4);
end

% Push button event for 0.5X speed
function call4(source, event4)
global sld;
global sliderVal;
sliderVal = 0.5;
set(sld, 'Value', 0.5);
end

% Push button event for 6X speed
function call5(source, event4)
global sld;
global sliderVal;
sliderVal = 2;
set(sld, 'Value', 2);
end


% Slider movement event
function call6(source, event1)
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
