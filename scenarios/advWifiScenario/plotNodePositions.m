function plotNodePositions(initX, initY, deltaX, deltaY, gridWidth, layoutType, numNodes, prefix)
% getGridPositions(INITX, INITY, DELTAX, DELTAY, GRIDWIDTH, LAYOUTTYPE,
% NUMNODES, PREFIX) plots the grid layout based on the given inputs.
%
% Input parameters list:
% INITX initial x position of the grid.
% INITY initial y position of the grid.
% DELTAX the gap between each node in X direction.
% DELTAY the gap between each node in Y direction.
% GRIDWIDTH number of nodes per row or column based on layout type.
% LAYOUTTYPE arranges nodes in row-wise for RowFirst or column-wise for
%       ColumnFirst layout type.
% NUMNODES number of nodes in the grid.
% PREFIX name prefix for each node in the grid.

%
% Copyright (C) Vamsi.  2017-18 All rights reserved.
%
% This copyrighted material is made available to anyone wishing to use,
% modify, copy, or redistribute it subject to the terms and conditions
% of the GNU General Public License version 2.
%

count = 0;
for i = 1:(numNodes)
    % Get the positions of each node in the grid.
    switch(layoutType)
        case 'RowFirst'
            % Arrange nodes row by row.
            x(count + 1) = initX + deltaX*(mod(count, gridWidth));
            y(count + 1) = initY + deltaY*(floor(count/gridWidth));
        case 'ColumnFirst'
            % Arrange nodes column by column.
            x(count + 1) = initX + deltaX*(floor(count/gridWidth));
            y(count + 1) = initY + deltaY*(mod(count, gridWidth));
        otherwise
            error('getGridPosition: Invalid layout type');
    end
    count = count + 1;
end
grid on;
% Plot x,y positions of each node.
plot(x,y,'o','MarkerSize',15,'MarkerFaceColor',[rand rand rand]);
% Get current figure.
ax1 = gca;
% Disable the x and y axis.
ax1.YAxis.Visible = 'off';
ax1.XAxis.Visible = 'off';
for i = 1:numNodes
    % Assign unique name to each node in the grid.
    str1 = strcat(prefix, num2str(i-1));
    text(x(i),y(i),str1,'VerticalAlignment','top','HorizontalAlignment','left')
end
end
