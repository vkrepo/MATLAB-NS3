classdef MatlabWifiChannel < MlWrapper
    % MatlabWifiChannel This object models a shared wireless channel for the MATLAB PHY model.
    
    %
    % Copyright (C) Vamsi.  2017-18 All rights reserved.
    %
    % This copyrighted material is made available to anyone wishing to use,
    % modify, copy, or redistribute it subject to the terms and conditions
    % of the GNU General Public License version 2.
    %
    
    properties ( Access = private, Hidden = true)
        cppHandle
    end
    
    methods
        function set(obj, val)
            obj.cppHandle = val;
        end
        
        function val = get(obj)
            val = obj.cppHandle;
        end
        
        function delete(obj)
            mexMatlabWifiChannel('delete', obj.cppHandle);
        end
        
        function obj = MatlabWifiChannel(varargin)
            % Creates MATLAB WiFi-channel object.
            
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexMatlabWifiChannel('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
    end
    
    methods (Static)
        function objND = mwcCreationFromUint64(val)
            % MATLAB wrapper around c++ MatlabWifiChannel object.
            
            objND = MatlabWifiChannel(0);
            objND.cppHandle = val;
        end
    end
end
