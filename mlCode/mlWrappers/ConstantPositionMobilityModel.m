classdef ConstantPositionMobilityModel < MlWrapper & MobilityModel
    % ConstantPositionMobilityModel This object is used to model nodes with no movement.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_constant_position_mobility_model.html
    
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
            mexConstantPositionMobilityModel('delete', obj.cppHandle);
        end
        
        function obj = ConstantPositionMobilityModel(varargin)
            switch (length(varargin))
                case 0
                    obj.cppHandle = mexConstantPositionMobilityModel('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
    end
    
    methods (Static)
        function objND = cpmmCreationFromUint64 (val)
            % MATLAB wrapper around c++ ConstantPositionMobilityModel object.
            
            objND = ConstantPositionMobilityModel(0);
            objND.cppHandle = val;
        end
    end
end