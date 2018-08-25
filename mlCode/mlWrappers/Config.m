classdef Config < handle
    % Config This object is used to configure the attributes of any model used in the simulation and also to set the trace callback.
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    methods (Access = public, Static)
        function Connect(componentName, event, callback)
            % Connects the traces as a MATLAB callback from NS-3.
            
            mexConfig('Connect', componentName, event, func2str(callback));
        end
        function Set(componentName, param, value)
            % Set the attributes of a model while simulation is running.
            
            mexConfig('Set', componentName, param, value.get());
        end
        
        function SetDefault(param, value)
            % Set the default attributes to a model.
            
            mexConfig('SetDefault', '', strcat('ns3::', param), value.get());
        end
    end
end
