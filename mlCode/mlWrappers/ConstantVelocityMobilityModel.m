classdef ConstantVelocityMobilityModel < MlWrapper & MobilityModel
    % ConstantAccelerationMobilityModel This object is used to model nodes with constant velocity mobility.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_constant_velocity_mobility_model.html
    
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
            mexConstantVelocityMobilityModel('delete', obj.cppHandle);
        end
        
        function SetVelocity(obj, speed)
            mexConstantVelocityMobilityModel('SetVelocity', obj.get(), speed);
        end
        
        function obj = ConstantVelocityMobilityModel(varargin)
            switch (length(varargin))
                case 0
                    obj.cppHandle = mexConstantVelocityMobilityModel('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
    end
    
    methods (Static)
        function objND = cvmmCreationFromUint64 (val)
            % MATLAB wrapper around c++ ConstantVelocityMobilityModel object.
            
            objND = ConstantVelocityMobilityModel(0);
            objND.cppHandle = val;
        end
    end
end