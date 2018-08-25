classdef ConstantAccelerationMobilityModel < MlWrapper & MobilityModel
    % ConstantAccelerationMobilityModel This object is used to model nodes with constant acceleration mobility.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_constant_acceleration_mobility_model.html
    
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
            mexConstantAccelerationMobilityModel('delete', obj.cppHandle);
        end
        
        function SetVelocityAndAcceleration(obj, velocity, acceleration)
            mexConstantAccelerationMobilityModel('SetVelocityAndAcceleration', obj.get(), velocity, acceleration);
        end
        
        function obj = ConstantAccelerationMobilityModel(varargin)
            switch (length(varargin))
                case 0
                    obj.cppHandle = mexConstantAccelerationMobilityModel('new');
                otherwise
                    obj.cppHandle = 0;
            end
        end
    end
    
    methods (Static)
        function objND = cammCreationFromUint64 (val)
            % MATLAB wrapper around c++ ConstantAccelerationMobilityModel object.
            
            objND = ConstantAccelerationMobilityModel(0);
            objND.cppHandle = val;
        end
    end
end