classdef Node < MlWrapper
    % Node This object models a node in the network.
    % More details at: https://www.nsnam.org/docs/release/3.26/doxygen/classns3_1_1_node.html
    
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
            mexNode('delete', obj.cppHandle);
        end
        
        function obj = Node(varargin)
            switch(length(varargin))
                case 0
                    obj.cppHandle = mexNode('new');
                case 1
                    obj.cppHandle = mexNode('new', varargin{1});
                otherwise
                    obj.cppHandle = 0;
            end
        end
        
        function objND = GetApplication(obj, index)
            objND = mexNode('GetApplication', obj.get(), index);
        end
        
        function objND = AddDevice(obj, device)
            objND = mexNode('AddDevice', obj.get(), device.get());
        end
        
        function objND = GetSystemId(obj)
            objND = mexNode('GetSystemId', obj.get());
        end
        
        function objND = GetId(obj)
            objND = mexNode('GetId', obj.get());
        end
        
        function objND = AddApplication(obj, application)
            objND = mexNode('AddApplication', obj.get(), application.get());
        end
        
        function objND = GetNDevices(obj)
            objND = mexNode('GetNDevices', obj.get());
        end
        
        function objND = GetDevice(obj, index)
            objND = mexNode('GetDevice', obj.get(), index);
        end
        
        function objND = GetLocalTime(obj)
            objND = mexNode('GetLocalTime', obj.get());
        end
        
        function objND = GetNApplications(obj)
            objND = mexNode('GetNApplications', obj.get());
        end
        
        function objND = GetObject(obj, type)
            % Gets the object installed on this node based on the object type.
            
            type = strcat('ns3::', type);
            objND = mexNode('GetObject', obj.get(), type);
            switch(type)
                case 'ns3::ConstantPositionMobilityModel'
                    objND = ConstantPositionMobilityModel.cpmmCreationFromUint64(objND);
                case 'ns3::ConstantVelocityMobilityModel'
                    objND = ConstantVelocityMobilityModel.cvmmCreationFromUint64(objND);
                case 'ns3::ConstantAccelerationMobilityModel'
                    objND = ConstantAccelerationMobilityModel.cammCreationFromUint64(objND);
                otherwise
                    objND = 0;
            end
        end
    end
    
    methods (Static)
        function objND = ChecksumEnabled()
            objND = mexNode('ChecksumEnabled');
        end
        
        function objND = nodeCreationFromUint64 (val)
            % MATLAB wrapper around c++ Node object.
            
            objND = Node(0, 0);
            objND.cppHandle = val;
        end
    end
end