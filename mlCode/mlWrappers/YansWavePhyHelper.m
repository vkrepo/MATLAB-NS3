classdef YansWavePhyHelper < MlWrapper & YansWifiPhyHelper
    % YansWavePhyHelper This object is used to create and manage Yans WAVE PHY object.
    % More details at https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_yans_wave_phy_helper.html
    
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
            mexYansWavePhyHelper('delete', obj.cppHandle);
        end
        
        function obj = YansWavePhyHelper(varargin)
            switch (length(varargin))
                case 0
                    obj.cppHandle = mexYansWavePhyHelper('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
    end
    
    methods (Static)
        function objND = Default()
            objND = YansWavePhyHelper(0);
            objND.cppHandle = mexYansWavePhyHelper('Default');
        end
    end
end